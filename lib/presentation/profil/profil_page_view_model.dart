import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pass_emploi_app/features/details_jeune/details_jeune_state.dart';
import 'package:pass_emploi_app/features/developer_option/activation/developer_options_action.dart';
import 'package:pass_emploi_app/features/developer_option/activation/developer_options_state.dart';
import 'package:pass_emploi_app/features/login/login_state.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_state.dart';
import 'package:pass_emploi_app/features/theme/theme_actions.dart';
import 'package:pass_emploi_app/features/theme/theme_state.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:redux/redux.dart';

class ProfilPageViewModel extends Equatable {
  final String userName;
  final String userEmail;
  final bool displayMonCompte;
  final bool displayMonConseiller;
  final bool displayPartageActivite;
  final bool displayDeveloperOptions;
  final bool withDownloadCv;
  final bool withQuestionnaireHighlight;
  final String? situationLabel;
  final String? domaineLabel;
  final String? zoneLabel;
  final int objectifsCount;
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeModeChanged;
  final Function() onTitleTap;

  ProfilPageViewModel({
    required this.userName,
    required this.userEmail,
    required this.displayMonCompte,
    required this.displayMonConseiller,
    required this.displayPartageActivite,
    required this.displayDeveloperOptions,
    required this.withDownloadCv,
    required this.withQuestionnaireHighlight,
    required this.situationLabel,
    required this.domaineLabel,
    required this.zoneLabel,
    required this.objectifsCount,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onTitleTap,
  });

  factory ProfilPageViewModel.create(Store<AppState> store) {
    final state = store.state.loginState;
    final user = state is LoginSuccessState ? state.user : null;
    final themeState = store.state.themeState;
    final answers = _questionnaireAnswers(store.state.onboardingQuestionnaireState);
    final situationLabel = answers?.situation?.label;
    final domaine = answers?.domaine?.trim();
    final domaineLabel = (domaine != null && domaine.isNotEmpty) ? domaine : null;
    final villeRecherche = answers?.villeRecherche ?? answers?.habitation;
    final zoneLabel = villeRecherche != null
        ? Strings.onboardingQuestionnaireLoaderZoneValue(villeRecherche.nom, answers?.rayonKm ?? 20)
        : null;
    final objectifsCount = answers?.objectifs.length ?? 0;
    final isInvite = user?.loginMode.isInvite() == true;
    return ProfilPageViewModel(
      // trim : l'invité n'a pas de nom de famille, sans quoi on afficherait "Invité "
      userName: user != null ? "${user.firstName} ${user.lastName}".trim() : "",
      userEmail: user?.email ?? Strings.missingEmailAddressValue,
      displayMonCompte: !isInvite,
      displayMonConseiller: _shouldDisplayMonConseiller(store.state.detailsJeuneState),
      displayPartageActivite: !isInvite,
      displayDeveloperOptions: store.state.developerOptionsState is DeveloperOptionsActivatedState,
      withDownloadCv: user?.loginMode.isPe() ?? false,
      withQuestionnaireHighlight:
          situationLabel != null || domaineLabel != null || zoneLabel != null || objectifsCount > 0,
      situationLabel: situationLabel,
      domaineLabel: domaineLabel,
      zoneLabel: zoneLabel,
      objectifsCount: objectifsCount,
      themeMode: themeState is ThemeSuccessState ? themeState.themeMode : ThemeMode.light,
      onThemeModeChanged: (themeMode) => store.dispatch(ThemeSaveAction(themeMode: themeMode)),
      onTitleTap: () => store.dispatch(DeveloperOptionsActivationRequestAction()),
    );
  }

  static OnboardingQuestionnaireAnswers? _questionnaireAnswers(OnboardingQuestionnaireState state) {
    if (state is OnboardingQuestionnaireSuccessState) return state.answers;
    return null;
  }

  static bool _shouldDisplayMonConseiller(DetailsJeuneState? state) {
    if (state == null || state is DetailsJeuneNotInitializedState) return false;
    return true;
  }

  @override
  List<Object?> get props => [
        userName,
        userEmail,
        displayMonCompte,
        displayMonConseiller,
        displayPartageActivite,
        displayDeveloperOptions,
        withDownloadCv,
        withQuestionnaireHighlight,
        situationLabel,
        domaineLabel,
        zoneLabel,
        objectifsCount,
        themeMode,
      ];
}
