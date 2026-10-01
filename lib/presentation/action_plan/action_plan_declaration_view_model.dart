import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_actions.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_declaration_state.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_state.dart';
import 'package:pass_emploi_app/features/deep_link/deep_link_actions.dart';
import 'package:pass_emploi_app/models/deep_link.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/action_plan/action_plan_repository.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:redux/redux.dart';

class ActionPlanDeclarationViewModel extends Equatable {
  final String titre;
  final String? categorie;
  final bool commentaireRequis;
  final DisplayState displayState;
  final String? messageErreur;
  final String prenom;
  final void Function(DateTime date, String? commentaire) onDeclare;
  final VoidCallback onVoirAgenda;

  const ActionPlanDeclarationViewModel({
    required this.titre,
    required this.categorie,
    required this.commentaireRequis,
    required this.displayState,
    required this.messageErreur,
    required this.prenom,
    required this.onDeclare,
    required this.onVoirAgenda,
  });

  factory ActionPlanDeclarationViewModel.create(Store<AppState> store, String actionId) {
    final planState = store.state.actionPlanState;
    final action = planState is ActionPlanSuccessState ? planState.plan.findAction(actionId) : null;
    final commentaireRequis = store.state.isMiloLoginMode();
    final declaration = store.state.actionPlanDeclarationState;
    return ActionPlanDeclarationViewModel(
      titre: action?.label ?? '',
      categorie: action?.categorie,
      commentaireRequis: commentaireRequis,
      displayState: switch (declaration) {
        ActionPlanDeclarationNotInitializedState() => DisplayState.EMPTY,
        ActionPlanDeclarationLoadingState() => DisplayState.LOADING,
        ActionPlanDeclarationSuccessState() => DisplayState.CONTENT,
        ActionPlanDeclarationFailureState() => DisplayState.FAILURE,
      },
      messageErreur: declaration is ActionPlanDeclarationFailureState ? _message(declaration.reason) : null,
      prenom: store.state.user()?.firstName ?? '',
      onDeclare: (date, commentaire) => store.dispatch(
        ActionPlanDeclareAction(actionId, date, commentaireRequis ? commentaire?.trim() : null),
      ),
      onVoirAgenda: () => store.dispatch(HandleDeepLinkAction(MonSuiviDeepLink(), DeepLinkOrigin.inAppNavigation)),
    );
  }

  static String _message(ActionPlanDeclarationFailureReason reason) => switch (reason) {
        ActionPlanDeclarationFailureReason.solutionRetiree => Strings.actionPlanDeclarationSolutionRetiree,
        ActionPlanDeclarationFailureReason.indisponible => Strings.actionPlanDeclarationIndisponible,
        ActionPlanDeclarationFailureReason.autre => Strings.miscellaneousErrorRetry,
      };

  @override
  List<Object?> get props => [titre, categorie, commentaireRequis, displayState, messageErreur, prenom];
}
