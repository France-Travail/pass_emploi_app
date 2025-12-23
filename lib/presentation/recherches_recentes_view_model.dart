import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/alerte/get/alerte_get_action.dart';
import 'package:pass_emploi_app/models/alerte/alerte.dart';
import 'package:pass_emploi_app/models/alerte/immersion_alerte.dart';
import 'package:pass_emploi_app/models/alerte/offre_emploi_alerte.dart';
import 'package:pass_emploi_app/models/alerte/service_civique_alerte.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:redux/redux.dart';

class RecherchesRecentesViewModel extends Equatable {
  final Alerte? rechercheRecente;
  final String title;
  final Function(Alerte) fetchAlerteResult;

  RecherchesRecentesViewModel({
    required this.rechercheRecente,
    required this.title,
    required this.fetchAlerteResult,
  });

  static RecherchesRecentesViewModel create(Store<AppState> store) {
    final state = store.state.recherchesRecentesState;
    final rechercheRecente = state.recentSearches.derniereRechercheOffre();
    return RecherchesRecentesViewModel(
      rechercheRecente: state.recentSearches.derniereRechercheOffre(),
      title: _title(rechercheRecente),
      fetchAlerteResult: (alerte) => store.dispatch(FetchAlerteResultsAction(alerte)),
    );
  }

  @override
  List<Object?> get props => [rechercheRecente];
}

String _title(Alerte? rechercheRecente) {
  if (rechercheRecente is OffreEmploiAlerte) {
    return rechercheRecente.onlyAlternance
        ? Strings.rechercheHomeOffresAlternanceTitle
        : Strings.rechercheHomeOffresEmploiTitle;
  } else if (rechercheRecente is ImmersionAlerte) {
    return Strings.rechercheHomeOffresImmersionTitle;
  } else if (rechercheRecente is ServiceCiviqueAlerte) {
    return Strings.rechercheHomeOffresServiceCiviqueTitle;
  } else {
    return Strings.rechercheHomeOffresEmploiTitle;
  }
}

extension _RechercheRecentesList on List<Alerte> {
  Alerte? derniereRechercheOffre() {
    return firstWhereOrNull((element) {
      return element is OffreEmploiAlerte || element is ImmersionAlerte || element is ServiceCiviqueAlerte;
    });
  }
}
