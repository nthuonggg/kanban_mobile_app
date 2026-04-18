import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/glass.dart';
import '../kanban/domain/models/task_model.dart';
import '../kanban/presentation/providers/task_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTasks = ref.watch(tasksStreamProvider);

    return Scaffold(
      body: SafeArea(
        child: asyncTasks.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Lỗi: $e')),
          data: (tasks) => _StatsContent(tasks: tasks),
        ),
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  final List<TaskModel> tasks;
  const _StatsContent({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final total = tasks.length;
    final done = tasks.where((t) => t.status == TaskStatus.done).length;
    final doing = tasks.where((t) => t.status == TaskStatus.doing).length;
    final todo = tasks.where((t) => t.status == TaskStatus.todo).length;
    final percent = total == 0 ? 0.0 : done / total;

    final high = tasks.where((t) => t.priority == TaskPriority.high).length;
    final medium =
        tasks.where((t) => t.priority == TaskPriority.medium).length;
    final low = tasks.where((t) => t.priority == TaskPriority.low).length;

    if (total == 0) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hoạt động',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
                height: 1.1,
                color: GlassPalette.onSurface,
              ),
            ),
            const SizedBox(height: 60),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.auto_graph,
                    size: 72,
                    color: GlassPalette.primaryContainer
                        .withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Chưa có dữ liệu',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: GlassPalette.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thêm vài công việc ở tab Bảng, thống kê sẽ\n'
                    'xuất hiện ở đây.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: GlassPalette.onSurfaceVariant
                          .withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hoạt động',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
              height: 1.05,
              color: GlassPalette.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          GlassContainer(
            borderRadius: 24,
            opacity: 0.88,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tỉ lệ hoàn thành',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: GlassPalette.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.data_usage,
                      color: GlassPalette.primaryContainer,
                      size: 30,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: 170,
                    height: 170,
                    child: CustomPaint(
                      painter: _RingPainter(percent),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(percent * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.5,
                                color: GlassPalette.onSurface,
                              ),
                            ),
                            const _SectionLabel(
                              'Đã hoàn thành',
                              color: GlassPalette.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle,
                  label: 'Hoàn thành',
                  value: done.toString(),
                  accent: Colors.green.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.play_circle,
                  label: 'Đang làm',
                  value: doing.toString(),
                  accent: GlassPalette.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.radio_button_unchecked,
                  label: 'Cần làm',
                  value: todo.toString(),
                  accent: Colors.amber.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.task_alt,
                  label: 'Tổng',
                  value: total.toString(),
                  accent: GlassPalette.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Phân bổ', color: GlassPalette.primary),
          const SizedBox(height: 10),
          GlassContainer(
            borderRadius: 24,
            opacity: 0.88,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Theo độ ưu tiên',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: GlassPalette.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                _PriorityBar(
                  label: 'Cao',
                  count: high,
                  total: total,
                  color: GlassPalette.tertiary,
                ),
                const SizedBox(height: 14),
                _PriorityBar(
                  label: 'Vừa',
                  count: medium,
                  total: total,
                  color: GlassPalette.primary,
                ),
                const SizedBox(height: 14),
                _PriorityBar(
                  label: 'Thấp',
                  count: low,
                  total: total,
                  color: Colors.green.shade600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel(this.text, {required this.color});
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: color,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 20,
      opacity: 0.86,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: GlassPalette.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              color: GlassPalette.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _PriorityBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: GlassPalette.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  _RingPainter(this.percent);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) / 2) - 10;

    final bgPaint = Paint()
      ..color = GlassPalette.outlineVariant.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (percent > 0) {
      final shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [GlassPalette.primary, GlassPalette.primaryContainer],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      final progressPaint = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * percent,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.percent != percent;
}
