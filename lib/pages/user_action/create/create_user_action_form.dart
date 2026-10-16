import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/user_action_type.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_form_step1.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_form_step2.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_form_step3.dart';
import 'package:pass_emploi_app/presentation/user_action/creation_form/create_user_action_form_view_model.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';

class CreateUserActionForm extends StatefulWidget {
  const CreateUserActionForm({super.key, required this.onSubmit, required this.onAbort});

  final void Function(CreateUserActionFormViewModel viewModel) onSubmit;
  final void Function() onAbort;

  @override
  State<CreateUserActionForm> createState() => _CreateUserActionFormState();
}

class _CreateUserActionFormState extends State<CreateUserActionForm> with WidgetsBindingObserver {
  late final CreateUserActionFormViewModel _viewModel;
  bool _keyboardOpen = false;
  // Les clés gardent la barre et l'étape (et le champ qui a le focus) quand la mise en page change.
  final GlobalKey _appBarKey = GlobalKey();
  final GlobalKey _formKey = GlobalKey();
  final GlobalKey _stepKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _viewModel = CreateUserActionFormViewModel();
    _viewModel.addListener(_onFormStateChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  // Le clavier est lu sur la vue, à chaque changement de dimensions : la page peut être affichée sous un Scaffold
  // qui a déjà retiré sa hauteur de MediaQuery.
  @override
  void didChangeMetrics() {
    if (!mounted) return;
    final open = A11yUtils.isKeyboardVisible(context);
    if (open != _keyboardOpen) setState(() => _keyboardOpen = open);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.removeListener(_onFormStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onFormStateChanged() {
    if (_viewModel.isAborted) {
      widget.onAbort();
      return;
    }
    if (_viewModel.isSubmitted) {
      widget.onSubmit(_viewModel);
    }
    if (mounted) setState(() {});
  }

  void _onBack() {
    if (MediaQuery.viewInsetsOf(context).bottom > 0) {
      FocusScope.of(context).unfocus();
      return;
    }
    _viewModel.viewChangedBackward();
  }

  void _onGoForward() {
    final wasLastStep = _viewModel.displayState == CreateUserActionDisplayState.step3;
    _viewModel.viewChangedForward();
    // A11y 5.4 / 9.9 : l'erreur affichée quand on valide un formulaire incomplet est annoncée.
    if (wasLastStep && !_viewModel.isSubmitted) A11yUtils.announce(Strings.fillAllFields);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = _keyboardOpen || MediaQuery.viewInsetsOf(context).bottom > 0;
    final appBar = _CreateUserActionAppBar(
      key: _appBarKey,
      onBackPressed: _onBack,
      // A11y 8.2 : la hauteur suit la taille de texte choisie dans les réglages.
      height: MediaQuery.textScalerOf(context).scale(76),
    );
    final form = _CreateUserActionForm(_viewModel, key: _formKey, stepKey: _stepKey, scrollsWithPage: keyboardOpen);
    // A11y 8.5 : les boutons ne recouvrent plus le formulaire. Le corps s'arrête au-dessus d'eux,
    // donc le focus lecteur d'écran / clavier ne peut plus être masqué par les boutons.
    final navButtons = _viewModel.shouldDisplayNavigationButtons
        ? _NavButtons(
            displayState: _viewModel.displayState,
            onGoBackPressed: _onBack,
            onGoForwardPressed: _viewModel.canGoForward ? _onGoForward : null,
          )
        : null;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onBack();
      },
      // A11y 8.2 et 11.9 : clavier ouvert, la barre, l'étape et les boutons défilent d'un bloc au-dessus du
      // clavier pour que le champ en cours de saisie reste visible ; clavier fermé, rien ne change.
      child: keyboardOpen
          ? Scaffold(
              backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
              body: SingleChildScrollView(
                // Le défilement de l'étape garde le contrôleur principal : s'il le perdait, il serait reconstruit
                // avec tout son contenu et le champ touché perdrait le focus.
                primary: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [appBar, form, if (navButtons != null) navButtons],
                ),
              ),
            )
          : Scaffold(
              backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
              resizeToAvoidBottomInset: false,
              appBar: appBar,
              body: form,
              bottomNavigationBar: navButtons,
            ),
    );
  }
}

class _CreateUserActionAppBar extends StatefulWidget implements PreferredSizeWidget {
  const _CreateUserActionAppBar({super.key, required this.onBackPressed, required this.height});

  final VoidCallback onBackPressed;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<_CreateUserActionAppBar> createState() => _CreateUserActionAppBarState();
}

class _CreateUserActionAppBarState extends State<_CreateUserActionAppBar> {
  bool _backFocused = false;

  @override
  Widget build(BuildContext context) {
    final onBackPressed = widget.onBackPressed;
    final backColor = DsfrColorDecisions.textTitleGrey(context);
    return AppBar(
      toolbarHeight: widget.preferredSize.height,
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      centerTitle: false,
      // A11y : l'AppBar marquerait tout le bloc (bouton Retour compris) comme en-tête ;
      // seul le titre porte ce rôle, via son propre Semantics(header).
      excludeHeaderSemantics: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            container: true,
            button: true,
            label: Strings.back,
            onTap: onBackPressed,
            excludeSemantics: true,
            // A11y 2.3 : contour de focus DSFR à la place du voile gris de Material.
            child: DsfrFocusWidget(
              isFocused: _backFocused,
              child: InkWell(
                onTap: onBackPressed,
                focusColor: DsfrColorDecisions.backgroundTransparent(context),
                onFocusChange: (focused) => setState(() => _backFocused = focused),
                child: Padding(
                  padding: const EdgeInsets.only(left: DsfrSpacings.s1w, right: DsfrSpacings.s3v),
                  child: Row(
                    children: [
                      Icon(DsfrIcons.systemArrowLeftSLine, color: backColor, size: 32),
                      Expanded(
                        child: Text(
                          Strings.back,
                          style: DsfrTextStyle.bodyMdBold(color: backColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
            child: Semantics(
              header: true,
              child: Text(
                Strings.createActionAppBarTitle,
                style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButtons extends StatelessWidget {
  const _NavButtons({
    required this.displayState,
    required this.onGoBackPressed,
    required this.onGoForwardPressed,
  });

  final CreateUserActionDisplayState displayState;
  final void Function()? onGoBackPressed;
  final void Function()? onGoForwardPressed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DsfrColorDecisions.backgroundDefaultGrey(context),
      child: Padding(
        padding: EdgeInsets.only(
          top: DsfrSpacings.s4w,
          left: DsfrSpacings.s2w,
          right: DsfrSpacings.s2w,
          bottom: MediaQuery.of(context).padding.bottom + DsfrSpacings.s2w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: double.infinity,
              child: DsfrButton(
                label: displayState.nextLabel,
                variant: DsfrButtonVariant.primary,
                size: DsfrComponentSize.md,
                onPressed: onGoForwardPressed,
              ),
            ),
            const SizedBox(height: DsfrSpacings.s2w),
            SizedBox(
              width: double.infinity,
              child: DsfrButton(
                label: Strings.back,
                variant: DsfrButtonVariant.secondary,
                size: DsfrComponentSize.md,
                foregroundColor: DsfrColorDecisions.textTitleGrey(context),
                onPressed: onGoBackPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateUserActionForm extends StatelessWidget {
  const _CreateUserActionForm(this.formState, {super.key, required this.stepKey, required this.scrollsWithPage});

  final CreateUserActionFormViewModel formState;

  /// Garde l'étape quand elle sort de son [Expanded] : sans elle, l'étape serait recréée à l'ouverture du clavier,
  /// le champ touché perdrait le focus et le clavier se refermerait aussitôt.
  final GlobalKey stepKey;

  /// Clavier ouvert : la page entière défile, l'étape prend sa hauteur naturelle.
  final bool scrollsWithPage;

  @override
  Widget build(BuildContext context) {
    final step = AnimatedSwitcher(
      key: stepKey,
      duration: AnimationDurations.fast,
      child: Align(
        alignment: Alignment.topCenter,
        child: switch (formState.displayState) {
          CreateUserActionDisplayState.step1 => CreateUserActionFormStep1(
            onActionTypeSelected: (type) => formState.userActionTypeSelected(type),
          ),
          CreateUserActionDisplayState.step2 => CreateUserActionFormStep2(
            actionType: formState.step1.actionCategory!,
            viewModel: formState.step2,
            onTitleChanged: (titleSource) => formState.titleChanged(titleSource),
            onDescriptionChanged: (description) => formState.descriptionChanged(description),
          ),
          CreateUserActionDisplayState.step3 => CreateUserActionFormStep3(
            actionType: formState.step1.actionCategory!,
            viewModel: formState.step3,
            onDateChanged: (id, dateSource) => formState.duplicateUserActionDateChanged(id, dateSource),
            onDescriptionChanged: (id, description) => formState.duplicateUserActionDescriptionChanged(id, description),
            onDelete: (id) => formState.deleteDuplicatedUserAction(id),
            onAddDuplicatedUserAction: () => formState.addDuplicatedUserAction(),
            titleSource: formState.step2.titleSource,
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
    return Column(
      mainAxisSize: scrollsWithPage ? MainAxisSize.min : MainAxisSize.max,
      children: [
        const SizedBox(height: DsfrSpacings.s2w),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
          child: AutoFocusA11y(
            key: ValueKey(formState.displayState),
            // A11y 7.1 : « Étape X sur 3, titre » restitué en un seul en-tête.
            child: Semantics(
              header: true,
              label: Strings.onboardingQuestionnaireStepA11y(
                formState.displayState.stepIndex + 1,
                CreateUserActionDisplayState.stepCount,
                _stepTitle,
              ),
              excludeSemantics: true,
              child: DsfrStepper(
                currentStep: formState.displayState.stepIndex + 1,
                stepsCount: CreateUserActionDisplayState.stepCount,
                stepTitle: _stepTitle,
              ),
            ),
          ),
        ),
        if (scrollsWithPage)
          step
        else
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
              child: step,
            ),
          ),
      ],
    );
  }

  String get _stepTitle => switch (formState.displayState) {
    CreateUserActionDisplayState.step1 => Strings.thematiquesDemarcheDescriptionShort,
    CreateUserActionDisplayState.step2 => formState.step1.actionCategory!.label,
    CreateUserActionDisplayState.step3 => Strings.userActionTitleStep3,
    _ => '',
  };
}
