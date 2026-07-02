import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/criteres_recherche_persist/criteres_recherche_persist_state.dart';
import 'package:pass_emploi_app/features/recherche/immersion/immersion_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/immersion/immersion_filtres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/recherche_actions.dart';
import 'package:pass_emploi_app/models/criteres_recherche_utilisateur.dart';
import 'package:pass_emploi_app/models/location.dart';
import 'package:pass_emploi_app/models/metier.dart';
import 'package:pass_emploi_app/models/recherche/recherche_request.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/recherche/recherche_state_to_display_state_extension.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

class CriteresRechercheImmersionContenuViewModel extends Equatable {
  final DisplayState displayState;
  final Metier? initialMetier;
  final Location? initialLocation;
  final int initialDistance;
  final Function(Metier metier, Location location, int distance) onSearchingRequest;

  CriteresRechercheImmersionContenuViewModel({
    required this.displayState,
    required this.initialMetier,
    required this.initialLocation,
    required this.initialDistance,
    required this.onSearchingRequest,
  });

  factory CriteresRechercheImmersionContenuViewModel.create(Store<AppState> store) {
    return CriteresRechercheImmersionContenuViewModel(
      displayState: store.state.rechercheImmersionState.displayState(),
      initialMetier: store.state.rechercheImmersionState.request?.criteres.metier ?? _metierRomePersiste(store),
      initialLocation:
          store.state.rechercheImmersionState.request?.criteres.location ?? store.getLastLocationSelected(),
      initialDistance:
          store.state.rechercheImmersionState.request?.filtres.distance ??
          store.criteresRechercheUtilisateur.rayon ??
          ImmersionFiltresRecherche.defaultDistanceValue,
      onSearchingRequest: (metier, location, distance) => _onSearchingRequest(store, metier, location, distance),
    );
  }

  @override
  List<Object?> get props => [displayState];
}

Metier? _metierRomePersiste(Store<AppState> store) {
  final metier = store.criteresRechercheUtilisateur.metier;
  return metier is MetierRomeCritere ? metier.metier : null;
}

void _onSearchingRequest(Store<AppState> store, Metier metier, Location location, int distance) {
  store.dispatch(
    RechercheRequestAction<ImmersionCriteresRecherche, ImmersionFiltresRecherche>(
      RechercheRequest(
        ImmersionCriteresRecherche(metier: metier, location: location),
        ImmersionFiltresRecherche.distance(distance),
        1,
      ),
    ),
  );
}
