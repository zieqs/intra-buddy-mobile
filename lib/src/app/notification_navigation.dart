import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Opens the Logbook tab from a local-notification tap.
///
/// The logbook lives in a [StatefulShellRoute] branch, so this must switch
/// branches with `go`; `push` would add a second copy of the shell.
void openLogbookFromNotification(GlobalKey<NavigatorState> navigatorKey) {
  final context = navigatorKey.currentContext;
  if (context == null) return;
  GoRouter.of(context).go('/logbook');
}
