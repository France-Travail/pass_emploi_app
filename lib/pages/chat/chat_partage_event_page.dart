import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/presentation/chat/chat_partage_event_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/confetti_wrapper.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/retry.dart';
import 'package:pass_emploi_app/widgets/success/bottom_actions.dart';
import 'package:pass_emploi_app/widgets/success/success_illustration.dart';

class ChatPartageEventPage extends StatelessWidget {
  const ChatPartageEventPage({super.key});

  static Route<bool?> route() {
    return MaterialPageRoute<bool?>(
      fullscreenDialog: true,
      builder: (_) => const ChatPartageEventPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiWrapper(builder: (context, confettiController) {
      return StoreConnector<AppState, ChatPartageEventViewModel>(
        converter: (store) => ChatPartageEventViewModel.create(store),
        builder: (context, vm) => _Builder(vm),
        onWillChange: (oldVm, newVm) => _onWillChange(oldVm, newVm, confettiController),
        distinct: true,
      );
    });
  }

  void _onWillChange(
    ChatPartageEventViewModel? oldVm,
    ChatPartageEventViewModel newVm,
    ConfettiController confettiController,
  ) {
    if (newVm.displayState == DisplayState.CONTENT && oldVm?.displayState != DisplayState.CONTENT) {
      confettiController.play();
    }
  }
}

class _Builder extends StatelessWidget {
  const _Builder(this.vm);
  final ChatPartageEventViewModel vm;

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
          DisplayState.CONTENT => const _Content(),
          DisplayState.FAILURE => _Failure(),
          _ => _Loading(),
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

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
                        Strings.demandeInscriptionDescription,
                        textAlign: TextAlign.center,
                        style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
                      ),
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
  @override
  Widget build(BuildContext context) {
    return Retry(
      Strings.demandeInscriptionError,
      () => Navigator.of(context).pop(),
      buttonLabel: Strings.demandeInscriptionErrorButton,
    );
  }
}
