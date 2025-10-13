import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/demarche/create/create_demarche_actions.dart';
import 'package:pass_emploi_app/features/favori/update/favori_update_actions.dart';
import 'package:pass_emploi_app/features/mon_suivi/mon_suivi_actions.dart';
import 'package:pass_emploi_app/features/offres_suivies/offres_suivies_actions.dart';
import 'package:pass_emploi_app/features/offres_suivies/offres_suivies_state.dart';
import 'package:pass_emploi_app/features/user_action/create/user_action_create_actions.dart';
import 'package:pass_emploi_app/models/favori.dart';
import 'package:pass_emploi_app/models/offre_emploi.dart';
import 'package:pass_emploi_app/models/offre_suivie.dart';
import 'package:pass_emploi_app/models/requests/user_action_create_request.dart';
import 'package:pass_emploi_app/models/user_action.dart';
import 'package:pass_emploi_app/models/user_action_type.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/date_extensions.dart';
import 'package:redux/redux.dart';

class OffreSuivieFormViewmodel extends Equatable {
  final bool isFavorisNonPostule;
  final bool fromAlternance;
  final String? dateConsultation;
  final String? offreLien;
  final bool showConfirmation;
  final String? confirmationMessage;
  final String confirmationButton;
  final String onCreateActionOrDemarcheLabel;
  final bool useDemarche;
  final void Function() onPostule;
  final void Function()? onInteresse;
  final void Function() onNotInterested;
  final void Function() onHideForever;
  final void Function() onCreateActionOrDemarche;

  OffreSuivieFormViewmodel._({
    required this.isFavorisNonPostule,
    required this.fromAlternance,
    required this.dateConsultation,
    required this.offreLien,
    required this.showConfirmation,
    required this.confirmationMessage,
    required this.confirmationButton,
    required this.onCreateActionOrDemarcheLabel,
    required this.useDemarche,
    required this.onPostule,
    required this.onInteresse,
    required this.onNotInterested,
    required this.onHideForever,
    required this.onCreateActionOrDemarche,
  });

  factory OffreSuivieFormViewmodel.create(Store<AppState> store, String offreId, bool isHomePage) {
    final offreSuivie = store.state.offresSuiviesState.getOffre(offreId);

    final isFavorisNonPostule = store.state.offreEmploiFavorisIdsState.isFavoriNonPostule(offreId);

    return OffreSuivieFormViewmodel._(
      isFavorisNonPostule: isFavorisNonPostule,
      fromAlternance: offreSuivie != null && offreSuivie.offreDto.isAlternance,
      dateConsultation: offreSuivie != null ? _dateConsultation(offreSuivie, isFavorisNonPostule) : null,
      offreLien: offreSuivie != null ? _offreLien(offreSuivie, isHomePage) : null,
      showConfirmation: _showConfirmation(store, offreId),
      confirmationMessage: _confirmationMessage(store, offreId),
      confirmationButton: _confirmationButton(store, offreId, isHomePage),
      onCreateActionOrDemarcheLabel: store.state.isMiloLoginMode() ? Strings.addAction : Strings.addDemarche,
      useDemarche: !store.state.isMiloLoginMode(),
      onPostule: _onPostule(isFavorisNonPostule, store, offreId, offreSuivie),
      onInteresse: _onInteresse(isFavorisNonPostule, store, offreId, offreSuivie),
      onNotInterested: offreSuivie != null ? () => store.dispatch(OffresSuiviesDeleteAction(offreSuivie)) : () {},
      onHideForever: () {
        store.dispatch(OffresSuiviesConfirmationResetAction());
        store.dispatch(FavoriUpdateConfirmationResetAction());
      },
      onCreateActionOrDemarche: () => _onCreateActionOrDemarche(store, offreSuivie),
    );
  }

  @override
  List<Object?> get props => [
        fromAlternance,
        dateConsultation,
        offreLien,
        showConfirmation,
        confirmationMessage,
        confirmationButton,
        onCreateActionOrDemarcheLabel,
        useDemarche,
        onCreateActionOrDemarche,
      ];
}

bool _showConfirmation(Store<AppState> store, String offreId) {
  final confirmationFavoris = store.state.favoriUpdateState.confirmationPostuleOffreId == offreId;
  final confirmationOffreSuivie = store.state.offresSuiviesState.confirmationOffre?.offreDto.id == offreId;
  return confirmationFavoris || confirmationOffreSuivie;
}

void Function()? _onInteresse(
    bool isFavorisNonPostule, Store<AppState> store, String offreId, OffreSuivie? offreSuivie) {
  if (isFavorisNonPostule) {
    return null;
  }
  return () {
    store.dispatch(FavoriUpdateRequestAction<OffreEmploi>(offreId, FavoriStatus.added));
    if (offreSuivie != null) store.dispatch(OffresSuiviesDeleteAction(offreSuivie));
  };
}

void Function() _onPostule(bool isFavorisNonPostule, Store<AppState> store, String offreId, OffreSuivie? offreSuivie) {
  return () {
    store.dispatch(
      FavoriUpdateRequestAction<OffreEmploi>(
        offreId,
        FavoriStatus.applied,
        currentStatus: isFavorisNonPostule ? FavoriStatus.added : null,
      ),
    );
    if (offreSuivie != null) store.dispatch(OffresSuiviesDeleteAction(offreSuivie));
  };
}

String? _dateConsultation(OffreSuivie offreSuivie, bool isFavorisNonPostule) {
  if (isFavorisNonPostule) {
    return null;
  }
  return Strings.youConsultedThisOfferAt(offreSuivie.dateConsultation.timeAgo());
}

String? _offreLien(OffreSuivie offreSuivie, bool showOffreDetails) {
  if (showOffreDetails) {
    return offreSuivie.offreDto.title;
  }
  return null;
}

String? _confirmationMessage(Store<AppState> store, String offreId) {
  final isOffreFavoris = store.state.offreEmploiFavorisIdsState.contains(offreId);
  final isUserMilo = store.state.isMiloLoginMode();
  return isOffreFavoris
      ? isUserMilo
          ? Strings.wishToCreateAction
          : Strings.wishToCreateDemarche
      : null;
}

String _confirmationButton(Store<AppState> store, String offreId, bool isHomePage) {
  if (isHomePage) {
    return store.state.offresSuiviesState.offresSuivies.isNotEmpty ? Strings.seeNextOffer : Strings.close;
  }

  return Strings.close;
}

void _onCreateActionOrDemarche(Store<AppState> store, OffreSuivie? offreSuivie) {
  if (store.state.isMiloLoginMode()) {
    store.dispatch(
      UserActionCreateRequestAction(
        UserActionCreateRequest(
          Strings.candidature,
          Strings.jaiPostuleA(offreSuivie?.offreDto.title ?? "", offreSuivie?.offreDto.companyName ?? ""),
          DateTime.now(),
          false,
          UserActionStatus.DONE,
          UserActionReferentielType.emploi,
          false,
        ),
      ),
    );
  } else {
    store.dispatch(
      CreateDemarcheRequestAction(
        codeQuoi: "Q14",
        codePourquoi: "P03",
        codeComment: null,
        dateEcheance: DateTime.now(),
        estDuplicata: false,
      ),
    );
    store.dispatch(MonSuiviRequestAction(MonSuiviPeriod.current));
  }
}
