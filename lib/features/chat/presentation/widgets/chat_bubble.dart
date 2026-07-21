import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/features/chat/domain/entities/chat_message.dart';
import 'package:clanship_cliente/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final String? senderAvatarUrl;
  final String? jobStatus;

  const ChatBubble({
    super.key,
    required this.message,
    this.senderAvatarUrl,
    this.jobStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');
    final isProposal = !isMe && message.text.startsWith('Propuesta de visita:');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (isProposal)
                  _buildProposalCard(context, theme)
                else if (message.type == ChatMessageType.image)
                  _buildImageBubble(context, theme)
                else if (message.type == ChatMessageType.audio)
                  _buildAudioBubble(context, theme)
                else
                  _buildTextBubble(context, theme),
                const SizedBox(height: 4),
                Text(
                  timeFormat.format(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isMe) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildTextBubble(BuildContext context, ThemeData theme) {
    final isMe = message.isMe;
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.70,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.primary
            : (theme.brightness == Brightness.dark
                  ? AppColors.slate800
                  : AppColors.slate100),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isMe ? 20 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 20),
        ),
        boxShadow: [
          if (isMe)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Text(
        message.text,
        style: TextStyle(
          color: isMe
              ? Colors.white
              : (theme.brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.slate900),
          fontSize: 15,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildImageBubble(BuildContext context, ThemeData theme) {
    final isMe = message.isMe;
    final fileUrl = message.fileUrl;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isMe ? 20 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 20),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: () {
          if (fileUrl != null && fileUrl.isNotEmpty) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  backgroundColor: Colors.black,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    iconTheme: const IconThemeData(color: Colors.white),
                  ),
                  body: Center(
                    child: InteractiveViewer(
                      child: Image.network(fileUrl),
                    ),
                  ),
                ),
              ),
            );
          }
        },
        child: fileUrl != null && fileUrl.isNotEmpty
            ? Image.network(
                fileUrl,
                width: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 220,
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              )
            : Container(
                width: 220,
                height: 150,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
      ),
    );
  }

  Widget _buildAudioBubble(BuildContext context, ThemeData theme) {
    if (message.fileUrl != null && message.fileUrl!.isNotEmpty) {
      return AudioBubbleContent(
        audioUrl: message.fileUrl!,
        isMe: message.isMe,
        isDark: theme.brightness == Brightness.dark,
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.red[100],
      child: const Text('Audio no disponible'),
    );
  }

  Widget _buildProposalCard(BuildContext context, ThemeData theme) {
    final text = message.text;
    String details = text.replaceFirst('Propuesta de visita:', '').trim();

    String dateTimeText = details;
    String? priceText;
    if (details.contains('|')) {
      final parts = details.split('|');
      dateTimeText = parts[0].trim();
      priceText = parts[1].trim();
    }

    final bool showActions = jobStatus == 'SCHEDULED';
    final bool isAccepted =
        jobStatus == 'AGREED' ||
        jobStatus == 'IN_VISIT' ||
        jobStatus == 'FINISHED';

    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Propuesta de Visita',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Fecha y Hora:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            dateTimeText,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (priceText != null) ...[
            const SizedBox(height: 8),
            Text(
              'Monto de la visita:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              priceText,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
          if (isAccepted) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Propuesta Aceptada',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ] else if (showActions) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<ChatBloc>().add(AcceptJobProposal());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Aceptar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<ChatBloc>().add(RejectJobProposal());
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Rechazar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: senderAvatarUrl != null && senderAvatarUrl!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(senderAvatarUrl!),
                fit: BoxFit.cover,
              )
            : null,
        color: Colors.grey[300],
      ),
      child: senderAvatarUrl == null || senderAvatarUrl!.isEmpty
          ? const Icon(Icons.person, size: 20, color: Colors.white)
          : null,
    );
  }
}

class AudioBubbleContent extends StatefulWidget {
  final String audioUrl;
  final bool isMe;
  final bool isDark;

  const AudioBubbleContent({
    super.key,
    required this.audioUrl,
    required this.isMe,
    required this.isDark,
  });

  @override
  State<AudioBubbleContent> createState() => _AudioBubbleContentState();
}

class _AudioBubbleContentState extends State<AudioBubbleContent> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() {
          _duration = d;
        });
      }
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() {
          _position = p;
        });
      }
    });
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(widget.audioUrl));
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.isMe ? Colors.white : (widget.isDark ? Colors.white : Colors.black87);
    final sliderActiveColor = widget.isMe ? Colors.white.withOpacity(0.9) : AppColors.primary;
    final sliderInactiveColor = widget.isMe ? Colors.white.withOpacity(0.3) : Colors.grey[400];

    return Container(
      width: 240,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.isMe 
            ? AppColors.primary
            : (widget.isDark ? AppColors.slate800 : AppColors.slate100),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(widget.isMe ? 20 : 4),
          bottomRight: Radius.circular(widget.isMe ? 4 : 20),
        ),
        boxShadow: [
          if (widget.isMe)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: themeColor,
              size: 28,
            ),
            onPressed: _togglePlay,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                    activeTrackColor: sliderActiveColor,
                    inactiveTrackColor: sliderInactiveColor,
                    thumbColor: sliderActiveColor,
                  ),
                  child: Slider(
                    min: 0.0,
                    max: _duration.inMilliseconds.toDouble() > 0.0 
                        ? _duration.inMilliseconds.toDouble() 
                        : 100.0,
                    value: _position.inMilliseconds.toDouble().clamp(
                      0.0, 
                      _duration.inMilliseconds.toDouble() > 0.0 
                          ? _duration.inMilliseconds.toDouble() 
                          : 100.0,
                    ),
                    onChanged: (val) async {
                      await _audioPlayer.seek(Duration(milliseconds: val.toInt()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: TextStyle(color: themeColor.withOpacity(0.7), fontSize: 11),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(color: themeColor.withOpacity(0.7), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
