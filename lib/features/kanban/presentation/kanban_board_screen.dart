import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/app_state.dart';
import '../../../core/widgets/glass.dart';
import '../domain/models/task_model.dart';
import 'providers/task_provider.dart';
import 'widgets/attachment_list.dart';

class KanbanBoardScreen extends ConsumerStatefulWidget {
  const KanbanBoardScreen({super.key});

  @override
  ConsumerState<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

enum TaskSort { createdDesc, createdAsc, priorityDesc, dueDateAsc }

class _KanbanBoardScreenState extends ConsumerState<KanbanBoardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  TaskPriority? _priorityFilter;
  TaskSort _sort = TaskSort.createdDesc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? Colors.red[700] : null,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showTaskSheet({TaskModel? existing}) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final descController =
        TextEditingController(text: existing?.description ?? '');
    TaskPriority selectedPriority = existing?.priority ?? TaskPriority.medium;
    DateTime? selectedDueDate = existing?.dueDate;
    final isEdit = existing != null;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: GlassContainer(
              borderRadius: 28,
              opacity: 0.94,
              blur: 30,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: GlassPalette.outlineVariant
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isEdit ? 'Sửa công việc' : 'Thêm công việc',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                      height: 1.15,
                      color: GlassPalette.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _FieldLabel('Tên công việc'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    autofocus: !isEdit,
                    decoration: const InputDecoration(
                      hintText: 'VD: Hoàn thành báo cáo tuần…',
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('Mô tả (tuỳ chọn)'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Thêm ghi chú, liên kết, chi tiết…',
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _FieldLabel('Độ ưu tiên'),
                  const SizedBox(height: 8),
                  Row(
                    children: TaskPriority.values.map((p) {
                      final selected = p == selectedPriority;
                      final color = _priorityColor(p);
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: p == TaskPriority.high ? 0 : 8,
                          ),
                          child: GestureDetector(
                            onTap: () => setModalState(
                              () => selectedPriority = p,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: selected
                                    ? color
                                    : Colors.white.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected
                                      ? color
                                      : Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _priorityLabel(p),
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : GlassPalette.onSurfaceVariant,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  const _FieldLabel('Hạn hoàn thành (tuỳ chọn)'),
                  const SizedBox(height: 8),
                  _DueDateField(
                    value: selectedDueDate,
                    onChanged: (d) => setModalState(() => selectedDueDate = d),
                  ),
                  if (isEdit) ...[
                    const SizedBox(height: 18),
                    AttachmentList(taskId: existing.id),
                  ] else ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: GlassPalette.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: GlassPalette.onSurfaceVariant,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Lưu công việc xong, mở lại để đính kèm tệp.',
                              style: TextStyle(
                                fontSize: 12,
                                color: GlassPalette.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  GlassButton(
                    primary: true,
                    onPressed: () async {
                      final title = titleController.text.trim();
                      if (title.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Vui lòng nhập tên công việc'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      final repo = ref.read(taskRepositoryProvider);
                      try {
                        if (isEdit) {
                          await repo.updateTask(
                            existing.copyWith(
                              title: title,
                              description: descController.text.trim(),
                              priority: selectedPriority,
                              dueDate: selectedDueDate,
                              clearDueDate: selectedDueDate == null,
                            ),
                          );
                        } else {
                          await repo.addTask(TaskModel(
                            id: '',
                            title: title,
                            description: descController.text.trim(),
                            status: TaskStatus.todo,
                            priority: selectedPriority,
                            createdAt: DateTime.now(),
                            dueDate: selectedDueDate,
                          ));
                        }
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        _toast(isEdit ? 'Đã lưu thay đổi' : 'Đã thêm công việc');
                      } catch (e) {
                        if (!ctx.mounted) return;
                        _toast('Lỗi: $e', error: true);
                      }
                    },
                    child: Text(isEdit ? 'Lưu thay đổi' : 'Thêm ngay'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return Colors.green.shade600;
      case TaskPriority.medium:
        return GlassPalette.primary;
      case TaskPriority.high:
        return GlassPalette.tertiary;
    }
  }

  static String _priorityLabel(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return 'THẤP';
      case TaskPriority.medium:
        return 'VỪA';
      case TaskPriority.high:
        return 'CAO';
    }
  }

  Widget _buildDropTab(int index, String label, TaskStatus status) {
    return Tab(
      child: DragTarget<TaskModel>(
        onWillAcceptWithDetails: (details) => details.data.status != status,
        onAcceptWithDetails: (details) async {
          final task = details.data;
          try {
            await ref
                .read(taskRepositoryProvider)
                .updateTaskStatus(task.id, status);
            _tabController.animateTo(index);
            _toast('Đã chuyển "${task.title}" sang $label');
          } catch (e) {
            _toast('Lỗi: $e', error: true);
          }
        },
        builder: (context, candidate, rejected) {
          final hover = candidate.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: hover
                ? BoxDecoration(
                    color: GlassPalette.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: GlassPalette.primary.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  )
                : null,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: hover ? FontWeight.w900 : FontWeight.w800,
                color: hover ? GlassPalette.primary : null,
                letterSpacing: 0.2,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _priorityChip({
    required String label,
    required TaskPriority? value,
    bool isLast = false,
  }) {
    final selected = _priorityFilter == value;
    return Padding(
      padding: EdgeInsets.only(right: isLast ? 0 : 8),
      child: GestureDetector(
        onTap: () => setState(() => _priorityFilter = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? GlassPalette.primary
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? GlassPalette.primary
                  : GlassPalette.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: GlassPalette.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : GlassPalette.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = AppState.instance.type == SessionType.guest;
    final user = Supabase.instance.client.auth.currentUser;
    final email = isGuest ? '' : (user?.email ?? '');
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top row: avatar + pill search button (style Aéro Vitrum)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          GlassPalette.primary,
                          GlassPalette.primaryContainer,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    alignment: Alignment.center,
                    child: isGuest
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 22,
                          )
                        : Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                  const Spacer(),
                  _ModeChip(isGuest: isGuest),
                  const SizedBox(width: 8),
                  _SortMenuBtn(
                    current: _sort,
                    onChanged: (s) => setState(() => _sort = s),
                  ),
                ],
              ),
            ),
            // Display title
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Bảng công việc',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                    height: 1.1,
                    color: GlassPalette.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Search pill
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm công việc, nhãn…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide(
                      color: GlassPalette.outlineVariant
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(
                      color: GlassPalette.primaryContainer,
                      width: 1.6,
                    ),
                  ),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
            // Priority filter chips — căn giữa
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _priorityChip(label: 'Tất cả', value: null),
                  _priorityChip(label: 'THẤP', value: TaskPriority.low),
                  _priorityChip(label: 'VỪA', value: TaskPriority.medium),
                  _priorityChip(label: 'CAO', value: TaskPriority.high, isLast: true),
                ],
              ),
            ),
            // TabBar columns — wrap Tab trong DragTarget để kéo-thả đổi status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
                tabs: [
                  _buildDropTab(0, 'Cần làm', TaskStatus.todo),
                  _buildDropTab(1, 'Đang làm', TaskStatus.doing),
                  _buildDropTab(2, 'Hoàn thành', TaskStatus.done),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TaskColumn(
                    status: 'todo',
                    searchQuery: _searchQuery,
                    priorityFilter: _priorityFilter,
                    sort: _sort,
                    onEdit: (t) => _showTaskSheet(existing: t),
                    onToast: _toast,
                  ),
                  _TaskColumn(
                    status: 'doing',
                    searchQuery: _searchQuery,
                    priorityFilter: _priorityFilter,
                    sort: _sort,
                    onEdit: (t) => _showTaskSheet(existing: t),
                    onToast: _toast,
                  ),
                  _TaskColumn(
                    status: 'done',
                    searchQuery: _searchQuery,
                    priorityFilter: _priorityFilter,
                    sort: _sort,
                    onEdit: (t) => _showTaskSheet(existing: t),
                    onToast: _toast,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 96),
        child: FloatingActionButton.extended(
          onPressed: () => _showTaskSheet(),
          icon: const Icon(Icons.add),
          label: const Text('Thêm việc'),
        ),
      ),
    );
  }
}

/// Pill badge hiển thị trạng thái mode (cloud/local) — không bấm được.
class _ModeChip extends StatelessWidget {
  final bool isGuest;
  const _ModeChip({required this.isGuest});

  @override
  Widget build(BuildContext context) {
    final tint = isGuest ? Colors.orange[700]! : Colors.green[700]!;
    final bg = isGuest ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9);
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tint.withValues(alpha: 0.35)),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGuest ? Icons.smartphone : Icons.cloud_done,
            size: 14,
            color: tint,
          ),
          const SizedBox(width: 4),
          Text(
            isGuest ? 'Cục bộ' : 'Cloud',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
              color: tint,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskColumn extends ConsumerWidget {
  final String status;
  final String searchQuery;
  final TaskPriority? priorityFilter;
  final TaskSort sort;
  final void Function(TaskModel) onEdit;
  final void Function(String, {bool error}) onToast;

  const _TaskColumn({
    required this.status,
    required this.searchQuery,
    required this.priorityFilter,
    required this.sort,
    required this.onEdit,
    required this.onToast,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTasks = ref.watch(tasksStreamProvider);
    final query = searchQuery.trim().toLowerCase();

    return asyncTasks.when(
      data: (tasks) {
        final columnTasks = tasks.where((t) {
          if (t.status.name != status) return false;
          if (priorityFilter != null && t.priority != priorityFilter) {
            return false;
          }
          if (query.isNotEmpty &&
              !t.title.toLowerCase().contains(query) &&
              !t.description.toLowerCase().contains(query)) {
            return false;
          }
          return true;
        }).toList();
        _applySort(columnTasks);

        if (columnTasks.isEmpty) {
          final emptyText = (query.isNotEmpty || priorityFilter != null)
              ? 'Không có việc nào khớp bộ lọc'
              : 'Chưa có việc nào';
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: GlassPalette.primaryContainer
                        .withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.inbox_outlined,
                    size: 36,
                    color: GlassPalette.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  emptyText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: GlassPalette.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 200),
          itemCount: columnTasks.length,
          itemBuilder: (context, index) {
            final task = columnTasks[index];
            return _TaskCard(
              task: task,
              onEdit: () => onEdit(task),
              onToast: onToast,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Lỗi khi tải dữ liệu: $e',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _applySort(List<TaskModel> list) {
    switch (sort) {
      case TaskSort.createdDesc:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case TaskSort.createdAsc:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case TaskSort.priorityDesc:
        int rank(TaskPriority p) => switch (p) {
              TaskPriority.high => 0,
              TaskPriority.medium => 1,
              TaskPriority.low => 2,
            };
        list.sort((a, b) => rank(a.priority).compareTo(rank(b.priority)));
      case TaskSort.dueDateAsc:
        list.sort((a, b) {
          final ad = a.dueDate;
          final bd = b.dueDate;
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return ad.compareTo(bd);
        });
    }
  }
}

class _TaskCard extends ConsumerWidget {
  final TaskModel task;
  final VoidCallback onEdit;
  final void Function(String, {bool error}) onToast;

  const _TaskCard({
    required this.task,
    required this.onEdit,
    required this.onToast,
  });

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa công việc?'),
        content: Text('"${task.title}" sẽ bị xóa vĩnh viễn.'),
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
      await ref.read(taskRepositoryProvider).deleteTask(task.id);
      onToast('Đã xóa công việc');
    } catch (e) {
      onToast('Lỗi xóa: $e', error: true);
    }
  }

  Future<void> _changeStatus(WidgetRef ref, TaskStatus status) async {
    try {
      await ref.read(taskRepositoryProvider).updateTaskStatus(task.id, status);
      onToast('Đã chuyển sang "${_statusLabel(status)}"');
    } catch (e) {
      onToast('Lỗi: $e', error: true);
    }
  }

  static String _statusLabel(TaskStatus s) {
    switch (s) {
      case TaskStatus.todo:
        return 'Cần làm';
      case TaskStatus.doing:
        return 'Đang làm';
      case TaskStatus.done:
        return 'Hoàn thành';
    }
  }

  void _showActionSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: GlassContainer(
          borderRadius: 24,
          opacity: 0.94,
          blur: 30,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Sửa'),
                  onTap: () {
                    Navigator.pop(ctx);
                    onEdit();
                  },
                ),
                if (task.status != TaskStatus.todo)
                  ListTile(
                    leading: const Icon(Icons.west),
                    title: const Text('Chuyển sang Cần làm'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _changeStatus(ref, TaskStatus.todo);
                    },
                  ),
                if (task.status != TaskStatus.doing)
                  ListTile(
                    leading: const Icon(Icons.play_arrow),
                    title: const Text('Chuyển sang Đang làm'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _changeStatus(ref, TaskStatus.doing);
                    },
                  ),
                if (task.status != TaskStatus.done)
                  ListTile(
                    leading: const Icon(Icons.check, color: Colors.green),
                    title: const Text(
                      'Chuyển sang Hoàn thành',
                      style: TextStyle(color: Colors.green),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _changeStatus(ref, TaskStatus.done);
                    },
                  ),
                const Divider(height: 8),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Xóa công việc',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmDelete(context, ref);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorMap = {
      TaskPriority.low: Colors.green.shade600,
      TaskPriority.medium: GlassPalette.primary,
      TaskPriority.high: GlassPalette.tertiary,
    };
    final pColor = colorMap[task.priority]!;
    final priorityText = _priorityTagText(task.priority);

    final card = _buildCard(context, ref, pColor, priorityText);

    return LongPressDraggable<TaskModel>(
      data: task,
      delay: const Duration(milliseconds: 280),
      onDragStarted: () => HapticFeedback.mediumImpact(),
      feedback: _DragFeedback(task: task, color: pColor),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      child: card,
    );
  }

  Widget _buildCard(
    BuildContext context,
    WidgetRef ref,
    Color pColor,
    String priorityText,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          GlassContainer(
            borderRadius: 20,
            opacity: 0.72,
            blur: 20,
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
            onTap: onEdit,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: pColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: pColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        priorityText,
                        style: TextStyle(
                          color: pColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      height: 28,
                      child: IconButton(
                        icon: const Icon(Icons.more_vert, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _showActionSheet(context, ref),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: GlassPalette.onSurface,
                    letterSpacing: -0.3,
                    height: 1.25,
                  ),
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    task.description,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: GlassPalette.onSurfaceVariant,
                      height: 1.45,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                _AttachmentCountBadge(taskId: task.id),
                if (task.dueDate != null) ...[
                  const SizedBox(height: 10),
                  _DueDateBadge(
                    dueDate: task.dueDate!,
                    isDone: task.status == TaskStatus.done,
                  ),
                ],
              ],
            ),
          ),
          // Dải màu bên trái — đủ nhận diện, bớt glow cho đỡ rối
          Positioned(
            left: 0,
            top: 14,
            bottom: 14,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: pColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _priorityTagText(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return 'THẤP';
      case TaskPriority.medium:
        return 'VỪA';
      case TaskPriority.high:
        return 'CAO';
    }
  }
}

/// Nút menu sort trên header Kanban.
class _SortMenuBtn extends StatelessWidget {
  final TaskSort current;
  final ValueChanged<TaskSort> onChanged;
  const _SortMenuBtn({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TaskSort>(
      tooltip: 'Sắp xếp',
      initialValue: current,
      onSelected: onChanged,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (ctx) => const [
        PopupMenuItem(
          value: TaskSort.createdDesc,
          child: Text('Mới nhất trước'),
        ),
        PopupMenuItem(
          value: TaskSort.createdAsc,
          child: Text('Cũ nhất trước'),
        ),
        PopupMenuItem(
          value: TaskSort.priorityDesc,
          child: Text('Theo độ ưu tiên'),
        ),
        PopupMenuItem(
          value: TaskSort.dueDateAsc,
          child: Text('Theo hạn (gần nhất)'),
        ),
      ],
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: GlassPalette.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: const Icon(
          Icons.sort,
          size: 20,
          color: GlassPalette.onSurface,
        ),
      ),
    );
  }
}

/// Ô chọn hạn hoàn thành trong sheet add/edit.
class _DueDateField extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  const _DueDateField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? now,
            firstDate: DateTime(now.year - 1),
            lastDate: DateTime(now.year + 5),
            helpText: 'Chọn hạn hoàn thành',
            cancelText: 'Hủy',
            confirmText: 'Chọn',
          );
          if (picked != null) onChanged(picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: GlassPalette.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: GlassPalette.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value == null
                      ? 'Không đặt hạn'
                      : _formatDueDate(value!),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: value == null
                        ? GlassPalette.outlineVariant
                        : GlassPalette.onSurface,
                  ),
                ),
              ),
              if (value != null)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minHeight: 28,
                    minWidth: 28,
                  ),
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => onChanged(null),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDueDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }
}

/// Badge hiển thị hạn hoàn thành trên TaskCard.
class _DueDateBadge extends StatelessWidget {
  final DateTime dueDate;
  final bool isDone;
  const _DueDateBadge({required this.dueDate, required this.isDone});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = due.difference(today).inDays;

    String label;
    Color color;
    IconData icon;

    if (isDone) {
      label = _format(dueDate);
      color = Colors.grey.shade600;
      icon = Icons.event_available_outlined;
    } else if (diff < 0) {
      label = 'Quá hạn ${-diff} ngày';
      color = GlassPalette.tertiary;
      icon = Icons.warning_amber_rounded;
    } else if (diff == 0) {
      label = 'Hôm nay';
      color = Colors.orange.shade700;
      icon = Icons.today_outlined;
    } else if (diff == 1) {
      label = 'Ngày mai';
      color = Colors.orange.shade700;
      icon = Icons.event_outlined;
    } else if (diff <= 7) {
      label = 'Còn $diff ngày';
      color = GlassPalette.primary;
      icon = Icons.event_outlined;
    } else {
      label = _format(dueDate);
      color = GlassPalette.onSurfaceVariant;
      icon = Icons.event_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              decoration: isDone ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  static String _format(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}';
  }
}

/// Widget hiển thị lúc đang kéo card — card "ma" nhẹ + shadow.
class _DragFeedback extends StatelessWidget {
  final TaskModel task;
  final Color color;
  const _DragFeedback({required this.task, required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Transform.rotate(
        angle: 0.02,
        child: Container(
          width: 300,
          padding: const EdgeInsets.fromLTRB(20, 14, 14, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: GlassPalette.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.drag_indicator, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Badge nhỏ hiển thị "📎 N" tệp đính kèm trên TaskCard.
class _AttachmentCountBadge extends ConsumerWidget {
  final String taskId;
  const _AttachmentCountBadge({required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(taskAttachmentsProvider(taskId));
    final count = asyncList.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );
    if (count == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: GlassPalette.primaryContainer.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.attach_file,
              size: 12,
              color: GlassPalette.primary,
            ),
            const SizedBox(width: 3),
            Text(
              '$count tệp',
              style: const TextStyle(
                color: GlassPalette.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Label chữ nhỏ in hoa phía trên input (theo mock Aéro Vitrum).
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: GlassPalette.onSurfaceVariant,
        ),
      ),
    );
  }
}
