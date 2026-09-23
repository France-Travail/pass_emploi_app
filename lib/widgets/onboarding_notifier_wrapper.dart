import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/models/onboarding.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/confetti_wrapper.dart';
import 'package:pass_emploi_app/widgets/snack_bar/show_snack_bar.dart';

class OnboardingNotifierWrapper extends StatefulWidget {
  final Widget child;

  const OnboardingNotifierWrapper({super.key, required this.child});

  @override
  State<OnboardingNotifierWrapper> createState() => _OnboardingNotifierWrapperState();
}

class _OnboardingNotifierWrapperState extends State<OnboardingNotifierWrapper> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Onboarding?>(
      converter: (store) => store.state.onboardingState.onboarding,
      builder: (context, viewModel) {
        return widget.child;
      },
      distinct: true,
      onDidChange: (previousOnboarding, onboarding) {
        if (previousOnboarding != null && onboarding != null && onboarding.showOnboarding) {
          if (!previousOnboarding.messageCompleted && onboarding.messageCompleted) {
            _showOnboardingSnackbar(Strings.onboardingStepFinished);
          } else if (!previousOnboarding.planActionCompleted && onboarding.planActionCompleted) {
            _showOnboardingSnackbar(Strings.onboardingStepFinished);
          } else if (!previousOnboarding.actionCompleted && onboarding.actionCompleted) {
            _showOnboardingSnackbar(Strings.onboardingStepFinished);
          } else if (!previousOnboarding.offreCompleted && onboarding.offreCompleted) {
            _showOnboardingSnackbar(Strings.onboardingStepFinished);
          } else if (!previousOnboarding.evenementCompleted && onboarding.evenementCompleted) {
            _showOnboardingSnackbar(Strings.onboardingStepFinished);
          }
        }
      },
    );
  }

  void _showOnboardingSnackbar(String message) {
    clearAllSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // a11y : le message ne disparaît pas automatiquement
        duration: const Duration(days: 365),
        margin: const EdgeInsets.all(DsfrSpacings.s2w),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        content: ConfettiWrapper(
          builder: (context, confettiController) {
            confettiController.play();
            // A11y : sans cela, la snackbar fusionne le message et la croix en un seul bouton pour le lecteur d'écran.
            return Semantics(
              container: true,
              explicitChildNodes: true,
              child: ColoredBox(
                color: DsfrColorDecisions.backgroundDefaultGrey(context),
                child: DsfrAlert(
                  type: DsfrAlertType.success,
                  description: DsfrAlertDescriptionText(message),
                  onClose: clearAllSnackBars,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
