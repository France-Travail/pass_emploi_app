import 'package:flutter/foundation.dart';
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
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_over_age_page.dart';
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
import 'package:pass_emploi_app/ui/theme.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';
import 'package:redux/redux.dart';

class OnboardingQuestionnairePage extends StatefulWidget {
  final bool editMode;

  const OnboardingQuestionnairePage({super.key, this.editMode = false});

  static MaterialPageRoute<void> materialPageRoute({bool editMode = true}) {
    return MaterialPageRoute(
      builder: (_) => OnboardingQuestionnairePage(editMode: editMode),
    );
  }

  @override
  State<OnboardingQuestionnairePage> createState() =>
      _OnboardingQuestionnairePageState();
}

class _OnboardingQuestionnairePageState
    extends State<OnboardingQuestionnairePage>
    with WidgetsBindingObserver {
  late final OnboardingQuestionnaireFormChangeNotifier _form;
  late final CommunesRepository _communesRepository;
  late final OnboardingQuestionnaireTracker _tracker;
  bool _formInitialized = false;
  OnboardingQuestionnaireStep? _lastAnnouncedStep;
  bool _keyboardOpen = false;

  @override
  void initState() {
    super.initState();
    _communesRepository = CommunesRepository();
    WidgetsBinding.instance.addObserver(this);
  }

  // Au premier lancement, la page est affichée dans le Scaffold racine de l'app, qui retire déjà la hauteur du
  // clavier de MediaQuery : le clavier est lu sur la vue, à chaque changement de dimensions.
  @override
  void didChangeMetrics() {
    if (!mounted) return;
    final open = A11yUtils.isKeyboardVisible(context);
    if (open != _keyboardOpen) setState(() => _keyboardOpen = open);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _keyboardOpen = A11yUtils.isKeyboardVisible(context);
    if (_formInitialized) return;
    _formInitialized = true;
    final store = StoreProvider.of<AppState>(context);
    final questionnaireState = store.state.onboardingQuestionnaireState;
    _tracker = OnboardingQuestionnaireTracker(
      isUpdate:
          questionnaireState is OnboardingQuestionnaireSuccessState &&
          questionnaireState.everFinished,
    );
    _form = OnboardingQuestionnaireFormChangeNotifier(
      loadAnswers: () async {
        final questionnaireState = store.state.onboardingQuestionnaireState;
        if (questionnaireState is OnboardingQuestionnaireSuccessState)
          return questionnaireState.answers;
        return const OnboardingQuestionnaireAnswers();
      },
      saveAnswers: (answers) async {
        store.dispatch(OnboardingQuestionnaireAnswersUpdatedAction(answers));
      },
      startAtFirstStep: widget.editMode,
      skipActionPlanGeneration: widget.editMode,
      withPrenomStep: store.state.isInviteLoginMode(),
      tracker: _tracker,
      onFinishWithoutGeneration: (answers) {
        store.dispatch(OnboardingQuestionnaireCompleteAction(answers));
        if (widget.editMode) {
          store.dispatch(OnboardingQuestionnaireFinishAction(answers));
          if (context.mounted) Navigator.of(context).pop();
        }
      },
    );
    _form.addListener(_announceStepIfChanged);
    _form.init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_formInitialized) _form.dispose();
    super.dispose();
  }

  // A11y 10.2 : sur Android, le focus TalkBack ne bouge pas tout seul (AutoFocusA11y sans effet) :
  // l'ouverture et chaque vraie transition d'étape sont donc annoncées.
  void _announceStepIfChanged() {
    final step = _form.step;
    if (_form.isLoading || step.isLoader || step == _lastAnnouncedStep) return;
    _lastAnnouncedStep = step;
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final annonce = Strings.onboardingQuestionnaireStepA11y(
      _form.stepNumber,
      _form.stepsCount,
      _stepTitle(step),
    );
    // Laisse TalkBack finir de lire le nouveau focus (« Retour ») avant d'annoncer l'étape.
    Future.delayed(AnimationDurations.slow, () {
      if (mounted && _form.step == step) A11yUtils.announce(annonce);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final keyboardOpen = _keyboardOpen;
    return Theme(
      data: isDarkMode ? PassEmploiTheme.darkData : PassEmploiTheme.data,
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
              backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(
                context,
              ),
              appBar: _form.step.isLoader
                  ? null
                  : OnboardingQuestionnaireAppBar(onBack: _onBack),
              body: SafeArea(
                child: _form.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _form.step.isLoader
                    ? OnboardingQuestionnaireLoaderStep(
                        answers: _form.savedAnswers,
                      )
                    : _QuestionnaireBody(
                        form: _form,
                        communesRepository: _communesRepository,
                        keyboardOpen: keyboardOpen,
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
      // pop() et non maybePop() : le PopScope (canPop: false) renverrait vers _onBack, en boucle.
      Navigator.of(context).pop();
      return;
    }
    final store = StoreProvider.of<AppState>(context);
    final questionnaireState = store.state.onboardingQuestionnaireState;
    // A11y 5.3 : rouvert depuis l'Accueil, le questionnaire se ferme sans déconnecter l'utilisateur.
    if (questionnaireState is OnboardingQuestionnaireSuccessState &&
        questionnaireState.resumedFromApp) {
      store.dispatch(OnboardingQuestionnaireCloseResumedAction());
    } else {
      _confirmLogout(store);
    }
  }

  // Parcours obligatoire : revenir en arrière déconnecte, on demande donc confirmation avant.
  Future<void> _confirmLogout(Store<AppState> store) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: DsfrColorDecisions.backgroundTransparent(context),
      barrierColor: DsfrColorDecisions.backgroundOverlayGrey(context),
      barrierLabel: Strings.bottomSheetBarrierLabel,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Theme(
        data: Theme.of(context).brightness == Brightness.dark
            ? PassEmploiTheme.darkData
            : PassEmploiTheme.data,
        child: DsfrModal(
          isDismissible: true,
          closeLabel: Strings.close,
          child: const _LogoutConfirmation(),
        ),
      ),
    );
    if (confirmed == true)
      store.dispatch(RequestLogoutAction(LogoutReason.userLogout));
  }
}

class _LogoutConfirmation extends StatelessWidget {
  const _LogoutConfirmation();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A11y : le titre est un en-tête et reçoit le focus du lecteur d'écran à l'ouverture.
        AutoFocusA11y(
          child: Semantics(
            header: true,
            child: Text(
              Strings.onboardingQuestionnaireLogoutTitle,
              style: DsfrTextStyle.headline4(
                color: DsfrColorDecisions.textTitleGrey(context),
              ),
            ),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        Text(
          Strings.onboardingQuestionnaireLogoutContent,
          style: DsfrTextStyle.bodyMd(
            color: DsfrColorDecisions.textDefaultGrey(context),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s4w),
        DsfrButton(
          label: Strings.onboardingQuestionnaireLogoutConfirm,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: () => Navigator.pop(context, true),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrButton(
          label: Strings.onboardingQuestionnaireLogoutCancel,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.lg,
          onPressed: () => Navigator.pop(context, false),
        ),
      ],
    );
  }
}

String _stepTitle(OnboardingQuestionnaireStep step) => switch (step) {
  OnboardingQuestionnaireStep.prenom =>
    Strings.onboardingQuestionnairePrenomTitle,
  OnboardingQuestionnaireStep.dateNaissance =>
    Strings.onboardingQuestionnaireBirthdateTitle,
  OnboardingQuestionnaireStep.habitation =>
    Strings.onboardingQuestionnaireHabitationTitle,
  OnboardingQuestionnaireStep.situation =>
    Strings.onboardingQuestionnaireSituationTitle,
  OnboardingQuestionnaireStep.objectifs =>
    Strings.onboardingQuestionnaireObjectifsTitle,
  OnboardingQuestionnaireStep.domaine =>
    Strings.onboardingQuestionnaireDomaineTitle,
  OnboardingQuestionnaireStep.villeRecherche =>
    Strings.onboardingQuestionnaireVilleTitle,
  OnboardingQuestionnaireStep.freins =>
    Strings.onboardingQuestionnaireFreinsTitle,
  OnboardingQuestionnaireStep.loader => '',
};

class _QuestionnaireBody extends StatefulWidget {
  const _QuestionnaireBody({
    required this.form,
    required this.communesRepository,
    required this.keyboardOpen,
  });

  final OnboardingQuestionnaireFormChangeNotifier form;
  final CommunesRepository communesRepository;
  final bool keyboardOpen;

  @override
  State<_QuestionnaireBody> createState() => _QuestionnaireBodyState();
}

class _QuestionnaireBodyState extends State<_QuestionnaireBody> {
  // Les clés gardent l'en-tête, l'étape (et le champ qui a le focus) et les boutons quand la mise en page change.
  final GlobalKey _headerKey = GlobalKey();
  final GlobalKey _contentKey = GlobalKey();
  final GlobalKey _actionsKey = GlobalKey();
  // Garde la position de défilement quand la mise en page change (sinon la page repart en haut à la fermeture du clavier).
  final GlobalKey _scrollKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    final header = Padding(
      key: _headerKey,
      padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_base),
      // A11y 10.2 : à chaque changement d'étape, le focus du lecteur d'écran part du bouton
      // « Continuer » pour aller sur le titre de la nouvelle étape.
      child: AutoFocusA11y(
        key: ValueKey(form.step),
        // Sur Android, l'étape est annoncée par la page (voir _announceStepIfChanged).
        enabled: defaultTargetPlatform != TargetPlatform.android,
        duration: AnimationDurations.slow,
        // A11y 10.2.3 : « Étape X sur Y, titre » restitué en un seul en-tête.
        child: Semantics(
          header: true,
          label: Strings.onboardingQuestionnaireStepA11y(
            form.stepNumber,
            form.stepsCount,
            _stepTitle(form.step),
          ),
          excludeSemantics: true,
          child: DsfrStepper(
            currentStep: form.stepNumber,
            stepsCount: form.stepsCount,
            stepTitle: _stepTitle(form.step),
          ),
        ),
      ),
    );
    final content = AnimatedSwitcher(
      key: _contentKey,
      duration: AnimationDurations.slow,
      switchInCurve: Curves.linear,
      switchOutCurve: Curves.linear,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            // A11y : l'étape précédente, encore affichée pendant le fondu, ne doit plus être
            // atteignable par le lecteur d'écran.
            // La clé conserve l'élément de l'étape sortante : sans elle, elle serait reconstruite avec la nouvelle étape.
            ...previousChildren.map(
              (child) => ExcludeSemantics(key: child.key, child: child),
            ),
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
        child: _StepContent(
          step: form.step,
          form: form,
          communesRepository: widget.communesRepository,
        ),
      ),
    );
    final actions = _BottomActions(key: _actionsKey, form: form);

    // A11y 8.2 et 11.9 : clavier ouvert (paysage, texte agrandi, petit téléphone), il ne reste presque plus de
    // place entre l'en-tête et les boutons fixes. Tout défile alors d'un bloc et le champ reste visible.
    if (widget.keyboardOpen) {
      return SingleChildScrollView(
        key: _scrollKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            Padding(
              padding: const EdgeInsets.all(Margins.spacing_base),
              child: content,
            ),
            actions,
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Expanded(
          child: SingleChildScrollView(
            key: _scrollKey,
            padding: const EdgeInsets.all(Margins.spacing_base),
            child: content,
          ),
        ),
        actions,
      ],
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({super.key, required this.form});

  final OnboardingQuestionnaireFormChangeNotifier form;

  @override
  Widget build(BuildContext context) {
    // A11y 5.3 : plus aucune étape n'avance seule, « Continuer » est donc toujours proposé.
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
    if (form.step == OnboardingQuestionnaireStep.dateNaissance &&
        form.isBirthDateUnderMinimumAge) {
      Navigator.of(
        context,
      ).push(OnboardingQuestionnaireUnderAgePage.materialPageRoute());
      return;
    }
    if (form.step == OnboardingQuestionnaireStep.dateNaissance &&
        form.isBirthDateOverMaximumAge) {
      Navigator.of(
        context,
      ).push(OnboardingQuestionnaireOverAgePage.materialPageRoute());
      return;
    }
    form.continueStep();
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({
    required this.step,
    required this.form,
    required this.communesRepository,
  });

  final OnboardingQuestionnaireStep step;
  final OnboardingQuestionnaireFormChangeNotifier form;
  final CommunesRepository communesRepository;

  @override
  Widget build(BuildContext context) {
    return switch (step) {
      OnboardingQuestionnaireStep.prenom => OnboardingQuestionnairePrenomStep(
        form: form,
      ),
      OnboardingQuestionnaireStep.dateNaissance =>
        OnboardingQuestionnaireBirthdateStep(form: form),
      OnboardingQuestionnaireStep.habitation =>
        OnboardingQuestionnaireLocationStep(
          form: form,
          communesRepository: communesRepository,
          isHabitation: true,
        ),
      OnboardingQuestionnaireStep.situation =>
        OnboardingQuestionnaireSituationStep(form: form),
      OnboardingQuestionnaireStep.objectifs =>
        OnboardingQuestionnaireObjectifsStep(form: form),
      OnboardingQuestionnaireStep.domaine => OnboardingQuestionnaireDomaineStep(
        form: form,
      ),
      OnboardingQuestionnaireStep.villeRecherche =>
        OnboardingQuestionnaireLocationStep(
          form: form,
          communesRepository: communesRepository,
          isHabitation: false,
        ),
      OnboardingQuestionnaireStep.freins => OnboardingQuestionnaireFreinsStep(
        form: form,
      ),
      OnboardingQuestionnaireStep.loader => const SizedBox.shrink(),
    };
  }
}
