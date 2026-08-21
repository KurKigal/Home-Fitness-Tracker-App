import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/app_settings.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/neu_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        Text('Ayarlar', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 6),
        Text(
          'Uygulama ve antrenman tercihlerin',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 30),

        _SectionTitle(title: 'Görünüm'),

        const SizedBox(height: 12),

        NeuCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SettingHeader(
                icon: Icons.palette_outlined,
                title: 'Tema',
                subtitle: 'Uygulamanın görünümünü seç.',
              ),
              const SizedBox(height: 20),
              _ThemeSelector(
                value: settings.themeMode,
                onChanged: (value) {
                  ref.read(appSettingsProvider.notifier).setThemeMode(value);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        _SectionTitle(title: 'Hatırlatıcı'),

        const SizedBox(height: 12),

        NeuCard(
          child: Column(
            children: [
              _NotificationSwitch(settings: settings),
              if (settings.notificationsEnabled) ...[
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                _ReminderTimeTile(settings: settings),
              ],
            ],
          ),
        ),

        const SizedBox(height: 30),

        _SectionTitle(title: 'Program'),

        const SizedBox(height: 12),

        NeuCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SettingHeader(
                icon: Icons.calendar_month_rounded,
                title: 'Antrenman Programı',
                subtitle: 'Eylül 2026 başlangıç programı ve devam eden döngü.',
              ),
              const SizedBox(height: 22),
              const _ProgramRow(label: 'Başlangıç', value: '1 Eylül 2026'),
              const SizedBox(height: 14),
              const _ProgramRow(
                label: 'İlk dönem',
                value: 'Eylül 2026 – Ocak 2027',
              ),
              const SizedBox(height: 14),
              const _ProgramRow(
                label: 'Devam',
                value: '4 haftalık sürekli döngü',
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.all_inclusive_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Program Ocak 2027 sonunda bitmez. '
                        'Sonrasında Kuvvet A, Easy Run, Kuvvet B, '
                        'dinlenme, kalite koşusu, Kuvvet C ve '
                        'Long Run döngüsü devam eder.',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        _SectionTitle(title: 'Uygulama'),

        const SizedBox(height: 12),

        NeuCard(
          child: Column(
            children: [
              const _InfoTile(
                icon: Icons.cloud_off_rounded,
                title: 'Tamamen Yerel',
                subtitle:
                    'Antrenman ve ayar verileri yalnızca bu cihazda tutulur.',
              ),
              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 18),
              const _InfoTile(
                icon: Icons.person_outline_rounded,
                title: 'Kişisel Kullanım',
                subtitle:
                    'Hesap, giriş veya bulut senkronizasyonu kullanılmaz.',
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        Center(
          child: Text(
            'Home Fitness Tracker',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 17),
    );
  }
}

class _SettingHeader extends StatelessWidget {
  const _SettingHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.35,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'system',
          icon: Icon(Icons.settings_suggest_outlined),
          label: Text('Sistem'),
        ),
        ButtonSegment(
          value: 'light',
          icon: Icon(Icons.light_mode_outlined),
          label: Text('Açık'),
        ),
        ButtonSegment(
          value: 'dark',
          icon: Icon(Icons.dark_mode_outlined),
          label: Text('Koyu'),
        ),
      ],
      selected: {value},
      onSelectionChanged: (selection) {
        if (selection.isEmpty) {
          return;
        }

        onChanged(selection.first);
      },
      showSelectedIcon: false,
    );
  }
}

class _NotificationSwitch extends ConsumerWidget {
  const _NotificationSwitch({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Antrenman Hatırlatıcısı',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 4),
              Text(
                settings.notificationsEnabled
                    ? 'Hatırlatıcı açık'
                    : 'Hatırlatıcı kapalı',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: settings.notificationsEnabled,
          onChanged: (value) {
            ref
                .read(appSettingsProvider.notifier)
                .setNotificationsEnabled(value);
          },
        ),
      ],
    );
  }
}

class _ReminderTimeTile extends ConsumerWidget {
  const _ReminderTimeTile({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = TimeOfDay(
      hour: settings.reminderHour,
      minute: settings.reminderMinute,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final selected = await showTimePicker(
          context: context,
          initialTime: time,
        );

        if (selected == null) {
          return;
        }

        ref
            .read(appSettingsProvider.notifier)
            .setReminderTime(hour: selected.hour, minute: selected.minute);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.schedule_rounded, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Hatırlatma Saati',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              _formatTime(settings.reminderHour, settings.reminderMinute),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  String _formatTime(int hour, int minute) {
    final formattedHour = hour.toString().padLeft(2, '0');

    final formattedMinute = minute.toString().padLeft(2, '0');

    return '$formattedHour:$formattedMinute';
  }
}

class _ProgramRow extends StatelessWidget {
  const _ProgramRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.55),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 23),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
