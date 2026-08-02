import 'package:flutter_test/flutter_test.dart';
import 'package:azkar/models/dua_model.dart';
import 'package:azkar/models/settings_model.dart';
import 'package:azkar/models/audio_azkar_model.dart';

void main() {
  group('DuaModel Tests', () {
    test('Should interpolate mother name correctly when provided', () {
      const dua = DuaModel(
        id: 1,
        text: 'اللهم اغفر لـ {mother_name} وارحمها',
        audio: 'assets/audio/audio1.mp3',
      );

      final formatted = dua.getFormattedText('أمي الغالية');
      expect(formatted, equals('اللهم اغفر لـ أمي الغالية وارحمها'));
    });

    test('Should fallback to "المتوفى" when mother name is empty', () {
      const dua = DuaModel(
        id: 1,
        text: 'اللهم اغفر لـ {mother_name} وارحمها',
        audio: 'assets/audio/audio1.mp3',
      );

      final formatted = dua.getFormattedText('  ');
      expect(formatted, equals('اللهم اغفر لـ المتوفى وارحمها'));
    });
  });

  group('AudioAzkarModel Tests', () {
    test('Should parse audio azkar json correctly', () {
      final json = {
        'id': 1,
        'title': 'مقطع صوتي 1',
        'audio': 'assets/audio/audio1.mp3',
        'soundName': 'audio1',
      };
      final item = AudioAzkarModel.fromJson(json);
      expect(item.id, equals(1));
      expect(item.title, equals('مقطع صوتي 1'));
      expect(item.soundName, equals('audio1'));
    });
  });

  group('SettingsModel Tests', () {
    test('Should default to 3 hours text interval and 6 hours audio interval', () {
      const settings = SettingsModel();
      expect(settings.textFrequency, NotificationFrequency.every3Hours);
      expect(settings.getEffectiveTextIntervalMinutes(), equals(180));
      expect(settings.getEffectiveAudioIntervalMinutes(), equals(360));
    });
  });
}
