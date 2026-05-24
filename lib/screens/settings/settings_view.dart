import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/audio_service.dart';
import '../../services/persistence_service.dart';
import '../../state/browser_state.dart';
import '../../state/chapter_state.dart';
import '../../state/ending_state.dart';
import '../../state/files_state.dart';
import '../../state/messages_state.dart';
import '../../state/notes_state.dart';
import '../../state/notifications_state.dart';
import '../../state/phone_state.dart';
import '../../state/photos_state.dart';
import '../../widgets/status_bar.dart';

/// Mostly cosmetic Settings app. The one functional control is the
/// "Resetuj rozgrywkę" button at the bottom which wipes prefs and resets
/// every state notifier so the demo can be replayed cleanly.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          children: [
            const StatusBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF0A84FF), size: 22),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Ustawienia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const _SectionLabel(text: 'OGÓLNE'),
                  _SettingsGroup(rows: [
                    _SettingsRow(
                      icon: Icons.airplanemode_active,
                      iconBg: const Color(0xFFFF9500),
                      label: 'Tryb samolotowy',
                      trailing: const _Toggle(value: false),
                      onTap: () => _showSettingFeedback(context, 'Tryb samolotowy jest wyłączony'),
                    ),
                    _SettingsRow(
                      icon: Icons.wifi,
                      iconBg: const Color(0xFF0A84FF),
                      label: 'Wi-Fi',
                      value: 'HB_Guest_5G',
                      onTap: () => _showSettingFeedback(context, 'Połączono z: HB_Guest_5G (nieszyfrowane)'),
                    ),
                    _SettingsRow(
                      icon: Icons.bluetooth,
                      iconBg: const Color(0xFF0A84FF),
                      label: 'Bluetooth',
                      value: 'Wyłączony',
                      onTap: () => _showSettingFeedback(context, 'Bluetooth jest wyłączony'),
                    ),
                    _SettingsRow(
                      icon: Icons.signal_cellular_alt,
                      iconBg: const Color(0xFF34C759),
                      label: 'Komórkowe',
                      value: 'Brak zasięgu',
                      onTap: () => _showSettingFeedback(context, 'Brak karty SIM lub zasięgu'),
                    ),
                    _SettingsRow(
                      icon: Icons.volume_off,
                      iconBg: const Color(0xFFFF2D55),
                      label: 'Wycisz dźwięki',
                      trailing: _MuteToggle(),
                    ),
                    _SettingsRow(
                      icon: Icons.notifications,
                      iconBg: const Color(0xFFFF453A),
                      label: 'Powiadomienia',
                      value: 'Włączone',
                      onTap: () => _showSettingFeedback(context, 'Nie można zmienić ustawień powiadomień'),
                    ),
                    _SettingsRow(
                      icon: Icons.lock,
                      iconBg: const Color(0xFF34C759),
                      label: 'Kod i Face ID',
                      onTap: () => _showSettingFeedback(context, 'Wymagane uwierzytelnienie właściciela'),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  const _SectionLabel(text: 'INFORMACJE'),
                  _SettingsGroup(rows: [
                    _SettingsRow(
                      icon: Icons.info_outline,
                      iconBg: const Color(0xFF8E8E93),
                      label: 'Model',
                      value: 'iPhone 15 Pro',
                      onTap: () => _showSettingFeedback(context, 'iPhone 15 Pro · 256 GB · iOS 18.4'),
                    ),
                    _SettingsRow(
                      icon: Icons.battery_full,
                      iconBg: const Color(0xFF34C759),
                      label: 'Bateria',
                      value: '${_currentBattery()}%',
                      onTap: () => _showSettingFeedback(context,
                          'Stan baterii: 89% · Ostatnie ładowanie: wczoraj 18:00'),
                    ),
                    _SettingsRow(
                      icon: Icons.storage,
                      iconBg: const Color(0xFF8E8E93),
                      label: 'Pamięć',
                      value: '47 GB / 256 GB',
                      onTap: () => _showSettingFeedback(context, 'Zdjęcia: 12 GB · Aplikacje: 28 GB · System: 7 GB'),
                    ),
                    _SettingsRow(
                      icon: Icons.person,
                      iconBg: const Color(0xFF0A84FF),
                      label: 'Właściciel',
                      value: 'N.',
                      onTap: () => _showSettingFeedback(context, 'Apple ID: n.***@icloud.com · Zalogowano'),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  const _SectionLabel(text: 'DEWELOPER'),
                  _SettingsGroup(rows: [
                    _SettingsRow(
                      icon: Icons.refresh,
                      iconBg: const Color(0xFFFF453A),
                      label: 'Resetuj rozgrywkę',
                      destructive: true,
                      onTap: () => _confirmReset(context),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Zaginiona - demo',
                      style: TextStyle(color: Colors.white24, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _currentBattery() {
    return StatusBar.currentBattery;
  }

  void _showSettingFeedback(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2C2C2E),
      ));
  }

  Future<void> _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Resetować rozgrywkę?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Wszystkie odkryte ślady, odblokowane notatki i konwersacje zostaną '
          'wymazane. Telefon zostanie ponownie zablokowany.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Anuluj',
                style: TextStyle(color: Color(0xFF0A84FF))),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Resetuj',
                style: TextStyle(color: Color(0xFFFF453A))),
          ),
        ],
      ),
    );

    if (ok != true || !context.mounted) return;

    // Clear prefs first, then reset every notifier. Order matters: ending
    // overlay reads EndingState; PhoneState.reset() flips back to lock
    // screen, which yanks the navigator back to the lock route.
    await PersistenceService.instance.clearAll();
    if (!context.mounted) return;
    await AudioService.instance.reset();
    if (!context.mounted) return;
    context.read<EndingState>().reset();
    context.read<MessagesState>().reset();
    context.read<NotesState>().reset();
    context.read<PhotosState>().reset();
    context.read<NotificationsState>().reset();
    context.read<FilesState>().reset();
    context.read<BrowserState>().reset();
    context.read<ChapterState>().reset();
    context.read<PhoneState>().reset();
  }
}

// ---------------- helpers ----------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.rows});
  final List<_SettingsRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1)
              const Padding(
                padding: EdgeInsets.only(left: 56),
                child: Divider(height: 1, color: Color(0xFF2C2C2E)),
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconBg,
    required this.label,
    this.value,
    this.trailing,
    this.destructive = false,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final String label;
  final String? value;
  final Widget? trailing;
  final bool destructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? const Color(0xFFFF453A) : Colors.white;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: color, fontSize: 15),
              ),
            ),
            if (value != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  value!,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            if (trailing != null) trailing!,
            if (onTap != null && trailing == null && value == null)
              const Icon(Icons.chevron_right,
                  color: Colors.white24, size: 18),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.value});
  final bool value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 26,
      decoration: BoxDecoration(
        color: value ? const Color(0xFF34C759) : const Color(0xFF3A3A3C),
        borderRadius: BorderRadius.circular(13),
      ),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _MuteToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final muted = context.watch<AudioService>().isMuted;
    return GestureDetector(
      onTap: () => context.read<AudioService>().toggleMute(),
      child: Container(
        width: 42,
        height: 26,
        decoration: BoxDecoration(
          color: muted ? const Color(0xFF34C759) : const Color(0xFF3A3A3C),
          borderRadius: BorderRadius.circular(13),
        ),
        alignment: muted ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
