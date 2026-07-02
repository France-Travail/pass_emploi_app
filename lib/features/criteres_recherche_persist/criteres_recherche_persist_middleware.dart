import 'package:pass_emploi_app/features/bootstrap/bootstrap_action.dart';
import 'package:pass_emploi_app/features/criteres_recherche_persist/criteres_recherche_persist_actions.dart';
import 'package:pass_emploi_app/features/criteres_recherche_persist/criteres_recherche_persist_state.dart';
import 'package:pass_emploi_app/features/recherche/emploi/emploi_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/emploi/emploi_filtres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/immersion/immersion_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/immersion/immersion_filtres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/recherche_actions.dart';
import 'package:pass_emploi_app/features/recherche/service_civique/service_civique_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/service_civique/service_civique_filtres_recherche.dart';
import 'package:pass_emploi_app/models/criteres_recherche_utilisateur.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/criteres_recherche_persist_repository.dart';
import 'package:redux/redux.dart';

class CriteresRecherchePersistMiddleware extends MiddlewareClass<AppState> {
  final CriteresRecherchePersistRepository _repository;

  CriteresRecherchePersistMiddleware(this._repository);

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    next(action);

    if (action is BootstrapAction) {
      final criteres = await _repository.get();
      store.dispatch(CriteresRecherchePersistSuccessAction(criteres ?? CriteresRechercheUtilisateur()));
    } else if (action is CriteresRecherchePersistWriteAction) {
      await _save(store, action.criteres);
    } else if (action is CriteresRecherchePersistWriteLocationAction) {
      final current = store.criteresRechercheUtilisateur;

      await _save(
        store,
        CriteresRechercheUtilisateur(metier: current.metier, location: action.location, rayon: current.rayon),
      );
    } else if (action is RechercheRequestAction<EmploiCriteresRecherche, EmploiFiltresRecherche>) {
      await _updateFromEmploiRecherche(store, action);
    } else if (action is RechercheRequestAction<ImmersionCriteresRecherche, ImmersionFiltresRecherche>) {
      await _updateFromImmersionRecherche(store, action);
    } else if (action is RechercheRequestAction<ServiceCiviqueCriteresRecherche, ServiceCiviqueFiltresRecherche>) {
      await _updateFromServiceCiviqueRecherche(store, action);
    }
  }

  Future<void> _updateFromEmploiRecherche(
    Store<AppState> store,
    RechercheRequestAction<EmploiCriteresRecherche, EmploiFiltresRecherche> action,
  ) async {
    final current = store.criteresRechercheUtilisateur;
    final keyword = action.request.criteres.keyword.trim();
    await _save(
      store,
      current.copyWith(
        metier: keyword.isNotEmpty ? _metierFromKeyword(keyword, current.metier) : null,
        location: action.request.criteres.location,
        rayon: action.request.filtres.distance,
      ),
    );
  }

  MetierCritere _metierFromKeyword(String keyword, MetierCritere? currentMetier) {
    if (currentMetier is MetierRomeCritere && currentMetier.metier.libelle == keyword) return currentMetier;
    return MetierTexteLibreCritere(keyword);
  }

  Future<void> _updateFromImmersionRecherche(
    Store<AppState> store,
    RechercheRequestAction<ImmersionCriteresRecherche, ImmersionFiltresRecherche> action,
  ) async {
    final metier = action.request.criteres.metier;
    await _save(
      store,
      store.criteresRechercheUtilisateur.copyWith(
        metier: metier != null ? MetierRomeCritere(metier) : null,
        location: action.request.criteres.location,
        rayon: action.request.filtres.distance,
      ),
    );
  }

  Future<void> _updateFromServiceCiviqueRecherche(
    Store<AppState> store,
    RechercheRequestAction<ServiceCiviqueCriteresRecherche, ServiceCiviqueFiltresRecherche> action,
  ) async {
    await _save(store, store.criteresRechercheUtilisateur.copyWith(location: action.request.criteres.location));
  }

  Future<void> _save(Store<AppState> store, CriteresRechercheUtilisateur criteres) async {
    await _repository.save(criteres);
    store.dispatch(CriteresRecherchePersistSuccessAction(criteres));
  }
}
