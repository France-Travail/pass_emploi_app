import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_actions.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_state.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_app_bar.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_birthdate_step.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_domaine_step.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_freins_step.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_loader_step.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_location_step.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_objectifs_step.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_prenom_step.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_situation_step.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_under_age_page.dart';
import 'package:pass_emploi_app/presentation/onboarding_questionnaire/onboarding_questionnaire_form_change_notifier.dart';
import 'package:pass_emploi_app/presentation/onboarding_questionnaire/onboarding_questionnaire_tracker.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/communes_repository.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';

class OnboardingQuestionnairePage extends StatefulWidget {
  final bool editMode;

  const OnboardingQuestionnairePage({super.key, this.editMode = false});

  static MaterialPageRoute<void> materialPageRoute({bool editMode = true}) {
    return MaterialPageRoute(builder: (_) => OnboardingQuestionnairePage(editMode: editMode));
  }

  @override
  State<OnboardingQuestionnairePage> createState() => _OnboardingQuestionnairePageState();
}

class _OnboardingQuestionnairePageState extends State<OnboardingQuestionnairePage> {
  late final OnboardingQuestionnaireFormChangeNotifier _form;
  late final CommunesRepository _communesRepository;
  late final OnboardingQuestionnaireTracker _tracker;
  bool _formInitialized = false;

  @override
  void initState() {
    super.initState();
    _communesRepository = CommunesRepository();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_formInitialized) return;
    _formInitialized = true;
    final store = StoreProvider.of<AppState>(context);
    final questionnaireState = store.state.onboardingQuestionnaireState;
    _tracker = OnboardingQuestionnaireTracker(
      isUpdate: questionnaireState is OnboardingQuestionnaireSuccessState && questionnaireState.everFinished,
    );
    _form = OnboardingQuestionnaireFormChangeNotifier(
      loadAnswers: () async {
        final questionnaireState = store.state.onboardingQuestionnaireState;
        if (questionnaireState is OnboardingQuestionnaireSuccessState) return questionnaireState.answers;
        return const OnboardingQuestionnaireAnswers();
      },
      saveAnswers: (answers) async {
        store.dispatch(OnboardingQuestionnaireAnswersUpdatedAction(answers));
      },
      startAtFirstStep: widget.editMode,
      skipActionPlanGeneration: widget.editMode,
      tracker: _tracker,
      onFinishWithoutGeneration: (answers) {
        store.dispatch(OnboardingQuestionnaireCompleteAction(answers));
        if (widget.editMode) {
          store.dispatch(OnboardingQuestionnaireFinishAction(answers));
          if (context.mounted) Navigator.of(context).pop();
        }
      },
    );
    _form.init();
  }

  @override
  void dispose() {
    if (_formInitialized) _form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
      child: ListenableBuilder(
        listenable: _form,
        builder: (context, _) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              _onBack();
            },
            child: Scaffold(
              backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
              appBar: _form.step.isLoader ? null : OnboardingQuestionnaireAppBar(onBack: _onBack),
              body: SafeArea(
                child: _form.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _form.step.isLoader
                    ? OnboardingQuestionnaireLoaderStep(answers: _form.savedAnswers)
                    : _QuestionnaireBody(
                        form: _form,
                        communesRepository: _communesRepository,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onBack() {
    if (_form.step.isLoader) return;
    final shouldClose = _form.goBack();
    if (!shouldClose) return;
    _tracker.trackEvent(
      AnalyticsEventNames.questionnaireExitAction,
      name: widget.editMode ? "Profil" : "Parcours d'entrée",
      value: _form.step.questionnaireIndex,
    );
    if (widget.editMode) {
      Navigator.of(context).maybePop();
    } else {
      StoreProvider.of<AppState>(context).dispatch(RequestLogoutAction(LogoutReason.userLogout));
    }
  }
}

class _QuestionnaireBody extends StatelessWidget {
  const _QuestionnaireBody({
    required this.form,
    required this.communesRepository,
  });

  final OnboardingQuestionnaireFormChangeNotifier form;
  final CommunesRepository communesRepository;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_base),
          // A11y 10.2 : à chaque changement d'étape, le focus du lecteur d'écran part du bouton
          // « Continuer » pour aller sur le titre de la nouvelle étape.
          child: AutoFocusA11y(
            key: ValueKey(form.step),
            duration: AnimationDurations.slow,
            // A11y 10.2.3 : « Étape X sur Y, titre » restitué en un seul en-tête.
            child: Semantics(
              header: true,
              label: Strings.onboardingQuestionnaireStepA11y(
                form.step.questionnaireIndex,
                OnboardingQuestionnaireStep.questionnaireCount,
                _stepTitle(form.step),
              ),
              excludeSemantics: true,
              child: DsfrStepper(
                currentStep: form.step.questionnaireIndex,
                stepsCount: OnboardingQuestionnaireStep.questionnaireCount,
                stepTitle: _stepTitle(form.step),
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Margins.spacing_base),
            child: AnimatedSwitcher(
              duration: AnimationDurations.slow,
              switchInCurve: Curves.linear,
              switchOutCurve: Curves.linear,
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // A11y : l'étape précédente, encore affichée pendant le fondu, ne doit plus être
                    // atteignable par le lecteur d'écran.
                    ...previousChildren.map((child) => ExcludeSemantics(child: child)),
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              // Fade-out puis vide puis fade-in : pas de superposition des textes.
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
                  ),
                  child: child,
                );
              },
              child: KeyedSubtree(
                key: ValueKey(form.step),
                child: _StepContent(form: form, communesRepository: communesRepository),
              ),
            ),
          ),
        ),
        _BottomActions(form: form),
      ],
    );
  }

  String _stepTitle(OnboardingQuestionnaireStep step) => switch (step) {
    OnboardingQuestionnaireStep.prenom => Strings.onboardingQuestionnairePrenomTitle,
    OnboardingQuestionnaireStep.dateNaissance => Strings.onboardingQuestionnaireBirthdateTitle,
    OnboardingQuestionnaireStep.habitation => Strings.onboardingQuestionnaireHabitationTitle,
    OnboardingQuestionnaireStep.situation => Strings.onboardingQuestionnaireSituationTitle,
    OnboardingQuestionnaireStep.objectifs => Strings.onboardingQuestionnaireObjectifsTitle,
    OnboardingQuestionnaireStep.domaine => Strings.onboardingQuestionnaireDomaineTitle,
    OnboardingQuestionnaireStep.villeRecherche => Strings.onboardingQuestionnaireVilleTitle,
    OnboardingQuestionnaireStep.freins => Strings.onboardingQuestionnaireFreinsTitle,
    OnboardingQuestionnaireStep.loader => '',
  };
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.form});

  final OnboardingQuestionnaireFormChangeNotifier form;

  @override
  Widget build(BuildContext context) {
    final hidePrimaryBecauseAutoAdvance =
        form.step == OnboardingQuestionnaireStep.situation ||
        (form.step == OnboardingQuestionnaireStep.habitation && form.draftHabitation == null) ||
        (form.step == OnboardingQuestionnaireStep.villeRecherche && form.draftVilleRecherche == null);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Margins.spacing_base,
        Margins.spacing_s,
        Margins.spacing_base,
        Margins.spacing_base,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!hidePrimaryBecauseAutoAdvance)
            DsfrButton(
              label: Strings.onboardingQuestionnaireContinue,
              variant: DsfrButtonVariant.primary,
              size: DsfrComponentSize.lg,
              onPressed: form.canContinue ? () => _onContinue(context) : null,
            ),
          const SizedBox(height: Margins.spacing_s),
          Center(
            child: DsfrButton(
              label: Strings.onboardingQuestionnaireSkip,
              variant: DsfrButtonVariant.tertiaryWithoutBorder,
              size: DsfrComponentSize.lg,
              onPressed: () => form.skipStep(),
            ),
          ),
        ],
      ),
    );
  }

  void _onContinue(BuildContext context) {
    if (form.step == OnboardingQuestionnaireStep.dateNaissance && form.isBirthDateUnderMinimumAge) {
      Navigator.of(context).push(OnboardingQuestionnaireUnderAgePage.materialPageRoute());
      return;
    }
    form.continueStep();
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({
    required this.form,
    required this.communesRepository,
  });

  final OnboardingQuestionnaireFormChangeNotifier form;
  final CommunesRepository communesRepository;

  @override
  Widget build(BuildContext context) {
    return switch (form.step) {
      OnboardingQuestionnaireStep.prenom => OnboardingQuestionnairePrenomStep(form: form),
      OnboardingQuestionnaireStep.dateNaissance => OnboardingQuestionnaireBirthdateStep(form: form),
      OnboardingQuestionnaireStep.habitation => OnboardingQuestionnaireLocationStep(
        form: form,
        communesRepository: communesRepository,
        isHabitation: true,
      ),
      OnboardingQuestionnaireStep.situation => OnboardingQuestionnaireSituationStep(form: form),
      OnboardingQuestionnaireStep.objectifs => OnboardingQuestionnaireObjectifsStep(form: form),
      OnboardingQuestionnaireStep.domaine => OnboardingQuestionnaireDomaineStep(form: form),
      OnboardingQuestionnaireStep.villeRecherche => OnboardingQuestionnaireLocationStep(
        form: form,
        communesRepository: communesRepository,
        isHabitation: false,
      ),
      OnboardingQuestionnaireStep.freins => OnboardingQuestionnaireFreinsStep(form: form),
      OnboardingQuestionnaireStep.loader => const SizedBox.shrink(),
    };
  }
}
