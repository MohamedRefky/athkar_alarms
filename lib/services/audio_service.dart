import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Stream<PlayerState> get onPlayerStateChanged => _audioPlayer.onPlayerStateChanged;
  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;
  Stream<Duration> get onDurationChanged => _audioPlayer.onDurationChanged;

  bool get isPlaying => _audioPlayer.state == PlayerState.playing;

  Future<void> playAsset(String assetPath) async {
    try {
      await _audioPlayer.stop();
      // Remove 'assets/' prefix if needed for Source.asset
      final cleanPath = assetPath.startsWith('assets/')
          ? assetPath.substring(7)
          : assetPath;
      await _audioPlayer.play(AssetSource(cleanPath));
    } catch (e) {
      // Audio file playback error fallback
    }
  }

  Future<void> playCustomFile(String filePath) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(DeviceFileSource(filePath));
    } catch (e) {
      // Device file playback error fallback
    }
  }

  Future<void> playAudioForDua({
    required String assetAudio,
    String? customAudioPath,
  }) async {
    if (customAudioPath != null && customAudioPath.isNotEmpty) {
      await playCustomFile(customAudioPath);
    } else {
      await playAsset(assetAudio);
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
