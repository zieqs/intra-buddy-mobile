import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BuddyScaffold extends StatelessWidget {
  const BuddyScaffold({
    super.key,
    required this.slivers,
    this.topBar,
    this.header,
    this.onRefresh,
  });

  final List<Widget> slivers;
  final Widget? topBar;
  final Widget? header;
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final header = this.header;
                  return Column(
                    children: [
                      if (header != null)
                        ConstrainedBox(
                          // The hero is normally fixed. On very large text
                          // scales it scrolls internally instead of squeezing
                          // the journey out of the screen.
                          constraints: BoxConstraints(
                            maxHeight: constraints.maxHeight * 0.6,
                          ),
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: header,
                          ),
                        ),
                      Expanded(
                        child: onRefresh == null
                            ? scroll
                            : RefreshIndicator(
                                onRefresh: onRefresh!,
                                child: scroll,
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
