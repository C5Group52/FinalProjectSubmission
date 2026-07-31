import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Selected bottom-nav tab index for [HomeShell]. Kept in Riverpod (not
/// screen-local `setState`) so other screens — e.g. the dashboard's
/// "See all" jobs link — can switch tabs programmatically.
final shellTabIndexProvider = NotifierProvider<ShellTabIndexController, int>(
  ShellTabIndexController.new,
);

class ShellTabIndexController extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}