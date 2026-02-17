import 'package:equatable/equatable.dart';

class Preferences extends Equatable {
  final bool partageFavoris;
  final bool pushNotificationAlertesOffres;
  final bool pushNotificationMessages;
  final bool pushNotificationCreationAction;
  final bool pushNotificationRendezvousSessions;
  final bool pushNotificationRappelActions;
  final bool pushNotificationActuMilo;

  Preferences({
    required this.partageFavoris,
    required this.pushNotificationAlertesOffres,
    required this.pushNotificationMessages,
    required this.pushNotificationCreationAction,
    required this.pushNotificationRendezvousSessions,
    required this.pushNotificationRappelActions,
    this.pushNotificationActuMilo = false,
  });

  factory Preferences.fromJson(dynamic json) {
    return Preferences(
      partageFavoris: json['partageFavoris'] as bool,
      pushNotificationAlertesOffres: json['alertesOffres'] as bool,
      pushNotificationMessages: json['messages'] as bool,
      pushNotificationCreationAction: json['creationActionConseiller'] as bool,
      pushNotificationRendezvousSessions: json['rendezVousSessions'] as bool,
      pushNotificationRappelActions: json['rappelActions'] as bool,
      pushNotificationActuMilo: json['actuMilo'] as bool? ?? false,
    );
  }

  Preferences copyWith({
    bool? partageFavoris,
    bool? pushNotificationAlertesOffres,
    bool? pushNotificationMessages,
    bool? pushNotificationCreationAction,
    bool? pushNotificationRendezvousSessions,
    bool? pushNotificationRappelActions,
    bool? pushNotificationActuMilo,
  }) {
    return Preferences(
      partageFavoris: partageFavoris ?? this.partageFavoris,
      pushNotificationAlertesOffres: pushNotificationAlertesOffres ?? this.pushNotificationAlertesOffres,
      pushNotificationMessages: pushNotificationMessages ?? this.pushNotificationMessages,
      pushNotificationCreationAction: pushNotificationCreationAction ?? this.pushNotificationCreationAction,
      pushNotificationRendezvousSessions: pushNotificationRendezvousSessions ?? this.pushNotificationRendezvousSessions,
      pushNotificationRappelActions: pushNotificationRappelActions ?? this.pushNotificationRappelActions,
      pushNotificationActuMilo: pushNotificationActuMilo ?? this.pushNotificationActuMilo,
    );
  }

  @override
  List<Object?> get props => [
    partageFavoris,
    pushNotificationAlertesOffres,
    pushNotificationMessages,
    pushNotificationCreationAction,
    pushNotificationRendezvousSessions,
    pushNotificationRappelActions,
    pushNotificationActuMilo,
  ];
}
