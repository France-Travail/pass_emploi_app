import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/events/list/event_list_actions.dart';
import 'package:pass_emploi_app/presentation/auto_inscription_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/confetti_wrapper.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/retry.dart';
import 'package:pass_emploi_app/widgets/success/bottom_actions.dart';
import 'package:pass_emploi_app/widgets/success/success_illustration.dart';

class AutoInscriptionPage extends StatelessWidget {
  const AutoInscriptionPage({super.key});

  static Route<bool?> route() {
    return MaterialPageRoute<bool?>(
      fullscreenDialog: true,
      builder: (_) => const AutoInscriptionPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiWrapper(
      builder: (context, confettiController) {
        return StoreConnector<AppState, AutoInscriptionViewModel>(
          converter: (store) => AutoInscriptionViewModel.create(store),
          builder: (context, vm) => _Builder(vm),
          onWillChange: (oldVm, newVm) => _onWillChange(oldVm, newVm, confettiController),
          onDispose: (store) => store.dispatch(EventListRequestAction(DateTime.now(), forceRefresh: true)),
          distinct: true,
        );
      },
    );
  }

  void _onWillChange(
    AutoInscriptionViewModel? oldVm,
    AutoInscriptionViewModel newVm,
    ConfettiController confettiController,
  ) {
    if (newVm.displayState == DisplayState.CONTENT && oldVm?.displayState != DisplayState.CONTENT) {
      confettiController.play();
    }
  }
}

class _Builder extends StatelessWidget {
  const _Builder(this.vm);
  final AutoInscriptionViewModel vm;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = DsfrColorDecisions.backgroundDefaultGrey(context);
    return Theme(
      data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: SecondaryAppBar(
          title: Strings.demandeInscriptionConfirmationTitle,
          backgroundColor: backgroundColor,
        ),
        body: switch (vm.displayState) {
          DisplayState.CONTENT => _Content(vm),
          DisplayState.FAILURE => _Failure(vm),
          _ => _Loading(),
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final AutoInscriptionViewModel vm;

  const _Content(this.vm);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: DsfrSpacings.s3w),
                    const SuccessIllustration(size: 160),
                    const SizedBox(height: DsfrSpacings.s3w),
                    Semantics(
                      header: true,
                      child: Text(
                        vm.eventTitle,
                        textAlign: TextAlign.center,
                        style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
                      ),
                    ),
                    const SizedBox(height: DsfrSpacings.s1w),
                    Text(
                      Strings.autoInscriptionContent,
                      textAlign: TextAlign.center,
                      style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                    ),
                  ],
                ),
              ),
            ),
            BottomActions(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: DsfrButton(
                    label: Strings.consulterAutresEvennements,
                    variant: DsfrButtonVariant.primary,
                    size: DsfrComponentSize.md,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _Failure extends StatelessWidget {
  _Failure(this.vm);
  final AutoInscriptionViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Retry(
      vm.errorMessage ?? "",
      () => Navigator.of(context).pop(),
      buttonLabel: Strings.demandeInscriptionErrorButton,
    );
  }
}
