import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/criteres_recherche_persist/criteres_recherche_persist_state.dart';
import 'package:pass_emploi_app/features/recherche/emploi/emploi_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/emploi/emploi_filtres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/immersion/immersion_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/immersion/immersion_filtres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/recherche_actions.dart';
import 'package:pass_emploi_app/features/recherche/service_civique/service_civique_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/service_civique/service_civique_filtres_recherche.dart';
import 'package:pass_emploi_app/models/accompagnement.dart';
import 'package:pass_emploi_app/models/brand.dart';
import 'package:pass_emploi_app/models/criteres_recherche_utilisateur.dart';
import 'package:pass_emploi_app/models/location.dart';
import 'package:pass_emploi_app/models/offre_type.dart';
import 'package:pass_emploi_app/models/recherche/recherche_request.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

class RechercheHomePageViewModel extends Equatable {
  final List<OffreType> offreTypes;
  final String? metierLabel;
  final String? lieuLabel;
  final void Function(OffreType) onOffreTypeTap;

  RechercheHomePageViewModel({
    required this.offreTypes,
    required this.metierLabel,
    required this.lieuLabel,
    required this.onOffreTypeTap,
  });

  factory RechercheHomePageViewModel.create(Store<AppState> store) {
    final accompagnement = store.state.accompagnement();
    final criteres = store.criteresRechercheUtilisateur;
    return RechercheHomePageViewModel(
      offreTypes: [
        OffreType.emploi,
        if ([Accompagnement.cej, Accompagnement.aij, Accompagnement.avenirPro].contains(accompagnement))
          OffreType.alternance,
        OffreType.immersion,
        if ([Accompagnement.cej, Accompagnement.aij, Accompagnement.avenirPro].contains(accompagnement))
          OffreType.serviceCivique,
      ],
      metierLabel: criteres.metier?.label,
      lieuLabel: criteres.location?.libelle,
      onOffreTypeTap: (offreType) => _onOffreTypeTap(store, offreType),
    );
  }

  @override
  List<Object?> get props => [offreTypes, metierLabel, lieuLabel];
}

void _onOffreTypeTap(Store<AppState> store, OffreType offreType) {
  final criteres = store.criteresRechercheUtilisateur;
  switch (offreType) {
    case OffreType.emploi:
      _launchRechercheEmploi(store, criteres, onlyAlternance: false);
    case OffreType.alternance:
      _launchRechercheEmploi(store, criteres, onlyAlternance: true);
    case OffreType.immersion:
      _launchRechercheImmersion(store, criteres);
    case OffreType.serviceCivique:
      _launchRechercheServiceCivique(store, criteres);
  }
}

void _launchRechercheEmploi(
  Store<AppState> store,
  CriteresRechercheUtilisateur criteres, {
  required bool onlyAlternance,
}) {
  final metier = criteres.metier;
  if (metier == null || metier.label.trim().isEmpty) return;
  final brand = store.state.configurationState.getBrand();
  final location = criteres.location;
  final rayonApplicable = location?.type == LocationType.COMMUNE ? criteres.rayon : null;
  store.dispatch(
    RechercheRequestAction<EmploiCriteresRecherche, EmploiFiltresRecherche>(
      RechercheRequest(
        EmploiCriteresRecherche(
          keyword: metier.label,
          location: location,
          rechercheType: brand.isPassEmploi
              ? RechercheType.offreEmploiAndAlternance
              : RechercheType.from(onlyAlternance),
        ),
        rayonApplicable != null
            ? EmploiFiltresRecherche.withFiltres(distance: rayonApplicable)
            : EmploiFiltresRecherche.noFiltre(),
        1,
      ),
    ),
  );
}

void _launchRechercheImmersion(Store<AppState> store, CriteresRechercheUtilisateur criteres) {
  final metier = criteres.metier;
  final location = criteres.location;

  if (metier is! MetierRomeCritere) return;
  if (location == null || location.type != LocationType.COMMUNE) return;
  if (location.latitude == null || location.longitude == null) return;
  store.dispatch(
    RechercheRequestAction<ImmersionCriteresRecherche, ImmersionFiltresRecherche>(
      RechercheRequest(
        ImmersionCriteresRecherche(metier: metier.metier, location: location),
        ImmersionFiltresRecherche.distance(criteres.rayon ?? ImmersionFiltresRecherche.defaultDistanceValue),
        1,
      ),
    ),
  );
}

void _launchRechercheServiceCivique(Store<AppState> store, CriteresRechercheUtilisateur criteres) {
  final location = criteres.location;
  if (location == null || location.type != LocationType.COMMUNE) return;
  store.dispatch(
    RechercheRequestAction<ServiceCiviqueCriteresRecherche, ServiceCiviqueFiltresRecherche>(
      RechercheRequest(
        ServiceCiviqueCriteresRecherche(location: location),
        ServiceCiviqueFiltresRecherche.noFiltre(),
        1,
      ),
    ),
  );
}
