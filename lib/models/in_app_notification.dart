import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/utils/string_extensions.dart';

enum InAppNotificationType {
  newActu,
  newAction,
  newRendezvous,
  rappelRendezvous,
  detailRendezvous,
  deletedRendezvous,
  updatedRendezvous,
  nouvelleOffre,
  migrationParcoursEmploi,
  detailAction,
  detailSessionMilo,
  deletedSessionMilo,
  rappelCreationAction,
  rappelCreationDemarche,
  actualisationPe,
  campagne,
  newMessage,
  nouvellesFonctionnalites,
  eventList,
  monSuivi,
  offresEnregistrees,
  savedSearches,
  recherche,
  outils,
  benevolat,
  laBonneAlternance,
  unknown;

  static InAppNotificationType fromString(String type) {
    return switch (type) {
      "NEW_ACTU" => newActu,
      "NEW_ACTION" => newAction,
      "NEW_RENDEZVOUS" => newRendezvous,
      "RAPPEL_RENDEZVOUS" => rappelRendezvous,
      "DETAIL_RENDEZVOUS" => detailRendezvous,
      "DELETED_RENDEZVOUS" => deletedRendezvous,
      "UPDATED_RENDEZVOUS" => updatedRendezvous,
      "NOUVELLE_OFFRE" => nouvelleOffre,
      "MIGRATION_PARCOURS_EMPLOI" => migrationParcoursEmploi,
      "DETAIL_ACTION" => detailAction,
      "DETAIL_SESSION_MILO" => detailSessionMilo,
      "DELETED_SESSION_MILO" => deletedSessionMilo,
      "RAPPEL_CREATION_ACTION" => rappelCreationAction,
      "RAPPEL_CREATION_DEMARCHE" => rappelCreationDemarche,
      "ACTUALISATION_PE" => actualisationPe,
      "CAMPAGNE" => campagne,
      "NEW_MESSAGE" => newMessage,
      "NOUVELLES_FONCTIONNALITES" => nouvellesFonctionnalites,
      "EVENT_LIST" => eventList,
      "MON_SUIVI" => monSuivi,
      "OFFRES_ENREGISTREES" => offresEnregistrees,
      "SAVED_SEARCHES" => savedSearches,
      "RECHERCHE" => recherche,
      "OUTILS" => outils,
      "BENEVOLAT" => benevolat,
      "LA_BONNE_ALTERNANCE" => laBonneAlternance,
      _ => unknown,
    };
  }
}

class InAppNotification extends Equatable {
  final String id;
  final DateTime date;
  final String titre;
  final String description;
  final InAppNotificationType type;
  final String? idObjet;

  InAppNotification({
    required this.id,
    required this.date,
    required this.titre,
    required this.description,
    required this.type,
    this.idObjet,
  });

  @override
  List<Object?> get props => [id, date, titre, description, type, idObjet];

  static InAppNotification fromJson(Map<String, dynamic> json) {
    return InAppNotification(
      id: json['id'] as String,
      date: (json['date'] as String).toDateTimeUtcOnLocalTimeZone(),
      titre: json['titre'] as String,
      description: json['description'] as String,
      type: InAppNotificationType.fromString(json['type'] as String),
      idObjet: json['idObjet'] as String?,
    );
  }
}
