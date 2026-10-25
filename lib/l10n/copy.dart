import '../domain/models.dart';

class Copy {
  static String mascotLine(
    MascotMood mood, {
    required int count,
    required int budget,
  }) {
    final ratio = budget <= 0 ? 0.0 : count / budget;

    if (count == 0) {
      return mood == MascotMood.celebrate
          ? 'STREAK MODE. Look at this shiny pink legend.'
          : 'Fresh. Soft. Dangerously cute.';
    }
    if (ratio <= 0.3) {
      return 'Still vibing. $count / $budget — no biggie.';
    }
    if (ratio <= 0.55) {
      return 'Getting a little grey… classic.';
    }
    if (ratio <= 0.85) {
      return 'Cough. Cough. Still cute tho.';
    }
    if (count > budget) {
      return "WHOOPS he's on fire. Tomorrow's a new cartoon.";
    }
    return 'Nearly soot. Honesty keeps the slapstick going.';
  }

  static String streakBroken() =>
      'Streak kaboom — start a silly new one tomorrow.';
}
