import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstLaunchNotifier extends Notifier<AsyncValue<bool>> {
  static const String _firstLaunchKey = 'first_launch_completed';

  @override
  AsyncValue<bool> build() {
    return const AsyncValue.loading();
  }

  Future<void> initialize() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = !(prefs.getBool(_firstLaunchKey) ?? false);
      state = AsyncValue.data(isFirstLaunch);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> markFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, true);
    state = const AsyncValue.data(false);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firstLaunchKey);
    state = const AsyncValue.data(true);
  }
}

final firstLaunchProvider = NotifierProvider<FirstLaunchNotifier, AsyncValue<bool>>(FirstLaunchNotifier.new);

final isFirstLaunchProvider = Provider<bool>((ref) {
  final firstLaunchAsync = ref.watch(firstLaunchProvider);
  return firstLaunchAsync.maybeWhen(data: (value) => value, orElse: () => false);
});
