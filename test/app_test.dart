import 'package:flutter_test/flutter_test.dart';
import 'package:azkar/models/dua_model.dart';
import 'package:azkar/models/settings_model.dart';

void main() {
  group('DuaModel Tests', () {
    test('Should interpolate mother name correctly when provided', () {
      const dua = DuaModel(
        id: 1,
        text: 'اللهم اغفر لـ {mother_name} وارحمها',
        audio: 'assets/audio/dua1.mp3',
      );

      final formatted = dua.getFormattedText('صباح عجمي');
      expect(formatted, equals('اللهم اغفر لـ صباح عجمي وارحمها'));
    });

    test('Should fallback to "أمي" when mother name is empty', () {
      const dua = DuaModel(
        id: 1,
        text: 'اللهم اغفر لـ {mother_name} وارحمها',
        audio: 'assets/audio/dua1.mp3',
      );

      final formatted = dua.getFormattedText('  ');
      expect(formatted, equals('اللهم اغفر لـ أمي وارحمها'));
    });
  });

  group('SettingsModel Tests', () {
    test('Should default to 3 hours interval', () {
      const settings = SettingsModel();
      expect(settings.frequency, NotificationFrequency.every3Hours);
      expect(settings.effectiveIntervalMinutes, equals(180));
    });

    test('Should return custom interval when frequency is custom', () {
      const settings = SettingsModel(
        frequency: NotificationFrequency.custom,
        customIntervalMinutes: 45,
      );
      expect(settings.effectiveIntervalMinutes, equals(45));
    });
  });
}
