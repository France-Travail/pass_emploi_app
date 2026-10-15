import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/features/demarche/create/create_demarche_actions.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche/pages/create_demarche_from_thematique_step_2_page.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche/pages/create_demarche_from_thematique_step_3_page.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche/pages/create_demarche_ia_ft_step_1_page.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche/pages/create_demarche_ia_ft_step_2_page.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche/pages/create_demarche_personnalisee_step_2_page.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche/pages/create_demarche_personnalisee_step_3_page.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche/pages/create_demarche_step_1_page.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_form/create_demarche_form_change_notifier.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_form/create_demarche_form_display_state.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';

class CreateDemarcheForm extends StatefulWidget {
  const CreateDemarcheForm({
    super.key,
    required this.hasDemarcheIa,
    required this.onCreateDemarchePersonnalisee,
    required this.onCreateDemarcheFromReferentiel,
    required this.onCreateDemarcheIaFt,
  });

  final bool hasDemarcheIa;
  final void Function(CreateDemarchePersonnaliseeRequestAction) onCreateDemarchePersonnalisee;
  final void Function(CreateDemarcheRequestAction) onCreateDemarcheFromReferentiel;
  final void Function(List<CreateDemarcheRequestAction>) onCreateDemarcheIaFt;

  @override
  State<CreateDemarcheForm> createState() => _CreateDemarcheFormState();
}

class _CreateDemarcheFormState extends State<CreateDemarcheForm> with WidgetsBindingObserver {
  late final CreateDemarcheFormChangeNotifier _changeNotifier;
  bool _keyboardOpen = false;

  @override
  void initState() {
    super.initState();
    _changeNotifier = CreateDemarcheFormChangeNotifier(
      displayState: widget.hasDemarcheIa ? CreateDemarcheIaFtStep1() : CreateDemarcheStep1Thematique(),
    );
    _changeNotifier.addListener(_onFormStateChanged);
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
    _changeNotifier.removeListener(_onFormStateChanged);
    _changeNotifier.dispose();
    super.dispose();
  }

  void _onFormStateChanged() {
    final displayState = _changeNotifier.displayState;
    if (displayState is CreateDemarcheFromThematiqueSubmitted) {
      widget.onCreateDemarcheFromReferentiel(_changeNotifier.createDemarcheRequestAction());
    }

    if (displayState is CreateDemarchePersonnaliseeSubmitted) {
      widget.onCreateDemarchePersonnalisee(_changeNotifier.createDemarchePersonnaliseeRequestAction());
    }

    if (displayState is CreateDemarcheIaFtSubmitted) {
      widget.onCreateDemarcheIaFt(displayState.createRequests);
    }

    if (mounted) setState(() {});
  }

  void _onBack() {
    if (MediaQuery.viewInsetsOf(context).bottom > 0) {
      FocusScope.of(context).unfocus();
      return;
    }
    if (_changeNotifier.displayState is CreateDemarcheStep1) {
      Navigator.pop(context);
    } else {
      _changeNotifier.onNavigateBackward();
    }
  }

  // Les clés gardent la barre et l'étape (et le champ qui a le focus) quand la mise en page change.
  final GlobalKey _appBarKey = GlobalKey();
  final GlobalKey _bodyKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = _keyboardOpen || MediaQuery.viewInsetsOf(context).bottom > 0;
    final appBar = _CreateDemarcheAppBar(
      key: _appBarKey,
      onBackPressed: _onBack,
      displayState: _changeNotifier.displayState,
      // A11y 8.2 : la hauteur suit la taille de texte choisie dans les réglages.
      height: MediaQuery.textScalerOf(context).scale(76),
    );
    final body = _Body(_changeNotifier, key: _bodyKey, scrollsWithPage: keyboardOpen);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onBack();
      },
      // A11y 8.2 et 11.9 : clavier ouvert, la barre et l'étape défilent d'un bloc au-dessus du clavier pour que
      // le champ en cours de saisie reste visible ; clavier fermé, rien ne change.
      child: keyboardOpen
          ? Scaffold(
              backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [appBar, body],
                ),
              ),
            )
          : Scaffold(
              backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
              resizeToAvoidBottomInset: false,
              appBar: appBar,
              body: body,
            ),
    );
  }
}

class _CreateDemarcheAppBar extends StatefulWidget implements PreferredSizeWidget {
  const _CreateDemarcheAppBar({
    super.key,
    required this.onBackPressed,
    required this.displayState,
    required this.height,
  });

  final double height;

  final VoidCallback onBackPressed;
  final CreateDemarcheDisplayState displayState;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<_CreateDemarcheAppBar> createState() => _CreateDemarcheAppBarState();
}

class _CreateDemarcheAppBarState extends State<_CreateDemarcheAppBar> {
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
                _appBarTitle,
                style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _appBarTitle => switch (widget.displayState) {
    CreateDemarcheIaFtStep1() ||
    CreateDemarcheIaFtStep2() ||
    CreateDemarcheIaFtSubmitted() => Strings.createDemarcheAppBarTitle,
    _ => Strings.createOneDemarcheAppBarTitle,
  };
}

class _Body extends StatelessWidget {
  final CreateDemarcheFormChangeNotifier changeNotifier;

  /// Clavier ouvert : la page entière défile, l'étape prend sa hauteur naturelle.
  final bool scrollsWithPage;

  const _Body(this.changeNotifier, {super.key, required this.scrollsWithPage});

  @override
  Widget build(BuildContext context) {
    final currentStepIndex = changeNotifier.displayState.index();
    final step = AnimatedSwitcher(
      duration: AnimationDurations.fast,
      child: Align(
        alignment: Alignment.topCenter,
        child: switch (changeNotifier.displayState) {
          CreateDemarcheStep1Thematique() => CreateDemarcheStep1Page(changeNotifier),
          CreateDemarcheIaFtStep1() => CreateDemarcheIaFtStep1Page(changeNotifier),
          CreateDemarcheFromThematiqueStep2() => CreateDemarcheFromThematiqueStep2Page(changeNotifier),
          CreateDemarchePersonnaliseeStep2() => CreateDemarchePersonnaliseeStep2Page(changeNotifier),
          CreateDemarcheIaFtStep2() => CreateDemarcheIaFtStep2Page(changeNotifier),
          CreateDemarcheFromThematiqueStep3() ||
          CreateDemarcheFromThematiqueSubmitted() => CreateDemarcheFromThematiqueStep3Page(changeNotifier),
          CreateDemarchePersonnaliseeStep3() ||
          CreateDemarchePersonnaliseeSubmitted() => CreateDemarchePersonnaliseeStep3Page(changeNotifier),
          CreateDemarcheIaFtSubmitted() => CreateDemarcheIaFtStep2Page(changeNotifier),
        },
      ),
    );
    return Column(
      mainAxisSize: scrollsWithPage ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (currentStepIndex != null) ...[
          const SizedBox(height: DsfrSpacings.s2w),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
            child: AutoFocusA11y(
              key: ValueKey(changeNotifier.displayState),
              // A11y 7.1 : « Étape X sur 3, titre » restitué en un seul en-tête.
              child: Semantics(
                header: true,
                label: Strings.onboardingQuestionnaireStepA11y(
                  currentStepIndex + 1,
                  CreateDemarcheDisplayState.stepsTotalCount,
                  _stepTitle,
                ),
                excludeSemantics: true,
                child: DsfrStepper(
                  currentStep: currentStepIndex + 1,
                  stepsCount: CreateDemarcheDisplayState.stepsTotalCount,
                  stepTitle: _stepTitle,
                ),
              ),
            ),
          ),
        ],
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

  String get _stepTitle => switch (changeNotifier.displayState) {
    CreateDemarcheStep1Thematique() => Strings.thematiquesDemarcheDescriptionShort,
    CreateDemarcheFromThematiqueStep2() ||
    CreateDemarcheFromThematiqueStep3() ||
    CreateDemarcheFromThematiqueSubmitted() => changeNotifier.step1ViewModel.selectedThematique?.title ?? "",
    CreateDemarchePersonnaliseeStep2() ||
    CreateDemarchePersonnaliseeStep3() ||
    CreateDemarchePersonnaliseeSubmitted() => Strings.createDemarchePersonnaliseeTitle,
    _ => '',
  };
}
