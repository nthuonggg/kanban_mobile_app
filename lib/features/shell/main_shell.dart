import 'package:flutter/material.dart';

import '../../core/widgets/glass_bottom_nav.dart';
import '../kanban/presentation/kanban_board_screen.dart';
import '../profile/profile_screen.dart';
import '../stats/stats_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _pages = [
    KanbanBoardScreen(),
    StatsScreen(),
    ProfileScreen(),
  ];

  static const _items = [
    GlassBottomNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Bảng',
    ),
    GlassBottomNavItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics_rounded,
      label: 'Hoạt động',
    ),
    GlassBottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
      label: 'Hồ sơ',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          IndexedStack(index: _index, children: _pages),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassBottomNav(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              items: _items,
            ),
          ),
        ],
      ),
    );
  }
}
