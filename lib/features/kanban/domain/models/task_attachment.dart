/// File đính kèm cho một task.
class TaskAttachment {
  final String id;
  final String taskId;
  final String fileName;

  /// Cloud: đường dẫn trong Supabase Storage (`<userId>/<taskId>/<file>`).
  /// Guest: đường dẫn file thật trong app documents directory.
  final String filePath;

  final String? mimeType;
  final int? fileSize;
  final DateTime createdAt;

  TaskAttachment({
    required this.id,
    required this.taskId,
    required this.fileName,
    required this.filePath,
    this.mimeType,
    this.fileSize,
    required this.createdAt,
  });

  factory TaskAttachment.fromJson(Map<String, dynamic> json) {
    return TaskAttachment(
      id: json['id'].toString(),
      taskId: json['task_id'].toString(),
      fileName: json['file_name'] ?? '',
      filePath: json['file_path'] ?? '',
      mimeType: json['mime_type'],
      fileSize: json['file_size'] is int
          ? json['file_size']
          : (json['file_size'] == null
              ? null
              : int.tryParse(json['file_size'].toString())),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'task_id': taskId,
        'file_name': fileName,
        'file_path': filePath,
        'mime_type': mimeType,
        'file_size': fileSize,
        'created_at': createdAt.toIso8601String(),
      };

  bool get isAudio => mimeType?.startsWith('audio/') ?? false;
  bool get isImage => mimeType?.startsWith('image/') ?? false;
  bool get isPdf => mimeType == 'application/pdf';

  String get sizeLabel {
    if (fileSize == null) return '';
    final kb = fileSize! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  /// Đoán mime type từ tên file (nếu file_picker không trả về).
  static String? guessMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return const {
      'mp3': 'audio/mpeg',
      'wav': 'audio/wav',
      'm4a': 'audio/mp4',
      'aac': 'audio/aac',
      'ogg': 'audio/ogg',
      'flac': 'audio/flac',
      'png': 'image/png',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'txt': 'text/plain',
      'mp4': 'video/mp4',
      'mov': 'video/quicktime',
    }[ext];
  }
}
