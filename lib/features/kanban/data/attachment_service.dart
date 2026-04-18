import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/task_attachment.dart';

abstract class AttachmentService {
  Future<List<TaskAttachment>> listForTask(String taskId);
  Future<TaskAttachment> upload(String taskId, File file, String fileName);
  Future<void> delete(TaskAttachment attachment);

  /// URL/đường dẫn để play/mở file (signed URL với cloud, file path với local).
  Future<String> getViewableUrl(TaskAttachment attachment);
}

// ════════════════════════════════════════════════════════════
// Cloud — Supabase Storage + bảng task_attachments
// ════════════════════════════════════════════════════════════

class SupabaseAttachmentService implements AttachmentService {
  static const String bucket = 'task-attachments';
  final SupabaseClient _client;

  SupabaseAttachmentService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<TaskAttachment>> listForTask(String taskId) async {
    final rows = await _client
        .from('task_attachments')
        .select()
        .eq('task_id', taskId)
        .order('created_at');
    return (rows as List)
        .map((j) => TaskAttachment.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TaskAttachment> upload(
    String taskId,
    File file,
    String fileName,
  ) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Cần đăng nhập để upload file lên Supabase Storage.');
    }
    final ts = DateTime.now().microsecondsSinceEpoch;
    final storagePath = '${user.id}/$taskId/${ts}_$fileName';
    final mime = TaskAttachment.guessMimeType(fileName);
    final size = await file.length();

    await _client.storage.from(bucket).upload(
          storagePath,
          file,
          fileOptions: FileOptions(contentType: mime, upsert: false),
        );

    final inserted = await _client
        .from('task_attachments')
        .insert({
          'task_id': taskId,
          'file_name': fileName,
          'file_path': storagePath,
          'mime_type': mime,
          'file_size': size,
        })
        .select()
        .single();

    return TaskAttachment.fromJson(inserted);
  }

  @override
  Future<void> delete(TaskAttachment attachment) async {
    // Xóa file vật lý trước, rồi xóa row.
    await _client.storage.from(bucket).remove([attachment.filePath]);
    await _client.from('task_attachments').delete().eq('id', attachment.id);
  }

  @override
  Future<String> getViewableUrl(TaskAttachment attachment) async {
    return await _client.storage
        .from(bucket)
        .createSignedUrl(attachment.filePath, 60 * 60);
  }
}

// ════════════════════════════════════════════════════════════
// Local — guest mode: file copy vào app documents + index trong SharedPreferences
// ════════════════════════════════════════════════════════════

class LocalAttachmentService implements AttachmentService {
  LocalAttachmentService._();
  static final LocalAttachmentService instance = LocalAttachmentService._();

  static const String _key = 'guest_attachments';

  Future<Directory> _attachmentsDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/attachments');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<List<TaskAttachment>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List)
        .map((j) => TaskAttachment.fromJson(Map<String, dynamic>.from(j as Map)))
        .toList();
  }

  Future<void> _saveAll(List<TaskAttachment> all) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(all.map((a) => a.toJson()).toList()),
    );
  }

  @override
  Future<List<TaskAttachment>> listForTask(String taskId) async {
    final all = await _loadAll();
    return all.where((a) => a.taskId == taskId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<TaskAttachment> upload(
    String taskId,
    File file,
    String fileName,
  ) async {
    final dir = await _attachmentsDir();
    final ts = DateTime.now().microsecondsSinceEpoch;
    final newPath = '${dir.path}/${ts}_$fileName';
    final copy = await file.copy(newPath);

    final attachment = TaskAttachment(
      id: ts.toString(),
      taskId: taskId,
      fileName: fileName,
      filePath: copy.path,
      mimeType: TaskAttachment.guessMimeType(fileName),
      fileSize: await file.length(),
      createdAt: DateTime.now(),
    );

    final all = await _loadAll();
    all.add(attachment);
    await _saveAll(all);
    return attachment;
  }

  @override
  Future<void> delete(TaskAttachment attachment) async {
    try {
      final f = File(attachment.filePath);
      if (await f.exists()) await f.delete();
    } catch (_) {
      // bỏ qua lỗi xóa file vật lý
    }
    final all = await _loadAll();
    all.removeWhere((a) => a.id == attachment.id);
    await _saveAll(all);
  }

  @override
  Future<String> getViewableUrl(TaskAttachment attachment) async {
    return attachment.filePath;
  }
}
