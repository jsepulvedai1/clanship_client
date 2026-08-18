import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:clanship_cliente/core/config/env_config.dart';
import 'package:clanship_cliente/core/network/graphql_service.dart';
import 'package:clanship_cliente/features/chat/domain/entities/chat_message.dart';
import 'package:clanship_cliente/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final GraphQLService _graphQLService;
  final Map<String, StreamController<List<ChatMessage>>> _controllers = {};
  final Map<String, StreamController<Map<String, dynamic>>> _statusControllers = {};
  final Map<String, WebSocket> _sockets = {};

  ChatRepositoryImpl(this._graphQLService);

  @override
  Future<ChatRoomInfo> getOrCreateChatRoom(int professionalId, {int? jobId}) async {
    const String mutation = r'''
      mutation GetOrCreateChatRoom($professionalId: Int!, $jobId: Int) {
        getOrCreateChatRoom(professionalId: $professionalId, jobId: $jobId) {
          room {
            id
            job {
              id
              status
            }
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

    final roomData = result.data?['getOrCreateChatRoom']?['room'];
    if (roomData == null) {
      throw Exception('Could not fetch chat room data');
    }

    final roomId = roomData['id']?.toString() ?? '';
    final jobData = roomData['job'];
    final roomJobId = jobData?['id']?.toString();
    final roomJobStatus = jobData?['status']?.toString();

    return ChatRoomInfo(
      roomId: roomId,
      jobId: roomJobId,
      jobStatus: roomJobStatus,
    );
  }

  @override
  Stream<Map<String, dynamic>> getJobStatusEvents(String roomId) {
    if (!_statusControllers.containsKey(roomId)) {
      _statusControllers[roomId] = StreamController<Map<String, dynamic>>.broadcast();
    }
    return _statusControllers[roomId]!.stream;
  }

  @override
  Stream<List<ChatMessage>> getMessages(String roomId) {
    if (!_controllers.containsKey(roomId)) {
      late StreamController<List<ChatMessage>> controller;
      void startListening() {
        _fetchMessages(roomId, controller);
        _connectWebSocket(roomId, controller);
      }

      void stopListening() {
        _sockets[roomId]?.close();
        _sockets.remove(roomId);
      }

      controller = StreamController<List<ChatMessage>>.broadcast(
        onListen: () {
          startListening();
        },
        onCancel: () {
          stopListening();
        },
      );

      _controllers[roomId] = controller;
    }
    return _controllers[roomId]!.stream;
  }

  Future<void> _connectWebSocket(
    String roomId,
    StreamController<List<ChatMessage>> controller,
  ) async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      final uri = Uri.parse(EnvConfig.instance.websocketUrl);
      final scheme = uri.scheme == 'https'
          ? 'wss'
          : (uri.scheme == 'http' ? 'ws' : uri.scheme);
      final baseUrl =
          '$scheme://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
      final wsUrl = '$baseUrl/ws/chat/$roomId/?token=$token';

      final socket = await WebSocket.connect(wsUrl);
      _sockets[roomId] = socket;

      socket.listen(
        (data) {
          try {
            final Map<String, dynamic> jsonData = jsonDecode(data.toString());
            final eventType = jsonData['event'] ?? jsonData['type'];
            if (eventType == 'JOB_STATUS_CHANGED' ||
                eventType == 'job_status_changed') {
              if (_statusControllers.containsKey(roomId) &&
                  !_statusControllers[roomId]!.isClosed) {
                _statusControllers[roomId]!.add(jsonData);
              }
            } else {
              _fetchMessages(roomId, controller);
            }
          } catch (_) {
            _fetchMessages(roomId, controller);
          }
        },
        onError: (_) {},
        onDone: () {},
      );
    } catch (_) {}
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

  Future<void> _fetchMessages(String roomId, StreamController<List<ChatMessage>> controller) async {
    final myId = await _getMyUserId();

    const String query = r'''
      query ChatMessages($roomId: Int!) {
        chatMessages(roomId: $roomId) {
          id
          text
          createdAt
          fileUrl
          messageType
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
        final messageTypeStr = m['messageType'] as String? ?? 'TEXT';
        ChatMessageType type = ChatMessageType.text;
        if (messageTypeStr == 'IMAGE') {
          type = ChatMessageType.image;
        } else if (messageTypeStr == 'AUDIO') {
          type = ChatMessageType.audio;
        } else if (messageTypeStr == 'APPOINTMENT') {
          type = ChatMessageType.appointment;
        }

        return ChatMessage(
          id: m['id'].toString(),
          senderId: senderId,
          receiverId: '',
          text: m['text'] ?? '',
          timestamp: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
          isMe: senderId == myId,
          type: type,
          fileUrl: _sanitizeFileUrl(m['fileUrl'] as String?),
        );
      }).toList();

      if (!controller.isClosed) {
        controller.add(messages);
      }
    }
  }

  @override
  Future<void> sendMessage(
    String roomId, 
    String text, {
    String? fileBase64, 
    String? fileName, 
    String? messageType,
  }) async {
    const String mutation = r'''
      mutation SendMessage($roomId: Int!, $text: String, $fileBase64: String, $fileName: String, $messageType: String) {
        sendMessage(roomId: $roomId, text: $text, fileBase64: $fileBase64, fileName: $fileName, messageType: $messageType) {
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
        'fileBase64': fileBase64,
        'fileName': fileName,
        'messageType': messageType,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await _graphQLService.client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final controller = _controllers[roomId];
    if (controller != null) {
      _fetchMessages(roomId, controller);
    }
  }

  String? _sanitizeFileUrl(String? url) {
    if (url == null) return null;
    if (url.startsWith('http://') && 
        !url.contains('127.0.0.1') && 
        !url.contains('localhost') && 
        !url.contains('10.0.2.2')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
  }
}
