import 'dart:async';
import 'package:clanship_cliente/core/network/graphql_service.dart';
import 'package:clanship_cliente/features/chat/domain/entities/chat_message.dart';
import 'package:clanship_cliente/features/chat/domain/repositories/chat_repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final GraphQLService _graphQLService;
  final Map<String, StreamController<List<ChatMessage>>> _controllers = {};
  Timer? _pollingTimer;

  ChatRepositoryImpl(this._graphQLService);

  @override
  Future<String> getOrCreateChatRoom(int professionalId, {int? jobId}) async {
    const String mutation = r'''
      mutation GetOrCreateChatRoom($professionalId: Int!, $jobId: Int) {
        getOrCreateChatRoom(professionalId: $professionalId, jobId: $jobId) {
          room {
            id
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'professionalId': professionalId,
        'jobId': jobId,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await _graphQLService.client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final roomId = result.data?['getOrCreateChatRoom']?['room']?['id'];
    if (roomId == null) {
      throw Exception('Could not fetch chat room ID');
    }

    return roomId.toString();
  }

  @override
  Stream<List<ChatMessage>> getMessages(String roomId) {
    if (!_controllers.containsKey(roomId)) {
      _controllers[roomId] = StreamController<List<ChatMessage>>.broadcast();
      
      // Start polling
      _startPolling(roomId);
    }
    return _controllers[roomId]!.stream;
  }

  void _startPolling(String roomId) {
    _fetchMessages(roomId);
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchMessages(roomId);
    });
  }

  String? _myUserId;

  Future<String> _getMyUserId() async {
    if (_myUserId != null) return _myUserId!;
    const String meQuery = r'''
      query {
        me {
          id
        }
      }
    ''';
    final result = await _graphQLService.client.query(QueryOptions(
      document: gql(meQuery),
      fetchPolicy: FetchPolicy.networkOnly,
    ));
    if (!result.hasException && result.data?['me'] != null) {
      _myUserId = result.data!['me']['id'].toString();
    }
    return _myUserId ?? '';
  }

  Future<void> _fetchMessages(String roomId) async {
    final myId = await _getMyUserId();

    const String query = r'''
      query ChatMessages($roomId: Int!) {
        chatMessages(roomId: $roomId) {
          id
          text
          createdAt
          sender {
            id
          }
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {
        'roomId': int.parse(roomId),
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await _graphQLService.client.query(options);

    if (!result.hasException && result.data != null) {
      final messagesData = result.data?['chatMessages'] as List<dynamic>? ?? [];
      
      final messages = messagesData.map((m) {
        final senderId = m['sender']['id'].toString();
        return ChatMessage(
          id: m['id'].toString(),
          senderId: senderId,
          receiverId: '', // We don't necessarily have the receiver here
          text: m['text'] ?? '',
          timestamp: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
          isMe: senderId == myId,
        );
      }).toList();

      _controllers[roomId]?.add(messages);
    }
  }

  @override
  Future<void> sendMessage(String roomId, String text) async {
    const String mutation = r'''
      mutation SendMessage($roomId: Int!, $text: String!) {
        sendMessage(roomId: $roomId, text: $text) {
          message {
            id
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'roomId': int.parse(roomId),
        'text': text,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await _graphQLService.client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    
    // Trigger a fetch right after sending
    _fetchMessages(roomId);
  }
}
