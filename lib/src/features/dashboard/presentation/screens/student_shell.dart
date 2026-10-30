import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:intra_buddy_mobile_v2/src/app/theme/app_colors.dart';
import 'package:intra_buddy_mobile_v2/src/app/ui/buddy_dock.dart';
import 'package:intra_buddy_mobile_v2/src/core/providers/tab_index_provider.dart';

class StudentShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const StudentShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBranch = navigationShell.currentIndex;
    final tabNotifier = ref.read(currentTabIndexProvider.notifier);
    if (tabNotifier.currentValue != currentBranch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        tabNotifier.setIndex(currentBranch);
      });
    }

    return Scaffold(
      backgroundColor: context.page,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: BuddyDock(
          currentIndex: currentBranch,
          onSelected: (index) => navigationShell.goBranch(index),
        ),
      ),
    );
  }
}
