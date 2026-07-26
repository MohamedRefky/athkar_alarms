import 'package:equatable/equatable.dart';
import '../models/settings_model.dart';

class SettingsState extends Equatable {
  final SettingsModel settings;
  final bool isSaving;
  final String? message;

  const SettingsState({
    required this.settings,
    this.isSaving = false,
    this.message,
  });

  SettingsState copyWith({
    SettingsModel? settings,
    bool? isSaving,
    String? message,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isSaving: isSaving ?? this.isSaving,
      message: message,
    );
  }

  @override
  List<Object?> get props => [settings, isSaving, message];
}
