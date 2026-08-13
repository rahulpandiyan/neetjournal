import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

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
    _Destination(icon: HugeIcons.strokeRoundedCalendar01, label: 'Today'),
    _Destination(icon: HugeIcons.strokeRoundedCalendar02, label: 'Timetable'),
    _Destination(icon: HugeIcons.strokeRoundedBook01, label: 'Journal'),
    _Destination(
      icon: HugeIcons.strokeRoundedTrendingUpDown,
      label: 'Progress',
    ),
    _Destination(icon: HugeIcons.strokeRoundedSettings01, label: 'Settings'),
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
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedMortarboard01,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  destinations: [
                    for (final d in _destinations)
                      NavigationRailDestination(
                        icon: HugeIcon(icon: d.icon),
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
            icon: HugeIcon(icon: d.icon),
            label: d.label,
          ),
      ],
    );
  }
}

class _Destination {
  const _Destination({required this.icon, required this.label});

  final List<List<dynamic>> icon;
  final String label;
}
