import 'package:equatable/equatable.dart';

class DuaModel extends Equatable {
  final int id;
  final String text;
  final String audio;
  final String? customAudioPath;

  const DuaModel({
    required this.id,
    required this.text,
    required this.audio,
    this.customAudioPath,
  });

  factory DuaModel.fromJson(Map<String, dynamic> json) {
    return DuaModel(
      id: json['id'] as int,
      text: json['text'] as String,
      audio: json['audio'] as String,
      customAudioPath: json['customAudioPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'audio': audio,
      'customAudioPath': customAudioPath,
    };
  }

  DuaModel copyWith({
    int? id,
    String? text,
    String? audio,
    String? customAudioPath,
  }) {
    return DuaModel(
      id: id ?? this.id,
      text: text ?? this.text,
      audio: audio ?? this.audio,
      customAudioPath: customAudioPath ?? this.customAudioPath,
    );
  }

  String getFormattedText(String motherName) {
    final trimmed = motherName.trim();
    final name = trimmed.isNotEmpty ? trimmed : 'المتوفى';
    return text.replaceAll('{mother_name}', name);
  }

  @override
  List<Object?> get props => [id, text, audio, customAudioPath];
}
