import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:pass_emploi_app/features/structures_accompagnement/structures_accompagnement_actions.dart';
import 'package:pass_emploi_app/features/structures_accompagnement/structures_accompagnement_state.dart';
import 'package:pass_emploi_app/models/structure_accompagnement.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/etre_accompagne/etre_accompagne_tracking.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/platform.dart';
import 'package:pass_emploi_app/utils/uri_handler.dart';
import 'package:redux/redux.dart';

class StructuresAccompagnementViewModel extends Equatable {
  final DisplayState displayState;
  final StructureAccompagnementType type;
  final String title;
  final String? subtitle;
  final String? intro;
  final bool withContact3949;
  final Uri contact3949Uri;
  final List<StructureAccompagnementItem> items;
  final String emptyTitle;
  final String emptyMessage;

  /// Recherche aboutie ou en échec, à suivre une seule fois.
  final EtreAccompagneTrackingEvent? resultEvent;
  final VoidCallback onRetry;

  const StructuresAccompagnementViewModel({
    required this.displayState,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.intro,
    required this.withContact3949,
    required this.contact3949Uri,
    required this.items,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.resultEvent,
    required this.onRetry,
  });

  factory StructuresAccompagnementViewModel.create(
    Store<AppState> store,
    StructuresAccompagnementRequest request, {
    required Platform platform,
  }) {
    final state = store.state.structuresAccompagnementState;
    final type = request.type;
    final isMissionLocale = type == StructureAccompagnementType.missionLocale;
    final ville = request.commune.nomCourt;
    final structures = state is StructuresAccompagnementSuccessState && state.request == request ? state.result : null;
    final isFailure = state is StructuresAccompagnementFailureState && state.request == request;
    final displayState = isFailure
        ? DisplayState.FAILURE
        : structures == null
        ? DisplayState.LOADING
        : structures.isEmpty
        ? DisplayState.EMPTY
        : DisplayState.CONTENT;
    final count = structures?.length ?? 0;
    final withContent = displayState == DisplayState.CONTENT;

    return StructuresAccompagnementViewModel(
      displayState: displayState,
      type: type,
      title: isMissionLocale ? Strings.etreAccompagneMissionLocale : Strings.etreAccompagneFranceTravail,
      subtitle: !withContent
          ? null
          : isMissionLocale
          ? Strings.etreAccompagneMissionLocaleSubtitle(ville)
          : Strings.etreAccompagneFranceTravailSubtitle(count, ville),
      intro: !withContent
          ? null
          : !isMissionLocale
          ? Strings.etreAccompagneIntroFranceTravail(count)
          : count > 1
          ? Strings.etreAccompagneIntroMissionLocaleSites(count, ville)
          : Strings.etreAccompagneIntroMissionLocale,
      // Le 3949 reste proposé pendant le chargement, en cas d'erreur ou sans agence.
      withContact3949: !isMissionLocale,
      contact3949Uri: UriHandler().phoneUri(Strings.etreAccompagne3949Numero),
      items: [
        for (final structure in structures ?? const <StructureAccompagnement>[])
          // France Travail : un seul numéro, le 3949, proposé au-dessus des agences.
          StructureAccompagnementItem.from(structure, platform: platform, withCall: isMissionLocale),
      ],
      emptyTitle: Strings.etreAccompagneEmptyTitle(request.commune.codePostal ?? request.commune.nomCourt),
      emptyMessage: isMissionLocale
          ? Strings.etreAccompagneEmptyMissionLocale
          : Strings.etreAccompagneEmptyFranceTravail,
      resultEvent: switch (displayState) {
        DisplayState.FAILURE => EtreAccompagneTrackingEvent.erreur(request),
        DisplayState.LOADING => null,
        _ => EtreAccompagneTrackingEvent.recherche(request, resultCount: count),
      },
      onRetry: () => store.dispatch(StructuresAccompagnementRequestAction(request)),
    );
  }

  @override
  List<Object?> get props => [
    displayState,
    type,
    title,
    subtitle,
    intro,
    withContact3949,
    contact3949Uri,
    items,
    emptyTitle,
    emptyMessage,
    resultEvent,
  ];
}

class StructureAccompagnementItem extends Equatable {
  final String nom;
  final String? adresse;
  final List<String> horaires;
  final String? horairesA11yLabel;
  final String? callLabel;
  final String? callA11yLabel;
  final Uri? callUri;
  final String itineraireA11yLabel;
  final Uri itineraireUri;

  const StructureAccompagnementItem({
    required this.nom,
    required this.adresse,
    required this.horaires,
    required this.horairesA11yLabel,
    required this.callLabel,
    required this.callA11yLabel,
    required this.callUri,
    required this.itineraireA11yLabel,
    required this.itineraireUri,
  });

  factory StructureAccompagnementItem.from(
    StructureAccompagnement structure, {
    required Platform platform,
    required bool withCall,
  }) {
    final telephone = structure.telephone;
    final digits = telephone?.replaceAll(RegExp(r'[^0-9+]'), '');
    final hasTelephone = withCall && telephone != null && digits != null && digits.isNotEmpty;
    final adresse = structure.adresse.complete;
    return StructureAccompagnementItem(
      nom: structure.nom,
      adresse: adresse,
      horaires: structure.horaires,
      // Lecteurs d'écran : la version rédigée du back si présente, sinon les lignes affichées.
      horairesA11yLabel: structure.horaires.isEmpty
          ? null
          : Strings.etreAccompagneHorairesA11y(structure.horairesAlt ?? structure.horaires.join(', ')),
      // Espaces insécables : le numéro n'est jamais coupé en fin de ligne.
      callLabel: hasTelephone ? Strings.etreAccompagneCall(telephone.replaceAll(' ', '\u00A0')) : null,
      callA11yLabel: hasTelephone ? Strings.etreAccompagneCallA11y(telephone, structure.nom) : null,
      callUri: hasTelephone ? UriHandler().phoneUri(digits) : null,
      itineraireA11yLabel: Strings.etreAccompagneItineraireA11y(structure.nom),
      // Sans coordonnées dans la réponse, Maps / Plans cherche le bâtiment à son adresse complète.
      itineraireUri: UriHandler().mapsUri(adresse ?? structure.nom, platform),
    );
  }

  @override
  List<Object?> get props => [
    nom,
    adresse,
    horaires,
    horairesA11yLabel,
    callLabel,
    callA11yLabel,
    callUri,
    itineraireA11yLabel,
    itineraireUri,
  ];
}
