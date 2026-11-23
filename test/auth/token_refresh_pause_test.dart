import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/auth/token_refresh_pause.dart';

void main() {
  final now = DateTime(2026, 11, 20, 10);

  TokenRefreshPause pause({
    Duration firstPause = const Duration(seconds: 60),
    double jitter = 0,
  }) {
    return TokenRefreshPause(
      firstPause: () => firstPause,
      random: _FixedRandom(jitter),
    );
  }

  test("aucune pause tant qu'aucun refus n'a eu lieu", () {
    expect(pause().activeUntil(now), isNull);
  });

  test("la pause est active jusqu'à sa fin, puis plus du tout", () {
    // Given
    final sut = pause();

    // When
    final end = sut.start(now);

    // Then
    expect(end, now.add(Duration(seconds: 60)));
    expect(sut.activeUntil(now.add(Duration(seconds: 59))), end);
    expect(sut.activeUntil(end), isNull);
  });

  test("les pauses doublent à chaque refus jusqu'à 5 minutes", () {
    // Given
    final sut = pause();

    // When
    final pauses = [for (var i = 0; i < 5; i++) sut.start(now).difference(now)];

    // Then
    expect(pauses, [
      Duration(minutes: 1),
      Duration(minutes: 2),
      Duration(minutes: 4),
      Duration(minutes: 5),
      Duration(minutes: 5),
    ]);
  });

  test("le plafond ne raccourcit jamais une première pause plus longue", () {
    expect(
      pause(firstPause: Duration(minutes: 10)).start(now),
      now.add(Duration(minutes: 10)),
    );
  });

  test("le délai aléatoire allonge la pause d'au plus 25 %", () {
    expect(pause(jitter: 1).start(now), now.add(Duration(seconds: 75)));
  });

  test("reset termine la pause et repart de la première durée", () {
    // Given
    final sut = pause();
    sut.start(now);
    sut.start(now);

    // When
    sut.reset();

    // Then
    expect(sut.activeUntil(now), isNull);
    expect(sut.start(now), now.add(Duration(seconds: 60)));
  });
}

class _FixedRandom implements Random {
  final double value;

  _FixedRandom(this.value);

  @override
  double nextDouble() => value;

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  int nextInt(int max) => throw UnimplementedError();
}
