import 'package:flutter/material.dart';

import 'journal/journal_screen.dart';
import 'progress/progress_screen.dart';
import 'settings/settings_screen.dart';
import 'timetable/timetable_screen.dart';
import 'today/today_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [
    TodayScreen(),
    TimetableScreen(),
    JournalScreen(),
    ProgressScreen(),
    SettingsScreen(),
  ];

  static const _destinations = [
    _Destination(
      icon: Icons.today_outlined,
      selectedIcon: Icons.today,
      label: 'Today',
    ),
    _Destination(
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
      label: 'Timetable',
    ),
    _Destination(
      icon: Icons.book_outlined,
      selectedIcon: Icons.book,
      label: 'Journal',
    ),
    _Destination(
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
      label: 'Progress',
    ),
    _Destination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 600;
        return Scaffold(
          body: Row(
            children: [
              if (wide)
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Icon(
                      Icons.school,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  destinations: [
                    for (final d in _destinations)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ),
                  ],
                ),
              if (wide) const VerticalDivider(width: 1, thickness: 1),
              Expanded(child: _pages[_index]),
            ],
          ),
          bottomNavigationBar: wide ? null : _bottomBar(),
        );
      },
    );
  }

  NavigationBar _bottomBar() {
    return NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      destinations: [
        for (final d in _destinations)
          NavigationDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: d.label,
          ),
      ],
    );
  }
}

class _Destination {
  const _Destination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
