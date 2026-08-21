import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/shell/home_shell.dart';
import 'providers/app_providers.dart';

class FitnessApp extends ConsumerWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Workout',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeModeFromSetting(settings.themeMode),
      home: const _NotificationBootstrap(),
    );
  }

  ThemeMode _themeModeFromSetting(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}

class _NotificationBootstrap extends ConsumerStatefulWidget {
  const _NotificationBootstrap();

  @override
  ConsumerState<_NotificationBootstrap> createState() =>
      _NotificationBootstrapState();
}

class _NotificationBootstrapState
    extends ConsumerState<_NotificationBootstrap> {
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapNotifications();
    });
  }

  Future<void> _bootstrapNotifications() async {
    if (_bootstrapped) {
      return;
    }

    _bootstrapped = true;

    final settings = ref.read(appSettingsProvider);

    if (!settings.notificationsEnabled) {
      return;
    }

    final notificationService = ref.read(notificationServiceProvider);

    final granted = await notificationService.requestPermission();

    if (!mounted) {
      return;
    }

    if (!granted) {
      await ref
          .read(appSettingsProvider.notifier)
          .setNotificationsEnabled(false);

      return;
    }

    await notificationService.syncSchedule(
      repository: ref.read(workoutRepositoryProvider),
      settings: settings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const HomeShell();
  }
}
