import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../features/kanban/domain/models/task_model.dart';

/// Quản lý local notification — nhắc hạn task.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'task_due_channel';
  static const String _channelName = 'Nhắc hạn công việc';
  static const String _channelDesc = 'Thông báo khi công việc đến hạn';

  static bool _initialized = false;

  /// Init plugin + timezone + xin quyền (gọi 1 lần ở main()).
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Init timezone database — bắt buộc cho zonedSchedule.
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Xin quyền Android 13+ và iOS
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await android?.requestNotificationsPermission();
        await android?.requestExactAlarmsPermission();
      } else if (Platform.isIOS || Platform.isMacOS) {
        await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }
    }
  }

  static NotificationDetails _details() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  /// Gửi thông báo ngay (dùng để test).
  static Future<void> showNow({
    required String title,
    required String body,
  }) async {
    await init();
    await _plugin.show(0, title, body, _details());
  }

  /// Đồng bộ tất cả notification dựa trên danh sách task hiện tại.
  /// Hủy tất cả lịch cũ rồi đặt lại lịch mới cho task có dueDate trong tương lai
  /// và chưa hoàn thành. Gọi mỗi khi tasks thay đổi.
  static Future<int> syncFromTasks(List<TaskModel> tasks) async {
    await init();
    await _plugin.cancelAll();

    int scheduled = 0;
    final now = DateTime.now();

    for (final task in tasks) {
      final due = task.dueDate;
      if (due == null) continue;
      if (task.status == TaskStatus.done) continue;

      // Nếu user chỉ chọn ngày (giờ 00:00) → mặc định nhắc lúc 9h sáng.
      DateTime fireAt;
      if (due.hour == 0 && due.minute == 0) {
        fireAt = DateTime(due.year, due.month, due.day, 9, 0);
      } else {
        fireAt = due;
      }
      if (fireAt.isBefore(now)) continue; // bỏ qua quá khứ

      try {
        await _plugin.zonedSchedule(
          task.id.hashCode & 0x7fffffff, // ID dương 32-bit
          'Đến hạn: ${task.title}',
          task.description.isNotEmpty
              ? task.description
              : 'Công việc của bạn đã đến hạn.',
          tz.TZDateTime.from(fireAt, tz.local),
          _details(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        scheduled++;
      } catch (e) {
        // Bỏ qua lỗi để các task khác vẫn được đặt lịch
        debugPrint('Lỗi schedule notification cho task ${task.id}: $e');
      }
    }
    return scheduled;
  }

  static Future<void> cancelForTask(String taskId) async {
    await init();
    await _plugin.cancel(taskId.hashCode & 0x7fffffff);
  }
}
