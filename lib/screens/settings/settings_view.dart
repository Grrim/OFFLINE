import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n_extensions.dart';
import '../../services/audio_service.dart';
import '../../services/iap_service.dart';
import '../../services/l10n_service.dart';
import '../../services/persistence_service.dart';
import '../../state/browser_state.dart';
import '../../state/chapter_state.dart';
import '../../state/email_state.dart';
import '../../state/ending_state.dart';
import '../../state/evidence_state.dart';
import '../../state/files_state.dart';
import '../../state/flags_state.dart';
import '../../state/maps_state.dart';
import '../../state/messages_state.dart';
import '../../state/new_game_plus_state.dart';
import '../../state/notes_state.dart';
import '../../state/notifications_state.dart';
import '../../state/phone_state.dart';
import '../../state/photos_state.dart';
import '../../state/recorder_state.dart';
import '../../state/settings_state.dart';
import '../../state/signal_puzzle_state.dart';
import '../../state/trust_state.dart';
import '../../widgets/fragment_hotspot.dart';
import '../../widgets/status_bar.dart';
import 'about_view.dart';

/// Settings app. Mix of:
/// - Cosmetic system rows (airplane mode, wi-fi, ...) — non-functional
///   flavor-text that respects taps with snackbar feedback.
/// - Real toggles tied to [SettingsState]: mute, reduced motion, haptics,
///   guided mode, telemetry opt-in, locale.
/// - Reset button that wipes gameplay only (preserves settings).
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
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
                  Text(
                    t.settingsTitle,
                    style: const TextStyle(
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
                  // — system flavour rows —
                  _SectionLabel(text: t.settingsSectionGeneral),
                  _SettingsGroup(rows: [
                    _SettingsRow(
                      icon: Icons.airplanemode_active,
                      iconBg: const Color(0xFFFF9500),
                      label: t.settingsFlavourAirplane,
                      trailing: const _StaticToggle(value: false),
                      onTap: () => _showSettingFeedback(
                          context, t.settingsFlavourFeedbackAirplane),
                    ),
                    _SettingsRow(
                      icon: Icons.wifi,
                      iconBg: const Color(0xFF0A84FF),
                      label: t.settingsFlavourWifi,
                      value: 'HB_Guest_5G',
                      onTap: () => _showSettingFeedback(context,
                          t.settingsFlavourFeedbackWifi),
                    ),
                    _SettingsRow(
                      icon: Icons.bluetooth,
                      iconBg: const Color(0xFF0A84FF),
                      label: t.settingsFlavourBluetooth,
                      value: t.settingsFlavourValueBluetoothOff,
                      onTap: () => _showSettingFeedback(
                          context, t.settingsFlavourFeedbackBluetooth),
                    ),
                    _SettingsRow(
                      icon: Icons.signal_cellular_alt,
                      iconBg: const Color(0xFF34C759),
                      label: t.settingsFlavourCellular,
                      value: t.settingsFlavourValueCellNoSignal,
                      onTap: () => _showSettingFeedback(
                          context, t.settingsFlavourFeedbackCellular),
                    ),
                    _SettingsRow(
                      icon: Icons.notifications,
                      iconBg: const Color(0xFFFF453A),
                      label: t.settingsFlavourNotifications,
                      value: t.settingsFlavourValueEnabled,
                      onTap: () => _showSettingFeedback(context,
                          t.settingsFlavourFeedbackNotifications),
                    ),
                    _SettingsRow(
                      icon: Icons.lock,
                      iconBg: const Color(0xFF34C759),
                      label: t.settingsFlavourPasscode,
                      onTap: () => _showSettingFeedback(context,
                          t.settingsFlavourFeedbackPasscode),
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // — reset (MOVED UP) —
                  _SettingsGroup(rows: [
                    _SettingsRow(
                      icon: Icons.refresh,
                      iconBg: const Color(0xFFFF453A),
                      label: t.settingsResetGame,
                      sub: t.settingsResetGameSub,
                      destructive: true,
                      onTap: () => _confirmReset(context),
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // — language —
                  _SectionLabel(text: t.settingsSectionLanguage),
                  _SettingsGroup(rows: [
                    _SettingsRow(
                      icon: Icons.language,
                      iconBg: const Color(0xFF5AC8FA),
                      label: t.settingsLanguage,
                      value: _getLanguageLabel(t, L10nService.instance.locale.languageCode),
                      onTap: () => _pickLanguage(context),
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // — real game settings —
                  _SectionLabel(text: t.settingsSectionGame),
                  _SettingsGroup(rows: [
                    _SettingsRow(
                      icon: Icons.restore,
                      iconBg: const Color(0xFF5856D6),
                      label: t.iapRestore,
                      onTap: () async {
                        try {
                          await IapService.instance.restorePurchases();
                          if (context.mounted) {
                            _showSettingFeedback(context, t.settingsFlavourFeedbackIapAttempt);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            _showSettingFeedback(context, t.settingsFlavourFeedbackIapError);
                          }
                        }
                      },
                    ),
                    _SettingsRow(
                      icon: Icons.volume_off,
                      iconBg: const Color(0xFFFF2D55),
                      label: t.settingsAudioMute,
                      sub: t.settingsAudioMuteSub,
                      trailing: _BoundToggle(
                        get: (s) => s.audioMuted,
                        set: (s, v) => s.setAudioMuted(v),
                      ),
                    ),
                    _SettingsRow(
                      icon: Icons.flash_off,
                      iconBg: const Color(0xFF8E8E93),
                      label: t.settingsReducedMotion,
                      sub: t.settingsReducedMotionSub,
                      trailing: _BoundToggle(
                        get: (s) => s.reducedMotion,
                        set: (s, v) => s.setReducedMotion(v),
                      ),
                    ),
                    _SettingsRow(
                      icon: Icons.vibration,
                      iconBg: const Color(0xFFFF9500),
                      label: t.settingsHaptics,
                      sub: t.settingsHapticsSub,
                      trailing: _BoundToggle(
                        get: (s) => s.haptics,
                        set: (s, v) => s.setHaptics(v),
                      ),
                    ),
                    _SettingsRow(
                      icon: Icons.lightbulb_outline,
                      iconBg: const Color(0xFFFFCC00),
                      label: t.settingsGuidedMode,
                      sub: t.settingsGuidedModeSub,
                      trailing: _BoundToggle(
                        get: (s) => s.guidedMode,
                        set: (s, v) => s.setGuidedMode(v),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // — privacy / telemetry —
                  _SectionLabel(text: t.settingsSectionPrivacy),
                  _SettingsGroup(rows: [
                    _SettingsRow(
                      icon: Icons.bug_report_outlined,
                      iconBg: const Color(0xFF8E8E93),
                      label: t.settingsTelemetry,
                      sub: t.settingsTelemetrySub,
                      trailing: _BoundToggle(
                        get: (s) => s.telemetryOptIn,
                        set: (s, v) => s.setTelemetryOptIn(v),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // — info —
                  _SectionLabel(text: t.settingsSectionInfo),
                  _SettingsGroup(rows: [
                    _SettingsRow(
                      icon: Icons.info_outline,
                      iconBg: const Color(0xFF8E8E93),
                      label: t.settingsFlavourModel,
                      value: 'iPhone 15 Pro',
                      onTap: () => _showSettingFeedback(context,
                          'iPhone 15 Pro · 256 GB · iOS 18.4'),
                    ),
                    _SettingsRow(
                      icon: Icons.battery_full,
                      iconBg: const Color(0xFF34C759),
                      label: t.settingsFlavourBattery,
                      value: t.settingsFlavourValueBattery(_currentBattery().toString()),
                      onTap: () => _showSettingFeedback(
                          context,
                          t.settingsFlavourFeedbackBattery(_currentBattery().toString())),
                    ),
                    _SettingsRow(
                      icon: Icons.storage,
                      iconBg: const Color(0xFF8E8E93),
                      label: t.settingsFlavourStorage,
                      value: t.settingsFlavourValueStorage,
                      onTap: () => _showSettingFeedback(context,
                          t.settingsFlavourFeedbackStorage),
                    ),
                    _SettingsRow(
                      icon: Icons.person,
                      iconBg: const Color(0xFF0A84FF),
                      label: t.settingsFlavourOwner,
                      value: t.settingsFlavourValueOwnerName,
                      onTap: () => _showSettingFeedback(context,
                          t.settingsFlavourFeedbackOwner),
                    ),
                    _SettingsRow(
                      icon: Icons.info,
                      iconBg: const Color(0xFFAF52DE),
                      label: t.settingsAbout,
                      sub: t.settingsFlavourAboutSub,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AboutView(),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 24),

                  const Center(
                    child: FragmentHotspot(
                      fragmentId: 'frag_sign',
                      child: Text(
                        'OFFLINE — Zaginiona',
                        style: TextStyle(
                            color: Colors.white24, fontSize: 12),
                      ),
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

  String _getLanguageLabel(dynamic t, String code) {
    switch (code) {
      case 'pl':
        return t.settingsLanguagePolish;
      case 'de':
        return 'Deutsch';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'it':
        return 'Italiano';
      case 'pt':
        return 'Português';
      case 'ru':
        return 'Русский';
      case 'en':
      default:
        return t.settingsLanguageEnglish;
    }
  }

  void _showSettingFeedback(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 13)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        elevation: 0,
      ));
  }

  Future<void> _pickLanguage(BuildContext context) async {
    final t = context.l10n;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0A0A0A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        final current = L10nService.instance.locale.languageCode;
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) => SafeArea(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                _LanguageRow(
                  label: t.settingsLanguagePolish,
                  isSelected: current == 'pl',
                  onTap: () {
                    L10nService.instance.setLocale(const Locale('pl'));
                    Navigator.of(ctx).pop();
                  },
                ),
                _LanguageRow(
                  label: t.settingsLanguageEnglish,
                  isSelected: current == 'en',
                  onTap: () {
                    L10nService.instance.setLocale(const Locale('en'));
                    Navigator.of(ctx).pop();
                  },
                ),
                _LanguageRow(
                  label: 'Deutsch',
                  isSelected: current == 'de',
                  onTap: () {
                    L10nService.instance.setLocale(const Locale('de'));
                    Navigator.of(ctx).pop();
                  },
                ),
                _LanguageRow(
                  label: 'Español',
                  isSelected: current == 'es',
                  onTap: () {
                    L10nService.instance.setLocale(const Locale('es'));
                    Navigator.of(ctx).pop();
                  },
                ),
                _LanguageRow(
                  label: 'Français',
                  isSelected: current == 'fr',
                  onTap: () {
                    L10nService.instance.setLocale(const Locale('fr'));
                    Navigator.of(ctx).pop();
                  },
                ),
                _LanguageRow(
                  label: 'Italiano',
                  isSelected: current == 'it',
                  onTap: () {
                    L10nService.instance.setLocale(const Locale('it'));
                    Navigator.of(ctx).pop();
                  },
                ),
                _LanguageRow(
                  label: 'Português',
                  isSelected: current == 'pt',
                  onTap: () {
                    L10nService.instance.setLocale(const Locale('pt'));
                    Navigator.of(ctx).pop();
                  },
                ),
                _LanguageRow(
                  label: 'Русский',
                  isSelected: current == 'ru',
                  onTap: () {
                    L10nService.instance.setLocale(const Locale('ru'));
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final t = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: Text(t.settingsResetConfirmTitle,
            style: const TextStyle(color: Colors.white)),
        content: Text(
          t.settingsResetConfirmBody,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(t.settingsResetConfirmCancel,
                style: const TextStyle(color: Color(0xFF0A84FF))),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(t.settingsResetConfirmConfirm,
                style: const TextStyle(color: Color(0xFFFF453A))),
          ),
        ],
      ),
    );

    if (ok != true || !context.mounted) return;

    try {
      HapticFeedback.heavyImpact();
      await PersistenceService.instance.clearGameState();
      if (!context.mounted) return;

      await AudioService.instance.reset();
      context.read<EndingState>().reset();
      context.read<MessagesState>().reset();
      context.read<NotesState>().reset();
      context.read<PhotosState>().reset();
      context.read<NotificationsState>().reset();
      context.read<FilesState>().reset();
      context.read<BrowserState>().reset();
      context.read<ChapterState>().reset();
      context.read<TrustState>().reset();
      context.read<EvidenceState>().reset();
      context.read<FlagsState>().reset();
      context.read<EmailState>().reset();
      context.read<RecorderState>().reset();
      context.read<MapsState>().reset();
      context.read<SignalPuzzleState>().reset();
      context.read<NewGamePlusState>().leavePlusRun();
      context.read<PhoneState>().reset();
    } catch (e) {
      debugPrint('Reset gameplay failed: $e');
    }
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
    return Material(
      color: const Color(0xFF1C1C1E),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
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
    this.sub,
    this.value,
    this.trailing,
    this.destructive = false,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final String label;
  final String? sub;
  final String? value;
  final Widget? trailing;
  final bool destructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? const Color(0xFFFF453A) : Colors.white;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (sub != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        sub!,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (value != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    value!,
                    style: const TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ),
              if (trailing != null) 
                trailing!
              else if (onTap != null)
                const Icon(Icons.chevron_right, color: Colors.white12, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Static (non-interactive) toggle for cosmetic system rows.
class _StaticToggle extends StatelessWidget {
  const _StaticToggle({required this.value});
  final bool value;

  @override
  Widget build(BuildContext context) {
    return _ToggleVisual(value: value);
  }
}

/// Interactive toggle bound to [SettingsState]. The caller provides
/// getter and setter — keeps the row widget reusable for any bool field.
class _BoundToggle extends StatelessWidget {
  const _BoundToggle({required this.get, required this.set});

  final bool Function(SettingsState) get;
  final void Function(SettingsState, bool) set;

  @override
  Widget build(BuildContext context) {
    final value = context.select<SettingsState, bool>(get);
    return GestureDetector(
      onTap: () => set(context.read<SettingsState>(), !value),
      child: _ToggleVisual(value: value),
    );
  }
}

class _ToggleVisual extends StatelessWidget {
  const _ToggleVisual({required this.value});
  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
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

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Color(0xFF0A84FF), size: 22),
          ],
        ),
      ),
    );
  }
}
