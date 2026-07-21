import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/pages/invite_onboarding/invite_onboarding_birthdate_step.dart';
import 'package:pass_emploi_app/pages/invite_onboarding/invite_onboarding_domaine_step.dart';
import 'package:pass_emploi_app/pages/invite_onboarding/invite_onboarding_freins_step.dart';
import 'package:pass_emploi_app/pages/invite_onboarding/invite_onboarding_loader_step.dart';
import 'package:pass_emploi_app/pages/invite_onboarding/invite_onboarding_location_step.dart';
import 'package:pass_emploi_app/pages/invite_onboarding/invite_onboarding_objectifs_step.dart';
import 'package:pass_emploi_app/pages/invite_onboarding/invite_onboarding_prenom_step.dart';
import 'package:pass_emploi_app/pages/invite_onboarding/invite_onboarding_situation_step.dart';
import 'package:pass_emploi_app/presentation/invite_onboarding/invite_onboarding_form_change_notifier.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/communes_repository.dart';
import 'package:pass_emploi_app/repositories/invite_onboarding_repository.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/secure_storage_exception_handler_decorator.dart';

class InviteOnboardingPage extends StatefulWidget {
  @override
  State<InviteOnboardingPage> createState() => _InviteOnboardingPageState();
}

class _InviteOnboardingPageState extends State<InviteOnboardingPage> {
  late final InviteOnboardingFormChangeNotifier _form;
  late final CommunesRepository _communesRepository;

  @override
  void initState() {
    super.initState();
    final storage = SecureStorageExceptionHandlerDecorator(FlutterSecureStorage());
    _form = InviteOnboardingFormChangeNotifier(InviteOnboardingRepository(storage));
    _communesRepository = CommunesRepository();
    _form.init();
  }

  @override
  void dispose() {
    _form.dispose();
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
              appBar: _form.step.isLoader
                  ? null
                  : AppBar(
                      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: Icon(
                          DsfrIcons.systemArrowLeftSLine,
                          color: DsfrColorDecisions.textActionHighBlueFrance(context),
                        ),
                        onPressed: _onBack,
                      ),
                      title: Text(
                        Strings.inviteOnboardingBack,
                        style: DsfrTextStyle.bodyMdBold(
                          color: DsfrColorDecisions.textActionHighBlueFrance(context),
                        ),
                      ),
                      titleSpacing: 0,
                      centerTitle: false,
                    ),
              body: SafeArea(
                child: _form.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _form.step.isLoader
                    ? InviteOnboardingLoaderStep(answers: _form.savedAnswers)
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
    final shouldLogout = _form.goBack();
    if (shouldLogout) {
      StoreProvider.of<AppState>(context).dispatch(RequestLogoutAction(LogoutReason.userLogout));
    }
  }
}

class _QuestionnaireBody extends StatelessWidget {
  const _QuestionnaireBody({
    required this.form,
    required this.communesRepository,
  });

  final InviteOnboardingFormChangeNotifier form;
  final CommunesRepository communesRepository;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_base),
          child: DsfrStepper(
            currentStep: form.step.questionnaireIndex,
            stepsCount: InviteOnboardingStep.questionnaireCount,
            stepTitle: _stepTitle(form.step),
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
                    ...previousChildren,
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

  String _stepTitle(InviteOnboardingStep step) => switch (step) {
    InviteOnboardingStep.prenom => Strings.inviteOnboardingPrenomTitle,
    InviteOnboardingStep.dateNaissance => Strings.inviteOnboardingBirthdateTitle,
    InviteOnboardingStep.habitation => Strings.inviteOnboardingHabitationTitle,
    InviteOnboardingStep.situation => Strings.inviteOnboardingSituationTitle,
    InviteOnboardingStep.objectifs => Strings.inviteOnboardingObjectifsTitle,
    InviteOnboardingStep.domaine => Strings.inviteOnboardingDomaineTitle,
    InviteOnboardingStep.villeRecherche => Strings.inviteOnboardingVilleTitle,
    InviteOnboardingStep.freins => Strings.inviteOnboardingFreinsTitle,
    InviteOnboardingStep.loader => '',
  };
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.form});

  final InviteOnboardingFormChangeNotifier form;

  @override
  Widget build(BuildContext context) {
    final hidePrimaryBecauseAutoAdvance =
        form.step == InviteOnboardingStep.situation ||
        (form.step == InviteOnboardingStep.habitation && form.draftHabitation == null) ||
        (form.step == InviteOnboardingStep.villeRecherche && form.draftVilleRecherche == null);

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
              label: Strings.inviteOnboardingContinue,
              variant: DsfrButtonVariant.primary,
              size: DsfrComponentSize.lg,
              onPressed: form.canContinue ? () => form.continueStep() : null,
            ),
          const SizedBox(height: Margins.spacing_s),
          Center(
            child: DsfrButton(
              label: Strings.inviteOnboardingSkip,
              variant: DsfrButtonVariant.tertiaryWithoutBorder,
              size: DsfrComponentSize.lg,
              onPressed: () => form.skipStep(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({
    required this.form,
    required this.communesRepository,
  });

  final InviteOnboardingFormChangeNotifier form;
  final CommunesRepository communesRepository;

  @override
  Widget build(BuildContext context) {
    return switch (form.step) {
      InviteOnboardingStep.prenom => InviteOnboardingPrenomStep(form: form),
      InviteOnboardingStep.dateNaissance => InviteOnboardingBirthdateStep(form: form),
      InviteOnboardingStep.habitation => InviteOnboardingLocationStep(
        form: form,
        communesRepository: communesRepository,
        isHabitation: true,
      ),
      InviteOnboardingStep.situation => InviteOnboardingSituationStep(form: form),
      InviteOnboardingStep.objectifs => InviteOnboardingObjectifsStep(form: form),
      InviteOnboardingStep.domaine => InviteOnboardingDomaineStep(form: form),
      InviteOnboardingStep.villeRecherche => InviteOnboardingLocationStep(
        form: form,
        communesRepository: communesRepository,
        isHabitation: false,
      ),
      InviteOnboardingStep.freins => InviteOnboardingFreinsStep(form: form),
      InviteOnboardingStep.loader => const SizedBox.shrink(),
    };
  }
}
