import 'package:pass_emploi_app/features/bootstrap/bootstrap_action.dart';
import 'package:pass_emploi_app/features/offres_suivies/offres_suivies_actions.dart';
import 'package:pass_emploi_app/features/offres_suivies/offres_suivies_state.dart';
import 'package:pass_emploi_app/models/favori.dart';
import 'package:pass_emploi_app/models/offre_suivie.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/offres_suivies_repository.dart';
import 'package:redux/redux.dart';

class OffresSuiviesMiddleware extends MiddlewareClass<AppState> {
  final OffresSuiviesRepository _repository;

  OffresSuiviesMiddleware(this._repository);

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    next(action);

    if (action is BootstrapAction) {
      final offresSuivies = await _repository.getOffresSuivies();
      final blacklistedOffreIds = await _repository.getBlacklistedOffreIds();
      store.dispatch(OffresSuiviesToStateAction(offresSuivies, blackListedOffreIds: blacklistedOffreIds));
    } else if (action is OffresSuiviesWriteAction) {
      final date = DateTime.now();
      final offreSuivie = OffreSuivie(offreDto: action.offreDto, dateConsultation: date);
      final newoffresSuivies = await _repository.setOffreSuivie(offreSuivie);
      store.dispatch(OffresSuiviesToStateAction(newoffresSuivies));
    } else if (action is OffresSuiviesDeleteAction) {
      final newoffresSuivies = await _repository.delete(action.offreSuivie);
      store.dispatch(
        OffresSuiviesToStateAction(
          newoffresSuivies,
          confirmationOffre: ConfirmationOffre(
            offreId: action.offreSuivie.offreDto.id,
            newStatus: FavoriStatus.removed,
          ),
        ),
      );
    } else if (action is OffresSuiviesBlacklistAction) {
      await _repository.blacklistOffreIds(action.offreId);
      final offresSuivies = await _repository.getOffresSuivies();
      final blacklistedOffreIds = await _repository.getBlacklistedOffreIds();
      store.dispatch(OffresSuiviesToStateAction(
        offresSuivies,
        blackListedOffreIds: blacklistedOffreIds,
        confirmationOffre: ConfirmationOffre(
          offreId: action.offreId,
          newStatus: FavoriStatus.blacklisted,
        ),
      ));
    }
  }
}
