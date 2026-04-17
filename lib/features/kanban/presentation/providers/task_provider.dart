import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_state.dart';
import '../../data/local_task_repository.dart';
import '../../data/task_repository.dart';
import '../../domain/models/task_model.dart';

// Provider ch\u1ecdn repo theo ch\u1ebf \u0111\u1ed9 \u0111\u0103ng nh\u1eadp:
// - guest  -> LocalTaskRepository (SharedPreferences)
// - cloud  -> SupabaseTaskRepository (Supabase Realtime)
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  if (AppState.instance.type == SessionType.guest) {
    return LocalTaskRepository.instance;
  }
  return SupabaseTaskRepository();
});

// Stream Provider t\u1ef1 \u0111\u1ed9ng qu\u1ea3n l\u00fd lu\u1ed3ng d\u1eef li\u1ec7u realtime/local.
final tasksStreamProvider = StreamProvider.autoDispose<List<TaskModel>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.streamTasks();
});
