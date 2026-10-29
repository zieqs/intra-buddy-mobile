/// One-shot intent set before the router exists, when the app is launched by
/// tapping a notification from a fully closed state.
class StartupIntent {
  StartupIntent._();

  static bool openLogbook = false;
}
