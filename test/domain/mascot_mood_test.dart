import 'package:flutter_test/flutter_test.dart';
import 'package:lung_buddy/domain/mascot_mood.dart';
import 'package:lung_buddy/domain/models.dart';

void main() {
  test('zero smokes early → happy', () {
    expect(
      MascotMoodLogic.fromToday(smokeCount: 0, budget: 10, nowHour: 9),
      MascotMood.happy,
    );
  });

  test('under half budget → chill', () {
    expect(
      MascotMoodLogic.fromToday(smokeCount: 3, budget: 10, nowHour: 14),
      MascotMood.chill,
    );
  });

  test('near budget → worried', () {
    expect(
      MascotMoodLogic.fromToday(smokeCount: 9, budget: 10, nowHour: 18),
      MascotMood.worried,
    );
  });

  test('over budget → worried (never shame state)', () {
    expect(
      MascotMoodLogic.fromToday(smokeCount: 12, budget: 10, nowHour: 20),
      MascotMood.worried,
    );
  });

  test('celebrate when yesterday won and today still under', () {
    expect(
      MascotMoodLogic.fromToday(
        smokeCount: 1,
        budget: 10,
        nowHour: 10,
        yesterdayWon: true,
      ),
      MascotMood.celebrate,
    );
  });
}
