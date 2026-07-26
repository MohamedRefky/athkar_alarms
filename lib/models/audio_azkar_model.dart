import 'package:equatable/equatable.dart';

class AudioAzkarModel extends Equatable {
  final int id;
  final String title;
  final String audio;
  final String soundName;

  const AudioAzkarModel({
    required this.id,
    required this.title,
    required this.audio,
    required this.soundName,
  });

  factory AudioAzkarModel.fromJson(Map<String, dynamic> json) {
    return AudioAzkarModel(
      id: json['id'] as int,
      title: json['title'] as String,
      audio: json['audio'] as String,
      soundName: json['soundName'] as String? ?? 'audio${json['id']}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'audio': audio,
      'soundName': soundName,
    };
  }

  @override
  List<Object?> get props => [id, title, audio, soundName];
}
