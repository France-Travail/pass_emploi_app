import 'dart:math';

/// Pause imposée aux refresh après un refus temporaire de connect (rate limit, erreur serveur).
///
/// La première pause dure la fenêtre du rate limit, les suivantes doublent jusqu'à un plafond.
/// On ajoute un délai aléatoire, jamais négatif pour ne pas revenir avant la fin de la fenêtre :
/// la limite de connect est par IP, les apps derrière la même IP ne doivent pas revenir ensemble.
class TokenRefreshPause {
  static const _maxPause = Duration(minutes: 5);
  static const _maxJitterRatio = 0.25;
  static const _maxDoublings = 10;

  final Duration Function() _firstPause;
  final Random _random;
  int _consecutiveRefusals = 0;
  DateTime? _endsAt;

  TokenRefreshPause({required this._firstPause, Random? random})
    : _random = random ?? Random();

  /// Fin de la pause en cours, ou null si on peut retenter.
  DateTime? activeUntil(DateTime now) {
    final endsAt = _endsAt;
    return endsAt != null && now.isBefore(endsAt) ? endsAt : null;
  }

  /// Démarre une pause après un refus et renvoie sa fin.
  DateTime start(DateTime now) {
    final firstPause = _firstPause();
    final maxPause = firstPause > _maxPause ? firstPause : _maxPause;
    final doubledPause =
        firstPause * (1 << min(_consecutiveRefusals, _maxDoublings));
    final pause = doubledPause > maxPause ? maxPause : doubledPause;
    final jitter = pause * (_random.nextDouble() * _maxJitterRatio);
    _consecutiveRefusals++;
    return _endsAt = now.add(pause + jitter);
  }

  void reset() {
    _consecutiveRefusals = 0;
    _endsAt = null;
  }
}
