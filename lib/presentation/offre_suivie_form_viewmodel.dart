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
  final void Function()? onNotYetPostuled;
  final void Function() onNotInterested;
  final void Function() onHideForever;
  final void Function() onCreateActionOrDemarche;
  final void Function()? onNextOffer;

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
    required this.onNotYetPostuled,
    required this.onNotInterested,
    required this.onHideForever,
    required this.onCreateActionOrDemarche,
    required this.onNextOffer,
  });

  factory OffreSuivieFormViewmodel.create(Store<AppState> store, String offreId, bool isHomePage) {
    final offreSuivie = store.state.offresSuiviesState.getOffre(offreId);

    final isFavorisNonPostule = store.state.favoriListState.isFavoriNonPostule(offreId);

    return OffreSuivieFormViewmodel._(
      isFavorisNonPostule: isFavorisNonPostule,
      fromAlternance: offreSuivie != null && offreSuivie.offreDto.isAlternance,
      dateConsultation: _dateConsultation(offreSuivie, offreId, isFavorisNonPostule, isHomePage, store),
      offreLien: _offreLien(offreSuivie, isHomePage, store, offreId),
      showConfirmation: _showConfirmation(store, offreId),
      confirmationMessage: _confirmationMessage(store, offreId),
      confirmationButton: _confirmationButton(store, offreId, isHomePage),
      onCreateActionOrDemarcheLabel: store.state.isMiloLoginMode() ? Strings.addAction : Strings.addDemarche,
      useDemarche: !store.state.isMiloLoginMode(),
      onPostule: _onPostule(isFavorisNonPostule, store, offreId, offreSuivie),
      onInteresse: _onInteresse(isFavorisNonPostule, store, offreId, offreSuivie),
      onNotInterested: _onNotInterested(offreSuivie, store, offreId),
      onHideForever: () {
        store.dispatch(OffresSuiviesConfirmationResetAction());
        store.dispatch(FavoriUpdateConfirmationResetAction());
      },
      onNotYetPostuled: _onNotYetPostuled(isFavorisNonPostule, store, offreId, isHomePage),
      onCreateActionOrDemarche: () => _onCreateActionOrDemarche(store, offreSuivie),
      onNextOffer: _onNextOffer(store, offreId, isHomePage),
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
  final confirmationOffreSuivie = store.state.offresSuiviesState.confirmationOffreId == offreId;
  return confirmationFavoris || confirmationOffreSuivie;
}

void Function()? _onNextOffer(Store<AppState> store, String offreId, bool isHomePage) {
  if (isHomePage) {
    return () {
      store.dispatch(OffresSuiviesConfirmationResetAction());
      store.dispatch(FavoriUpdateConfirmationResetAction());
    };
  }
  return null;
}

// TODO: Test me
void Function()? _onNotYetPostuled(bool isFavorisNonPostule, Store<AppState> store, String offreId, bool isHomePage) {
  if (isFavorisNonPostule && isHomePage) {
    return () => store.dispatch(OffresSuiviesBlacklistAction(offreId));
  }
  return null;
}

void Function() _onNotInterested(OffreSuivie? offreSuivie, Store<AppState> store, String offreId) {
  return () {
    if (offreSuivie != null) {
      store.dispatch(OffresSuiviesDeleteAction(offreSuivie));
    }
    final isEnFavoris = store.state.offreEmploiFavorisIdsState.contains(offreId);
    if (isEnFavoris) {
      store.dispatch(FavoriUpdateRequestAction<OffreEmploi>(offreId, FavoriStatus.removed));
    }
  };
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

// TODO: Test me
String? _dateConsultation(
  OffreSuivie? offreSuivie,
  String offreId,
  bool isFavorisNonPostule,
  bool isHomePage,
  Store<AppState> store,
) {
  if (isFavorisNonPostule) {
    if (isHomePage) {
      final dateCreation = store.state.favoriListState.favoriOrNull(offreId)?.dateDeCreation;
      return Strings.youSavedThisOfferAt(dateCreation?.timeAgo() ?? "");
    }
    return null;
  }
  if (offreSuivie != null) {
    return Strings.youConsultedThisOfferAt(offreSuivie.dateConsultation.timeAgo());
  }
  return null;
}

// TODO: Test me
String? _offreLien(OffreSuivie? offreSuivie, bool showOffreDetails, Store<AppState> store, String offreId) {
  if (showOffreDetails) {
    if (offreSuivie != null) {
      return offreSuivie.offreDto.title;
    }
    final favori = store.state.favoriListState.favoriOrNull(offreId);
    return favori?.titre;
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
