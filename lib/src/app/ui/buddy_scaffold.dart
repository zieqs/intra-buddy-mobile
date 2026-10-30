import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BuddyScaffold extends StatelessWidget {
  const BuddyScaffold({
    super.key,
    required this.slivers,
    this.topBar,
    this.onRefresh,
  });

  final List<Widget> slivers;
  final Widget? topBar;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final scroll = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: slivers,
    );

    return Scaffold(
      backgroundColor: context.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ?topBar,
            Expanded(
              child: onRefresh == null
                  ? scroll
                  : RefreshIndicator(onRefresh: onRefresh!, child: scroll),
            ),
          ],
        ),
      ),
    );
  }
}
