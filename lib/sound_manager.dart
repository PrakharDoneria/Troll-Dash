import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _soundPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  
  bool _soundEnabled = true;
  bool _musicEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    if (!_soundEnabled) {
      _soundPlayer.stop();
    }
  }

  void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    if (!_musicEnabled) {
      _musicPlayer.stop();
    } else {
      playBackgroundMusic();
    }
  }

  Future<void> playJumpSound() async {
    if (!_soundEnabled) return;
    try {
      // Using a simple beep sound effect - in a real game you'd have actual audio files
      await _soundPlayer.play(AssetSource('sounds/jump.mp3'));
    } catch (e) {
      // Silently fail if sound file doesn't exist
    }
  }

  Future<void> playTrapSound() async {
    if (!_soundEnabled) return;
    try {
      await _soundPlayer.play(AssetSource('sounds/trap.mp3'));
    } catch (e) {
      // Silently fail if sound file doesn't exist
    }
  }

  Future<void> playLevelCompleteSound() async {
    if (!_soundEnabled) return;
    try {
      await _soundPlayer.play(AssetSource('sounds/level_complete.mp3'));
    } catch (e) {
      // Silently fail if sound file doesn't exist
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.play(AssetSource('music/background.mp3'));
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      // Silently fail if music file doesn't exist
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
  }

  void dispose() {
    _soundPlayer.dispose();
    _musicPlayer.dispose();
  }
}