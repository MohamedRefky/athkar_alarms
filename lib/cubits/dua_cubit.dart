import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/dua_model.dart';
import '../models/audio_azkar_model.dart';
import '../services/audio_service.dart';
import '../services/preferences_service.dart';
import 'dua_state.dart';

class DuaCubit extends Cubit<DuaState> {
  final AudioService _audioService;
  final PreferencesService _prefsService;

  StreamSubscription? _playerStateSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;

  DuaCubit(this._audioService, this._prefsService) : super(const DuaState()) {
    _initAudioListeners();
  }

  void _initAudioListeners() {
    _playerStateSub = _audioService.onPlayerStateChanged.listen((playerState) {
      emit(state.copyWith(isPlayingAudio: playerState == PlayerState.playing));
    });

    _positionSub = _audioService.onPositionChanged.listen((pos) {
      emit(state.copyWith(audioPosition: pos));
    });

    _durationSub = _audioService.onDurationChanged.listen((dur) {
      emit(state.copyWith(audioDuration: dur));
    });
  }

  Future<void> loadDuas() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      // Load written duas
      final jsonString = await rootBundle.loadString('assets/duas.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final duas = jsonList.map((j) => DuaModel.fromJson(j)).toList();

      // Load audio azkar
      List<AudioAzkarModel> audioAzkar = [];
      try {
        final audioJsonString =
            await rootBundle.loadString('assets/audio_azkar.json');
        final List<dynamic> audioJsonList = jsonDecode(audioJsonString);
        audioAzkar =
            audioJsonList.map((j) => AudioAzkarModel.fromJson(j)).toList();
      } catch (_) {}

      DuaModel? initialDua;
      final lastId = _prefsService.getLastDuaId();
      if (lastId != null) {
        initialDua = duas.firstWhere(
          (d) => d.id == lastId,
          orElse: () => duas.first,
        );
      } else if (duas.isNotEmpty) {
        initialDua = duas.first;
      }

      emit(state.copyWith(
        duas: duas,
        audioAzkar: audioAzkar,
        currentDua: initialDua,
        currentAudioAzkar: audioAzkar.isNotEmpty ? audioAzkar.first : null,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'تعذر تحميل قائمة الأدعية: $e',
      ));
    }
  }

  void nextRandomDua() {
    if (state.duas.isEmpty) return;
    _audioService.stop();

    final currentId = state.currentDua?.id;
    final availableDuas = state.duas.length > 1
        ? state.duas.where((d) => d.id != currentId).toList()
        : state.duas;

    final random = Random();
    final nextDua = availableDuas[random.nextInt(availableDuas.length)];

    _prefsService.saveLastDuaId(nextDua.id);
    emit(state.copyWith(
      currentDua: nextDua,
      isPlayingAudio: false,
      audioPosition: Duration.zero,
    ));
  }

  void selectDuaById(int id,
      {bool autoPlayAudio = false, Map<int, String>? customAudioMap}) {
    if (state.duas.isEmpty) return;
    final found =
        state.duas.firstWhere((d) => d.id == id, orElse: () => state.duas.first);

    _prefsService.saveLastDuaId(found.id);
    emit(state.copyWith(
      currentDua: found,
      isPlayingAudio: false,
      audioPosition: Duration.zero,
    ));

    if (autoPlayAudio) {
      playAudio(customAudioMap: customAudioMap);
    }
  }

  Future<void> toggleAudio({Map<int, String>? customAudioMap}) async {
    if (state.isPlayingAudio) {
      await _audioService.stop();
    } else {
      await playAudio(customAudioMap: customAudioMap);
    }
  }

  Future<void> playAudio({Map<int, String>? customAudioMap}) async {
    final dua = state.currentDua;
    if (dua == null) return;

    final customPath = customAudioMap?[dua.id] ?? dua.customAudioPath;

    await _audioService.playAudioForDua(
      assetAudio: dua.audio,
      customAudioPath: customPath,
    );
  }

  Future<void> playAudioAzkarItem(AudioAzkarModel item) async {
    if (state.currentAudioAzkar?.id == item.id && state.isPlayingAudio) {
      await _audioService.stop();
      emit(state.copyWith(isPlayingAudio: false));
    } else {
      emit(state.copyWith(
        currentAudioAzkar: item,
        audioPosition: Duration.zero,
      ));
      await _audioService.playAsset(item.audio);
    }
  }

  Future<void> stopAudio() async {
    await _audioService.stop();
  }

  @override
  Future<void> close() {
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    return super.close();
  }
}
