import 'package:flutter/widgets.dart';

/// Shared root navigator key so services outside the widget tree (notification
/// taps) can navigate through the app router.
final GlobalKey<NavigatorState> appRootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
