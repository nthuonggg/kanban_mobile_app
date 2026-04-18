import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../core/widgets/glass.dart';
import '../../domain/models/task_attachment.dart';
import '../providers/task_provider.dart';

/// Hiển thị + quản lý danh sách file đính kèm của một task.
class AttachmentList extends ConsumerWidget {
  final String taskId;
  const AttachmentList({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(taskAttachmentsProvider(taskId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.attach_file,
              size: 16,
              color: GlassPalette.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              'Tệp đính kèm',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: GlassPalette.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Thêm tệp'),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => _pickAndUpload(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 8),
        asyncList.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (e, _) => _ErrorBox(message: '$e'),
          data: (list) {
            if (list.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: GlassPalette.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Chưa có tệp nào',
                  style: TextStyle(
                    fontSize: 13,
                    color: GlassPalette.onSurfaceVariant,
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (final a in list) ...[
                  _AttachmentTile(
                    attachment: a,
                    onDelete: () => _confirmDelete(context, ref, a),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
    final picked = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (picked == null || picked.files.isEmpty) return;
    final pf = picked.files.single;
    if (pf.path == null) return;

    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Đang tải tệp lên…'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 30),
      ),
    );
    try {
      await ref
          .read(attachmentServiceProvider)
          .upload(taskId, File(pf.path!), pf.name);
      ref.invalidate(taskAttachmentsProvider(taskId));
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Đã đính kèm ${pf.name}'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Lỗi tải lên: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red[700],
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    TaskAttachment a,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa tệp?'),
        content: Text('Tệp "${a.fileName}" sẽ bị xóa vĩnh viễn.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(attachmentServiceProvider).delete(a);
      ref.invalidate(taskAttachmentsProvider(taskId));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi xóa: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }
}

class _AttachmentTile extends ConsumerWidget {
  final TaskAttachment attachment;
  final VoidCallback onDelete;
  const _AttachmentTile({
    required this.attachment,
    required this.onDelete,
  });

  IconData get _icon {
    if (attachment.isAudio) return Icons.audiotrack;
    if (attachment.isImage) return Icons.image;
    if (attachment.isPdf) return Icons.picture_as_pdf;
    return Icons.insert_drive_file;
  }

  Color get _color {
    if (attachment.isAudio) return GlassPalette.primary;
    if (attachment.isImage) return Colors.green.shade600;
    if (attachment.isPdf) return GlassPalette.tertiary;
    return GlassPalette.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: GlassPalette.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_icon, size: 20, color: _color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: GlassPalette.onSurface,
                        ),
                      ),
                      if (attachment.sizeLabel.isNotEmpty)
                        Text(
                          attachment.sizeLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: GlassPalette.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!attachment.isAudio)
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 18),
                    tooltip: 'Mở tệp',
                    onPressed: () => _openExternal(context, ref),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.red),
                  tooltip: 'Xóa',
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
          if (attachment.isAudio)
            _AudioPlayer(attachment: attachment, accentColor: _color),
        ],
      ),
    );
  }

  Future<void> _openExternal(BuildContext context, WidgetRef ref) async {
    try {
      final url = await ref
          .read(attachmentServiceProvider)
          .getViewableUrl(attachment);
      // Local file: mở bằng default app. Cloud (signed URL): mở trong browser.
      if (url.startsWith('http')) {
        // chưa có url_launcher — hiển thị URL để user copy/mở thủ công
        if (!context.mounted) return;
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Đường dẫn tệp'),
            content: SelectableText(url),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      } else {
        await OpenFilex.open(url);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không mở được tệp: $e')),
      );
    }
  }
}

// ════════════════════════════════════════════════════════════
// Mini audio player với just_audio
// ════════════════════════════════════════════════════════════

class _AudioPlayer extends ConsumerStatefulWidget {
  final TaskAttachment attachment;
  final Color accentColor;
  const _AudioPlayer({required this.attachment, required this.accentColor});

  @override
  ConsumerState<_AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends ConsumerState<_AudioPlayer> {
  final AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _ready = false;
  bool _loading = true;
  String? _error;

  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _stateSub;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    try {
      final url = await ref
          .read(attachmentServiceProvider)
          .getViewableUrl(widget.attachment);
      if (url.startsWith('http')) {
        await _player.setUrl(url);
      } else {
        await _player.setFilePath(url);
      }
      _durSub = _player.durationStream.listen((d) {
        if (d != null && mounted) setState(() => _duration = d);
      });
      _posSub = _player.positionStream.listen((p) {
        if (mounted) setState(() => _position = p);
      });
      _stateSub = _player.playerStateStream.listen((s) {
        if (mounted && s.processingState == ProcessingState.completed) {
          _player.seek(Duration.zero);
          _player.pause();
        }
      });
      if (mounted) setState(() => _ready = true);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: SizedBox(
          height: 24,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }
    if (_error != null || !_ready) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Text(
          'Không phát được: ${_error ?? "lỗi không rõ"}',
          style: const TextStyle(fontSize: 11, color: Colors.red),
        ),
      );
    }

    final isPlaying = _player.playing;
    final maxMs = _duration.inMilliseconds.toDouble().clamp(1, double.infinity);
    final posMs = _position.inMilliseconds.toDouble().clamp(0, maxMs);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Row(
        children: [
          IconButton(
            iconSize: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: widget.accentColor,
            ),
            onPressed: () async {
              if (isPlaying) {
                await _player.pause();
              } else {
                await _player.play();
              }
              if (mounted) setState(() {});
            },
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: widget.accentColor,
                inactiveTrackColor:
                    widget.accentColor.withValues(alpha: 0.25),
                thumbColor: widget.accentColor,
              ),
              child: Slider(
                value: posMs.toDouble(),
                max: maxMs.toDouble(),
                onChanged: (v) =>
                    _player.seek(Duration(milliseconds: v.toInt())),
              ),
            ),
          ),
          Text(
            '${_format(_position)} / ${_format(_duration)}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: GlassPalette.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Lỗi tải tệp: $message',
        style: const TextStyle(fontSize: 12, color: Colors.red),
      ),
    );
  }
}
