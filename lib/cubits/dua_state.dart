import 'package:equatable/equatable.dart';
import '../models/dua_model.dart';

class DuaState extends Equatable {
  final List<DuaModel> duas;
  final DuaModel? currentDua;
  final bool isLoading;
  final bool isPlayingAudio;
  final Duration audioPosition;
  final Duration audioDuration;
  final String? errorMessage;

  const DuaState({
    this.duas = const [],
    this.currentDua,
    this.isLoading = false,
    this.isPlayingAudio = false,
    this.audioPosition = Duration.zero,
    this.audioDuration = Duration.zero,
    this.errorMessage,
  });

  DuaState copyWith({
    List<DuaModel>? duas,
    DuaModel? currentDua,
    bool? isLoading,
    bool? isPlayingAudio,
    Duration? audioPosition,
    Duration? audioDuration,
    String? errorMessage,
  }) {
    return DuaState(
      duas: duas ?? this.duas,
      currentDua: currentDua ?? this.currentDua,
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
        currentDua,
        isLoading,
        isPlayingAudio,
        audioPosition,
        audioDuration,
        errorMessage,
      ];
}
