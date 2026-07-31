import 'package:equatable/equatable.dart';

class AudioAzkarModel extends Equatable {
  final int id;
  final String title;
  final String audio;
  final String soundName;
  final String gender; // 'female' or 'male'

  const AudioAzkarModel({
    required this.id,
    required this.title,
    required this.audio,
    required this.soundName,
    this.gender = 'female',
  });

  bool get isFemale => gender == 'female';
  bool get isMale => gender == 'male';

  factory AudioAzkarModel.fromJson(Map<String, dynamic> json) {
    final audioPath = json['audio'] as String? ?? '';
    return AudioAzkarModel(
      id: json['id'] as int,
      title: json['title'] as String,
      audio: audioPath,
      soundName: json['soundName'] as String? ?? 'audio${json['id']}',
      gender: json['gender'] as String? ??
          (audioPath.contains('/man/') ? 'male' : 'female'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'audio': audio,
      'soundName': soundName,
      'gender': gender,
    };
  }

  @override
  List<Object?> get props => [id, title, audio, soundName, gender];
}
