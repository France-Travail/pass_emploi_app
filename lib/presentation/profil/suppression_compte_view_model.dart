import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/login/login_state.dart';
import 'package:pass_emploi_app/features/suppression_compte/suppression_compte_action.dart';
import 'package:pass_emploi_app/features/suppression_compte/suppression_compte_state.dart';
import 'package:pass_emploi_app/models/accompagnement.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/user.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:redux/redux.dart';

class SuppressionCompteViewModel extends Equatable {
  final String title;
  final String introduction;
  final List<String> warningSuppressionFeatures;
  final String? accompagnementNotice;
  final String? poleEmploiNotice;
  final String confirmLabel;
  final DisplayState? displayState;
  final Function() onDeleteUser;

  SuppressionCompteViewModel({
    required this.title,
    required this.introduction,
    required this.warningSuppressionFeatures,
    required this.accompagnementNotice,
    required this.poleEmploiNotice,
    required this.confirmLabel,
    required this.displayState,
    required this.onDeleteUser,
  });

  factory SuppressionCompteViewModel.create(Store<AppState> store) {
    final loginState = store.state.loginState;
    final user = loginState is LoginSuccessState ? loginState.user : null;
    final copy = _copyFor(user);
    return SuppressionCompteViewModel(
      title: copy.title,
      introduction: copy.introduction,
      warningSuppressionFeatures: copy.features,
      accompagnementNotice: copy.accompagnementNotice,
      poleEmploiNotice: copy.poleEmploiNotice,
      confirmLabel: copy.confirmLabel,
      onDeleteUser: () => store.dispatch(SuppressionCompteRequestAction()),
      displayState: _displayState(store.state.suppressionCompteState),
    );
  }

  @override
  List<Object?> get props => [
        title,
        introduction,
        warningSuppressionFeatures,
        accompagnementNotice,
        poleEmploiNotice,
        confirmLabel,
        displayState,
      ];
}

typedef _SuppressionCopy = ({
  String title,
  String introduction,
  List<String> features,
  String? accompagnementNotice,
  String? poleEmploiNotice,
  String confirmLabel,
});

_SuppressionCopy _copyFor(User? user) {
  final isInvite = user?.loginMode.isInvite() == true;
  final isPe = user?.loginMode.isPe() == true;
  final accompagnement = user?.accompagnement;
  final isFtNonAccompagne = isPe &&
      (accompagnement == Accompagnement.ftEspaceCandidat || accompagnement == Accompagnement.ftDemandeurDEmploi);

  if (isInvite) {
    return (
      title: Strings.suppressionDonneesButtonLabel,
      introduction: Strings.suppressionDonneesIntroduction,
      features: Strings.warningPointsInvite,
      accompagnementNotice: null,
      poleEmploiNotice: null,
      confirmLabel: Strings.suppressionDonneesButtonLabel,
    );
  }
  if (isFtNonAccompagne) {
    return (
      title: Strings.suppressionPageTitle,
      introduction: Strings.warningInformationParagraph1,
      features: Strings.warningPointsFtNonAccompagne,
      accompagnementNotice: null,
      poleEmploiNotice: null,
      confirmLabel: Strings.suppressionButtonLabel,
    );
  }
  if (isPe) {
    return (
      title: Strings.suppressionPageTitle,
      introduction: Strings.warningInformationParagraph1,
      features: Strings.warningPointsFtAccompagne,
      accompagnementNotice: Strings.warningInformationParagraph2,
      poleEmploiNotice: Strings.warningInformationPoleEmploi,
      confirmLabel: Strings.suppressionButtonLabel,
    );
  }
  return (
    title: Strings.suppressionPageTitle,
    introduction: Strings.warningInformationParagraph1,
    features: Strings.warningPointsMilo,
    accompagnementNotice: Strings.warningInformationParagraph2,
    poleEmploiNotice: null,
    confirmLabel: Strings.suppressionButtonLabel,
  );
}

DisplayState? _displayState(SuppressionCompteState state) {
  if (state is SuppressionCompteFailureState) return DisplayState.FAILURE;
  if (state is SuppressionCompteSuccessState) return DisplayState.CONTENT;
  if (state is SuppressionCompteLoadingState) return DisplayState.LOADING;
  return null;
}
