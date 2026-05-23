import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Centralised audio manager for the game.
///
/// Handles three layers:
/// 1. **Ambient** — a looping background drone/atmosphere track.
/// 2. **SFX** — short one-shot sounds (notification ping, keypad click,
///    lock success, glitch burst).
/// 3. **Tension** — a secondary loop that fades in during high-stress
///    moments (Sheriff sequence).
///
/// All paths are relative to `assets/audio/`. If a file is missing the
/// player silently fails — the game works without audio assets.
class AudioService extends ChangeNotifier {
  AudioService() {
    _ambientPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
    _tensionPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
    _sfxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.release);
  }

  static AudioService? _instance;
  static AudioService get instance => _instance ??= AudioService();

  late final AudioPlayer _ambientPlayer;
  late final AudioPlayer _tensionPlayer;
  late final AudioPlayer _sfxPlayer;

  bool _muted = false;
  bool get isMuted => _muted;

  final double _ambientVolume = 0.3;
  double _tensionVolume = 0.0;
  final double _sfxVolume = 0.7;

  // ─── Ambient ───────────────────────────────────────────────

  /// Start the ambient loop. Call once after unlock or on app start.
  Future<void> startAmbient() async {
    if (_muted) return;
    try {
      await _ambientPlayer.setVolume(_ambientVolume);
      await _ambientPlayer.play(AssetSource('audio/ambient_drone.wav'));
    } catch (_) {
      // Asset missing — silent fail.
    }
  }

  Future<void> stopAmbient() async {
    await _ambientPlayer.stop();
  }

  // ─── Tension ───────────────────────────────────────────────

  /// Fade in the tension track (Sheriff sequence).
  Future<void> startTension() async {
    if (_muted) return;
    try {
      _tensionVolume = 0.0;
      await _tensionPlayer.setVolume(0);
      await _tensionPlayer.play(AssetSource('audio/tension_loop.wav'));
      // Gradual fade-in over ~2 seconds.
      for (var i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        _tensionVolume = (i / 10) * 0.5;
        await _tensionPlayer.setVolume(_tensionVolume);
      }
    } catch (_) {
      // Asset missing — silent fail.
    }
  }

  /// Fade out and stop the tension track.
  Future<void> stopTension() async {
    for (var i = 10; i >= 0; i--) {
      _tensionVolume = (i / 10) * 0.5;
      await _tensionPlayer.setVolume(_tensionVolume);
      await Future.delayed(const Duration(milliseconds: 100));
    }
    await _tensionPlayer.stop();
  }

  // ─── SFX ───────────────────────────────────────────────────

  /// Play a one-shot sound effect.
  Future<void> playSfx(GameSfx sfx) async {
    if (_muted) return;
    try {
      await _sfxPlayer.setVolume(_sfxVolume);
      await _sfxPlayer.play(AssetSource(sfx.path));
    } catch (_) {
      // Asset missing — silent fail.
    }
  }

  // ─── Controls ──────────────────────────────────────────────

  void toggleMute() {
    _muted = !_muted;
    if (_muted) {
      _ambientPlayer.setVolume(0);
      _tensionPlayer.setVolume(0);
      _sfxPlayer.setVolume(0);
    } else {
      _ambientPlayer.setVolume(_ambientVolume);
      _tensionPlayer.setVolume(_tensionVolume);
      _sfxPlayer.setVolume(_sfxVolume);
    }
    notifyListeners();
  }

  void setMuted(bool value) {
    if (_muted == value) return;
    toggleMute();
  }

  /// Stop everything and release resources.
  Future<void> disposeAll() async {
    await _ambientPlayer.dispose();
    await _tensionPlayer.dispose();
    await _sfxPlayer.dispose();
  }

  /// Reset audio state (on game reset).
  Future<void> reset() async {
    await _ambientPlayer.stop();
    await _tensionPlayer.stop();
    await _sfxPlayer.stop();
    _tensionVolume = 0;
  }
}

/// All sound effects used in the game.
enum GameSfx {
  notification('audio/sfx_notification.wav'),
  keypadTap('audio/sfx_keypad_tap.wav'),
  keypadError('audio/sfx_keypad_error.wav'),
  unlockSuccess('audio/sfx_unlock.wav'),
  glitchBurst('audio/sfx_glitch.wav'),
  messageReceived('audio/sfx_message.wav'),
  endingReveal('audio/sfx_ending.wav');

  const GameSfx(this.path);
  final String path;
}
