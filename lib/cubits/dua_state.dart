import 'package:equatable/equatable.dart';
import '../models/dua_model.dart';
import '../models/audio_azkar_model.dart';

class DuaState extends Equatable {
  final List<DuaModel> duas;
  final List<AudioAzkarModel> audioAzkar;
  final DuaModel? currentDua;
  final AudioAzkarModel? currentAudioAzkar;
  final bool isLoading;
  final bool isPlayingAudio;
  final Duration audioPosition;
  final Duration audioDuration;
  final String? errorMessage;

  const DuaState({
    this.duas = const [],
    this.audioAzkar = const [],
    this.currentDua,
    this.currentAudioAzkar,
    this.isLoading = false,
    this.isPlayingAudio = false,
    this.audioPosition = Duration.zero,
    this.audioDuration = Duration.zero,
    this.errorMessage,
  });

  DuaState copyWith({
    List<DuaModel>? duas,
    List<AudioAzkarModel>? audioAzkar,
    DuaModel? currentDua,
    AudioAzkarModel? currentAudioAzkar,
    bool? isLoading,
    bool? isPlayingAudio,
    Duration? audioPosition,
    Duration? audioDuration,
    String? errorMessage,
  }) {
    return DuaState(
      duas: duas ?? this.duas,
      audioAzkar: audioAzkar ?? this.audioAzkar,
      currentDua: currentDua ?? this.currentDua,
      currentAudioAzkar: currentAudioAzkar ?? this.currentAudioAzkar,
      isLoading: isLoading ?? this.isLoading,
      isPlayingAudio: isPlayingAudio ?? this.isPlayingAudio,
      audioPosition: audioPosition ?? this.audioPosition,
      audioDuration: audioDuration ?? this.audioDuration,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        duas,
        audioAzkar,
        currentDua,
        currentAudioAzkar,
        isLoading,
        isPlayingAudio,
        audioPosition,
        audioDuration,
        errorMessage,
      ];
}
