import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/task_model.dart';

abstract class TaskRepository {
  Stream<List<TaskModel>> streamTasks();
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> updateTaskStatus(String id, TaskStatus status);
  Future<void> deleteTask(String id);
}

class SupabaseTaskRepository implements TaskRepository {
  final SupabaseClient _client;

  SupabaseTaskRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Stream<List<TaskModel>> streamTasks() {
    return _client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => TaskModel.fromJson(json)).toList());
  }

  @override
  Future<void> addTask(TaskModel task) async {
    await _client.from('tasks').insert(task.toJson());
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await _client.from('tasks').update({
      'title': task.title,
      'description': task.description,
      'status': task.status.name,
      'priority': task.priority.name,
      'due_date': task.dueDate?.toIso8601String(),
    }).eq('id', task.id);
  }

  @override
  Future<void> updateTaskStatus(String id, TaskStatus status) async {
    await _client.from('tasks').update({'status': status.name}).eq('id', id);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _client.from('tasks').delete().eq('id', id);
  }
}
