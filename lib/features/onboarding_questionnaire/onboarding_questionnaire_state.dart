import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';

sealed class OnboardingQuestionnaireState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OnboardingQuestionnaireNotInitializedState extends OnboardingQuestionnaireState {}

class OnboardingQuestionnaireSuccessState extends OnboardingQuestionnaireState {
  final bool finished;
  final OnboardingQuestionnaireAnswers answers;

  OnboardingQuestionnaireSuccessState({required this.finished, required this.answers});

  @override
  List<Object?> get props => [finished, answers];
}
