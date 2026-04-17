import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/task_model.dart';
import 'task_repository.dart';

class LocalTaskRepository implements TaskRepository {
  LocalTaskRepository._();
  static final LocalTaskRepository instance = LocalTaskRepository._();

  static const _storageKey = 'guest_tasks';

  final StreamController<List<TaskModel>> _controller =
      StreamController<List<TaskModel>>.broadcast();
  List<TaskModel> _cache = [];
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final list = jsonDecode(raw) as List;
      _cache = list
          .map((e) => TaskModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    _loaded = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_cache.map((t) => t.toJson()).toList()),
    );
    _controller.add(List.of(_cache));
  }

  @override
  Stream<List<TaskModel>> streamTasks() async* {
    await _ensureLoaded();
    yield List.of(_cache);
    yield* _controller.stream;
  }

  @override
  Future<void> addTask(TaskModel task) async {
    await _ensureLoaded();
    final newId = DateTime.now().microsecondsSinceEpoch.toString();
    _cache.insert(0, task.copyWith(id: newId));
    await _save();
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await _ensureLoaded();
    _cache = _cache.map((t) => t.id == task.id ? task : t).toList();
    await _save();
  }

  @override
  Future<void> updateTaskStatus(String id, TaskStatus status) async {
    await _ensureLoaded();
    _cache = _cache
        .map((t) => t.id == id ? t.copyWith(status: status) : t)
        .toList();
    await _save();
  }

  @override
  Future<void> deleteTask(String id) async {
    await _ensureLoaded();
    _cache.removeWhere((t) => t.id == id);
    await _save();
  }
}
