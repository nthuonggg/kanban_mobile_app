import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_state.dart';
import '../../core/notification_service.dart';
import '../../core/widgets/glass.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _confirmSignOut() async {
    final isGuest = AppState.instance.type == SessionType.guest;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: Text(
          isGuest
              ? 'Công việc đã lưu cục bộ vẫn sẽ được giữ trên thiết bị.'
              : 'Bạn sẽ đăng xuất khỏi tài khoản hiện tại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await AppState.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = AppState.instance.type == SessionType.guest;
    final user = Supabase.instance.client.auth.currentUser;
    final email = isGuest ? 'Chưa đăng nhập' : (user?.email ?? '—');
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hồ sơ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  height: 1.1,
                  color: GlassPalette.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
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
                    boxShadow: [
                      BoxShadow(
                        color: GlassPalette.primary.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: isGuest
                      ? const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 44,
                        )
                      : Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  email,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: GlassPalette.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: _ModeBadge(isGuest: isGuest),
              ),
              const SizedBox(height: 28),
              _SectionLabel('Tài khoản'),
              const SizedBox(height: 10),
              GlassContainer(
                borderRadius: 20,
                opacity: 0.88,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.verified_outlined,
                      label: 'Phương thức đăng nhập',
                      value: isGuest
                          ? 'Không tài khoản'
                          : _providerLabel(
                              user?.appMetadata['provider']?.toString(),
                            ),
                    ),
                    if (!isGuest) ...[
                      const _Divider(),
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Ngày tạo tài khoản',
                        value: _formatDate(user?.createdAt),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SectionLabel('Ứng dụng'),
              const SizedBox(height: 10),
              GlassContainer(
                borderRadius: 20,
                opacity: 0.88,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _ActionRow(
                      icon: Icons.notifications_active_outlined,
                      label: 'Gửi thông báo thử',
                      onTap: () async {
                        await NotificationService.showNow(
                          title: 'Kanban Cá Nhân',
                          body:
                              'Thông báo hoạt động bình thường. Lịch nhắc hạn '
                              'task sẽ tự đẩy đúng thời điểm.',
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã gửi thông báo thử'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const _Divider(),
                    _ActionRow(
                      icon: Icons.info_outline,
                      label: 'Về Kanban Cá Nhân',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Kanban Cá Nhân',
                          applicationVersion: '1.0.0',
                          applicationIcon: const Icon(
                            Icons.view_kanban_rounded,
                            size: 36,
                            color: GlassPalette.primary,
                          ),
                          children: const [
                            Text(
                              'Ứng dụng quản lý công việc cá nhân theo mô '
                              'hình Kanban, đồng bộ Supabase hoặc dùng cục bộ.',
                            ),
                          ],
                        );
                      },
                    ),
                    const _Divider(),
                    _ActionRow(
                      icon: Icons.logout,
                      label: 'Đăng xuất',
                      color: Colors.red,
                      onTap: _confirmSignOut,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _providerLabel(String? provider) {
    switch (provider) {
      case 'google':
        return 'Google';
      case 'email':
        return 'Email & mật khẩu';
      case null:
      case '':
        return 'Email & mật khẩu';
      default:
        return provider;
    }
  }

  static String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final d = DateTime.parse(iso).toLocal();
      return '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/'
          '${d.year}';
    } catch (_) {
      return '—';
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: GlassPalette.primary,
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  final bool isGuest;
  const _ModeBadge({required this.isGuest});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isGuest ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isGuest
              ? Colors.orange.withValues(alpha: 0.5)
              : Colors.green.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGuest ? Icons.smartphone : Icons.cloud_done,
            size: 14,
            color: isGuest ? Colors.orange[800] : Colors.green[800],
          ),
          const SizedBox(width: 6),
          Text(
            isGuest ? 'Cục bộ (chỉ máy này)' : 'Đã đồng bộ Cloud',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isGuest ? Colors.orange[900] : Colors.green[800],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: GlassPalette.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: GlassPalette.onSurface,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: GlassPalette.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fg = color ?? GlassPalette.onSurface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: GlassPalette.outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: GlassPalette.outlineVariant.withValues(alpha: 0.3),
      ),
    );
  }
}
