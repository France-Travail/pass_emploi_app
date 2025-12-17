import 'package:flutter/material.dart';
import 'package:pass_emploi_app/features/demarche/create/create_demarche_actions.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche/create_demarche_app_bar_back_button.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche/pages/create_demarche_from_thematique_step_2_page.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche/pages/create_demarche_from_thematique_step_3_page.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche/pages/create_demarche_ia_ft_step_2_page.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche/pages/create_demarche_ia_ft_step_3_page.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche/pages/create_demarche_personnalisee_step_2_page.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche/pages/create_demarche_personnalisee_step_3_page.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche/pages/create_demarche_step_1_page.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche_form_page.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_form/create_demarche_form_change_notifier.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_form/create_demarche_form_display_state.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/pass_emploi_stepper.dart';

class CreateDemarcheForm extends StatefulWidget {
  const CreateDemarcheForm({
    super.key,
    this.startPoint,
    required this.onCreateDemarchePersonnalisee,
    required this.onCreateDemarcheFromReferentiel,
    required this.onCreateDemarcheIaFt,
  });

  final StartPoint? startPoint;
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
    _changeNotifier = CreateDemarcheFormChangeNotifier(displayState: widget.startPoint?.toDisplayState());
    _changeNotifier.addListener(_onFormStateChanged);
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

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: SecondaryAppBar(title: Strings.createDemarcheAppBarTitle, leading: AppBarBackButton(_changeNotifier)),
      body: _Body(_changeNotifier),
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
        SizedBox(height: Margins.spacing_base),
        if (currentStepIndex != null)
          CreateDemarcheStepper(
            stepCount: CreateDemarcheDisplayState.stepsTotalCount,
            currentStepIndex: currentStepIndex,
          ),
        Expanded(
          child: AnimatedSwitcher(
            duration: AnimationDurations.fast,
            child: Column(
              children: [
                Expanded(
                  child: switch (changeNotifier.displayState) {
                    CreateDemarcheStep1() => CreateDemarcheStep1Page(changeNotifier),
                    CreateDemarcheFromThematiqueStep2() => CreateDemarcheFromThematiqueStep2Page(changeNotifier),
                    CreateDemarchePersonnaliseeStep2() => CreateDemarchePersonnaliseeStep2Page(changeNotifier),
                    CreateDemarcheIaFtStep2() => CreateDemarcheIaFtStep2Page(changeNotifier),
                    CreateDemarcheFromThematiqueStep3() ||
                    CreateDemarcheFromThematiqueSubmitted() => CreateDemarcheFromThematiqueStep3Page(changeNotifier),
                    CreateDemarchePersonnaliseeStep3() ||
                    CreateDemarchePersonnaliseeSubmitted() => CreateDemarchePersonnaliseeStep3Page(changeNotifier),
                    CreateDemarcheIaFtStep3() => CreateDemarcheIaFtStep3Page(changeNotifier),
                    CreateDemarcheIaFtSubmitted() => CreateDemarcheIaFtStep3Page(changeNotifier),
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

extension StartPointExt on StartPoint? {
  CreateDemarcheDisplayState toDisplayState() {
    return switch (this) {
      StartPoint.ftIa => CreateDemarcheIaFtStep2(),
      _ => CreateDemarcheStep1(),
    };
  }
}
