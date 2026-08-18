import 'package:clanship_cliente/core/di/injection.dart';
import 'package:clanship_cliente/core/theme/app_colors.dart';
import 'package:clanship_cliente/core/utils/error_parser.dart';
import 'package:clanship_cliente/features/chat/domain/entities/chat_message.dart';
import 'package:clanship_cliente/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:clanship_cliente/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:clanship_cliente/features/home/domain/entities/professional.dart';
import 'package:clanship_cliente/features/jobs/presentation/widgets/create_job_bottom_sheet.dart';
import 'package:clanship_cliente/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_cliente/features/auth/presentation/bloc/auth_state.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:clanship_cliente/features/jobs/domain/repositories/job_repository.dart';
import 'package:record/record.dart';
import 'package:clanship_cliente/core/utils/image_cropper_helper.dart';

import 'dart:async';
import 'package:clanship_cliente/core/network/jobs_websocket_service.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_bloc.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_event.dart';
import 'package:clanship_cliente/features/jobs/presentation/widgets/rating_dialog.dart';

class ChatPage extends StatefulWidget {
  final Professional professional;
  final String? jobId;

  const ChatPage({super.key, required this.professional, this.jobId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final bool _isUrgent = false;
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _hasPromptedRating = false;
  StreamSubscription? _socketSubscription;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });

    final socketService = getIt<JobsWebSocketService>();
    _socketSubscription = socketService.stream.listen((event) {
      final eventType =
          (event['event']?.toString() ?? event['type']?.toString() ?? '').toLowerCase();
      if (eventType == 'job_updated' || eventType == 'job_status_changed' || eventType == 'job_cancelled') {
        final jobId = event['job_id']?.toString() ?? event['jobId']?.toString();
        final status =
            (event['status']?.toString() ?? event['new_status']?.toString() ?? '').toUpperCase();
        if (widget.jobId != null &&
            jobId == widget.jobId &&
            (status == 'CANCELLED' || eventType == 'job_cancelled')) {
          if (mounted) {
            final reason = event['cancellation_reason'] ?? event['reason'];
            final messageText = reason != null && reason.toString().isNotEmpty
                ? 'La solicitud de trabajo ha sido cancelada. Motivo: $reason'
                : 'La solicitud de trabajo ha sido cancelada.';
            context.read<NavigationBloc>().add(const TabChanged(0));
            Navigator.of(context).popUntil((route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(messageText),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _pickAndSendImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 70,
      );
      if (image == null) return;

      final croppedPath = await ImageCropperHelper.cropImage(
        imagePath: image.path,
        isSquare: false,
      );
      if (croppedPath == null) return;

      final File file = File(croppedPath);
      final bytes = await file.readAsBytes();
      final String base64Image = base64Encode(bytes);
      final String fileName = image.name;

      if (mounted) {
        context.read<ChatBloc>().add(
          SendMessage(
            widget.professional.id,
            '',
            fileBase64: 'data:image/jpeg;base64,$base64Image',
            fileName: fileName,
            messageType: 'IMAGE',
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking and sending image: $e');
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.primary,
                ),
                title: const Text('Tomar Foto'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickAndSendImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_rounded,
                  color: AppColors.primary,
                ),
                title: const Text('Elegir de Galería'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickAndSendImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleRecording() async {
    try {
      if (_isRecording) {
        final path = await _audioRecorder.stop();
        setState(() {
          _isRecording = false;
        });

        if (path != null) {
          final File file = File(path);
          final bytes = await file.readAsBytes();
          final String base64Audio = base64Encode(bytes);
          final String fileName =
              'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

          if (mounted) {
            context.read<ChatBloc>().add(
              SendMessage(
                widget.professional.id,
                '',
                fileBase64: 'data:audio/m4a;base64,$base64Audio',
                fileName: fileName,
                messageType: 'AUDIO',
              ),
            );
          }
        }
      } else {
        FocusScope.of(context).unfocus();
        if (await _audioRecorder.hasPermission()) {
          final directory = Directory.systemTemp;
          final String filePath =
              '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: filePath,
          );

          setState(() {
            _isRecording = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error toggling recording: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) =>
          getIt<ChatBloc>()
            ..add(LoadMessages(widget.professional.id, jobId: widget.jobId)),
      child: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is JobAcceptedState) {
            context.read<NavigationBloc>().add(const TabChanged(1));
            Navigator.of(context).popUntil((route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '¡Propuesta aceptada! Redirigiendo a Seguimiento.',
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is JobCancelledState) {
            context.read<NavigationBloc>().add(const TabChanged(0));
            Navigator.of(context).popUntil((route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.byMe
                      ? 'Has rechazado la propuesta de visita.'
                      : 'La solicitud de trabajo ha sido cancelada.',
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is ChatLoaded &&
              state.jobStatus == 'FINISHED' &&
              !_hasPromptedRating &&
              widget.jobId != null) {
            _hasPromptedRating = true;
            final jobIdInt = int.tryParse(widget.jobId!) ?? 0;
            if (jobIdInt != 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (_) => RatingDialog(
                      jobId: jobIdInt,
                      professionalName: widget.professional.name,
                    ),
                  );
                }
              });
            }
          }
        },
        child: Scaffold(
          backgroundColor: _isUrgent
              ? const Color(0xFFFFF0F0)
              : Theme.of(context).scaffoldBackgroundColor,
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(context, l10n),
          body: Column(
            children: [
              const SizedBox(height: 110), // AppBar + ActionBar space
              _buildActionBar(l10n),
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ChatLoaded) {
                      final messages = state.messages.reversed.toList();

                      ChatMessage? latestProposalMsg;
                      final hasProposalStatus =
                          state.jobStatus == 'SCHEDULED' ||
                          state.jobStatus == 'AGREED' ||
                          state.jobStatus == 'IN_VISIT' ||
                          state.jobStatus == 'FINISHED' ||
                          state.jobStatus == 'CANCELLED';
                      if (hasProposalStatus) {
                        try {
                          latestProposalMsg = state.messages.lastWhere(
                            (m) =>
                                !m.isMe &&
                                m.text.startsWith('Propuesta de visita:'),
                          );
                        } catch (_) {
                          latestProposalMsg = null;
                        }
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          String? avatarUrl;
                          if (msg.isMe) {
                            final authState = context.read<AuthBloc>().state;
                            if (authState is AuthAuthenticated) {
                              avatarUrl = authState.user.avatarPath;
                            }
                          } else {
                            avatarUrl = widget.professional.imageUrl;
                          }

                          final isLatest =
                              latestProposalMsg != null &&
                              msg.id == latestProposalMsg.id;

                          return ChatBubble(
                            message: msg,
                            senderAvatarUrl: avatarUrl,
                            jobStatus: state.jobStatus,
                            isLatestProposal: isLatest,
                          );
                        },
                      );
                    } else if (state is ChatError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              Builder(builder: (context) => _buildInputBar(context, l10n)),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return AppBar(
      backgroundColor: _isUrgent
          ? const Color(0xFFFFE5E5).withValues(alpha: 0.7)
          : Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.7),
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Theme.of(context).iconTheme.color,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.professional.imageUrl),
            radius: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.professional.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.chatStatusOnline,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.success),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.flag_outlined),
          tooltip: 'Reportar usuario o chat',
          onPressed: () => _showReportUserDialog(widget.professional.name),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildActionBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.jobId != null)
            _buildActionButton(
              label: l10n.chatActionEnrich,
              icon: Icons.add_photo_alternate_outlined,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              onTap: _showEnrichJobBottomSheet,
            )
          else
            _buildActionButton(
              label: l10n.chatActionJob,
              icon: Icons.work_outline_rounded,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              onTap: () async {
                final result = await showModalBottomSheet<dynamic>(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => CreateJobBottomSheet(
                    professionalId: int.parse(widget.professional.id),
                  ),
                );

                if (result is String && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.chatJobCreatedSuccess)),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        professional: widget.professional,
                        jobId: result,
                      ),
                    ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color : Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showAttachmentOptions,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? AppColors.slate800
                    : AppColors.slate100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.slate900
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  if (Theme.of(context).brightness == Brightness.light)
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: _isRecording
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      alignment: Alignment.centerLeft,
                      child: const Row(
                        children: [
                          Icon(Icons.mic, color: Colors.red, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Grabando audio...',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : TextField(
                      controller: _controller,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: l10n.chatInputPlaceholder,
                        hintStyle: TextStyle(
                          color: Theme.of(context).hintColor.withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Builder(
            builder: (context) => GestureDetector(
              onTap: () {
                if (_isRecording || _controller.text.isEmpty) {
                  _toggleRecording();
                } else {
                  context.read<ChatBloc>().add(
                    SendMessage(widget.professional.id, _controller.text),
                  );
                  _controller.clear();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.red : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isRecording
                      ? Icons.stop_rounded
                      : (_controller.text.isNotEmpty
                            ? Icons.send_rounded
                            : Icons.mic_rounded),
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEnrichJobBottomSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController detailsController = TextEditingController();
    XFile? selectedImage;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.chatEnrichTitle,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: detailsController,
                      minLines: 3,
                      maxLines: 5,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.chatEnrichHint,
                        hintStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Image selector
                    InkWell(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 70,
                        );
                        if (image != null) {
                          setModalState(() {
                            selectedImage = image;
                          });
                        }
                      },
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 36,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.chatEnrichAttachPhoto,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  File(selectedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (detailsController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.chatEnrichEnterDetailsError,
                                    ),
                                  ),
                                );
                                return;
                              }

                              setModalState(() {
                                isSaving = true;
                              });

                              final messenger = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(context);
                              final chatBloc = context.read<ChatBloc>();

                              try {
                                String? base64Photo;
                                if (selectedImage != null) {
                                  final bytes = await selectedImage!
                                      .readAsBytes();
                                  base64Photo =
                                      'data:image/png;base64,${base64.encode(bytes)}';
                                }

                                final jobIdInt =
                                    int.tryParse(widget.jobId ?? '') ?? 0;
                                if (jobIdInt > 0) {
                                  final jobRepository = getIt<JobRepository>();
                                  await jobRepository.enrichJob(
                                    jobIdInt,
                                    detailsController.text.trim(),
                                    base64Photo,
                                  );

                                  if (mounted) {
                                    navigator.pop();
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.chatEnrichSuccess),
                                      ),
                                    );
                                    // Enviar un mensaje de aviso en el chat
                                    chatBloc.add(
                                      SendMessage(
                                        widget.professional.id,
                                        l10n.chatEnrichMessage,
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error: ${getCleanErrorMessage(e)}',
                                    ),
                                  ),
                                );
                              } finally {
                                if (mounted) {
                                  setModalState(() {
                                    isSaving = false;
                                  });
                                }
                              }
                            },
                      child: isSaving
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Text(l10n.chatEnrichConfirm),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showReportUserDialog(String targetName) {
    final TextEditingController detailController = TextEditingController();
    String selectedReason = 'Lenguaje inapropiado o acoso';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.flag_outlined, color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reportar a $targetName',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona el motivo por el cual deseas reportar a este usuario en el chat:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...[
                    'Lenguaje inapropiado o acoso',
                    'Spam o fraude',
                    'Comportamiento sospechoso o agresivo',
                    'Foto o contenido ofensivo',
                    'Otro motivo',
                  ].map((reason) => RadioListTile<String>(
                        title: Text(reason, style: const TextStyle(fontSize: 14)),
                        value: reason,
                        groupValue: selectedReason,
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedReason = val);
                          }
                        },
                      )),
                  const SizedBox(height: 8),
                  TextField(
                    controller: detailController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Detalles adicionales (opcional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Reporte de chat recibido con éxito. El equipo de soporte revisará la conversación dentro de 24 horas.',
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      child: const Text(
                        'Enviar Reporte',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
