import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/demarche/create/create_demarche_actions.dart';
import 'package:pass_emploi_app/features/offre_emploi/details/offre_emploi_details_state.dart';
import 'package:pass_emploi_app/features/user_action/create/user_action_create_actions.dart';
import 'package:pass_emploi_app/models/accompagnement.dart';
import 'package:pass_emploi_app/models/requests/user_action_create_request.dart';
import 'package:pass_emploi_app/models/user_action.dart';
import 'package:pass_emploi_app/models/user_action_type.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:redux/redux.dart';

// enum PostuerConfirmationSource {}

class PostulerConfirmationViewModel extends Equatable {
  const PostulerConfirmationViewModel({
    required this.onCreateActionOrDemarcheLabel,
    required this.wishToCreateActionOrDemarche,
    required this.useDemarche,
    required this.onCreateActionOrDemarche,
  });

  final String onCreateActionOrDemarcheLabel;
  final String wishToCreateActionOrDemarche;
  final bool useDemarche;
  final void Function()? onCreateActionOrDemarche;

  factory PostulerConfirmationViewModel.create(Store<AppState> store, String offreId) {
    return PostulerConfirmationViewModel(
      onCreateActionOrDemarcheLabel: store.state.isMiloLoginMode() ? Strings.addAction : Strings.addDemarche,
      wishToCreateActionOrDemarche: store.state.isMiloLoginMode()
          ? Strings.wishToCreateAction
          : Strings.wishToCreateDemarche,
      useDemarche: !store.state.isMiloLoginMode(),
      onCreateActionOrDemarche: _onCreateActionOrDemarche(store),
    );
  }

  @override
  List<Object?> get props => [
    onCreateActionOrDemarcheLabel,
    wishToCreateActionOrDemarche,
    useDemarche,
    onCreateActionOrDemarche,
  ];
}

void Function()? _onCreateActionOrDemarche(Store<AppState> store) {
  final user = store.state.user();
  if (user?.accompagnement == Accompagnement.avenirPro) {
    return null;
  }

  final offreEmploiDetailsState = store.state.offreEmploiDetailsState;

  return () {
    if (store.state.isMiloLoginMode()) {
      store.dispatch(
        UserActionCreateRequestAction(
          UserActionCreateRequest(
            Strings.candidature,
            _getComment(offreEmploiDetailsState.offreTitleOrNull, offreEmploiDetailsState.offreCompanyNameOrNull),
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
    }
  };
}

String _getComment(String? title, String? companyName) {
  if (title == null) {
    return Strings.jaiPostuleAOffre;
  }
  return Strings.jaiPostuleA(title, companyName ?? Strings.unknown);
}

extension on OffreEmploiDetailsState {
  String? get offreTitleOrNull =>
      this is OffreEmploiDetailsSuccessState ? (this as OffreEmploiDetailsSuccessState).offre.title : null;
  String? get offreCompanyNameOrNull =>
      this is OffreEmploiDetailsSuccessState ? (this as OffreEmploiDetailsSuccessState).offre.companyName : null;
}
