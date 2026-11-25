import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/models/structure_accompagnement.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';

/// Évènements Matomo de « Être accompagné ». Ils ne portent jamais la ville : seulement le type de structure, l'origine
/// de la ville (questionnaire, saisie ou géolocalisation) et le nombre de résultats.
class EtreAccompagneTrackingEvent extends Equatable {
  final String action;
  final String? name;
  final int? value;

  const EtreAccompagneTrackingEvent(this.action, {this.name, this.value});

  const EtreAccompagneTrackingEvent.tuile() : this(AnalyticsEventNames.etreAccompagneTuileAction);

  EtreAccompagneTrackingEvent.recherche(StructuresAccompagnementRequest request, {required int resultCount})
    : this(
        AnalyticsEventNames.etreAccompagneRechercheAction(request.type.trackingLabel),
        name: request.origine.trackingLabel,
        value: resultCount,
      );

  EtreAccompagneTrackingEvent.erreur(StructuresAccompagnementRequest request)
    : this(
        AnalyticsEventNames.etreAccompagneErreurAction(request.type.trackingLabel),
        name: request.origine.trackingLabel,
      );

  EtreAccompagneTrackingEvent.appel(StructureAccompagnementType type)
    : this(AnalyticsEventNames.etreAccompagneAppelAction(type.trackingLabel));

  const EtreAccompagneTrackingEvent.appel3949() : this(AnalyticsEventNames.etreAccompagneAppel3949Action);

  EtreAccompagneTrackingEvent.itineraire(StructureAccompagnementType type)
    : this(AnalyticsEventNames.etreAccompagneItineraireAction(type.trackingLabel));

  void send() {
    PassEmploiMatomoTracker.instance.trackEvent(
      eventCategory: AnalyticsEventNames.etreAccompagneCategory,
      action: action,
      eventName: name,
      eventValue: value,
    );
  }

  @override
  List<Object?> get props => [action, name, value];
}

extension StructureAccompagnementTypeTracking on StructureAccompagnementType {
  String get trackingLabel => switch (this) {
    StructureAccompagnementType.missionLocale => "Mission Locale",
    StructureAccompagnementType.franceTravail => "France Travail",
  };

  String get trackingScreenName => switch (this) {
    StructureAccompagnementType.missionLocale => AnalyticsScreenNames.etreAccompagneMissionLocale,
    StructureAccompagnementType.franceTravail => AnalyticsScreenNames.etreAccompagneFranceTravail,
  };
}
