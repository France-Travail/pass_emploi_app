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

class _CreateDemarcheFormState extends State<CreateDemarcheForm> {
  late final CreateDemarcheFormChangeNotifier _changeNotifier;

  @override
  void initState() {
    super.initState();
    _changeNotifier = CreateDemarcheFormChangeNotifier(
      displayState: widget.hasDemarcheIa ? CreateDemarcheIaFtStep1() : CreateDemarcheStep1Thematique(),
    );
    _changeNotifier.addListener(_onFormStateChanged);
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onBack();
      },
      child: Scaffold(
        backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
        resizeToAvoidBottomInset: false,
        appBar: _CreateDemarcheAppBar(onBackPressed: _onBack),
        body: _Body(_changeNotifier),
      ),
    );
  }
}

class _CreateDemarcheAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CreateDemarcheAppBar({required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    final backColor = DsfrColorDecisions.textTitleGrey(context);
    return AppBar(
      toolbarHeight: preferredSize.height,
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            label: Strings.back,
            child: InkWell(
              onTap: onBackPressed,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
            child: Semantics(
              header: true,
              child: Text(
                Strings.createDemarcheAppBarTitle,
                style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final CreateDemarcheFormChangeNotifier changeNotifier;

  const _Body(this.changeNotifier);

  @override
  Widget build(BuildContext context) {
    final currentStepIndex = changeNotifier.displayState.index();
    return Column(
      children: [
        if (currentStepIndex != null) ...[
          const SizedBox(height: DsfrSpacings.s2w),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
            child: AutoFocusA11y(
              key: ValueKey(changeNotifier.displayState),
              child: DsfrStepper(
                currentStep: currentStepIndex + 1,
                stepsCount: CreateDemarcheDisplayState.stepsTotalCount,
                stepTitle: _stepTitle,
              ),
            ),
          ),
        ],
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
            child: AnimatedSwitcher(
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
            ),
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
