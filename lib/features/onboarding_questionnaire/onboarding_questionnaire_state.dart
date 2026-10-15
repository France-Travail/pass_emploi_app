import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';

sealed class OnboardingQuestionnaireState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OnboardingQuestionnaireNotInitializedState extends OnboardingQuestionnaireState {}

class OnboardingQuestionnaireSuccessState extends OnboardingQuestionnaireState {
  final bool finished;
  final bool everFinished;

  /// Vrai quand le questionnaire a été rouvert depuis l'app (Accueil), faux quand le routeur l'impose après la connexion.
  final bool resumedFromApp;
  final OnboardingQuestionnaireAnswers answers;

  OnboardingQuestionnaireSuccessState({
    required this.finished,
    required this.answers,
    this.everFinished = false,
    this.resumedFromApp = false,
  });

  @override
  List<Object?> get props => [finished, everFinished, resumedFromApp, answers];
}
