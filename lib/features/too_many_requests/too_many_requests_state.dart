import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/redux/app_state.dart';

class TooManyRequestsState extends Equatable {
  final DateTime? retryNotBefore;

  TooManyRequestsState({this.retryNotBefore});

  bool isActive(DateTime now) {
    final retryNotBefore = this.retryNotBefore;
    return retryNotBefore != null && now.isBefore(retryNotBefore);
  }

  @override
  List<Object?> get props => [retryNotBefore];
}

extension AppStateTooManyRequests on AppState {
  /// Vrai tant que la dernière limite de débit rencontrée court encore : une erreur affichée
  /// pendant ce temps est présentée comme un « trop de requêtes ».
  bool isTooManyRequests() => tooManyRequestsState.isActive(clock.now());
}
