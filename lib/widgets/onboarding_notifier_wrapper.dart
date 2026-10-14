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
  bool _bannerVisible = false;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Onboarding?>(
      converter: (store) => store.state.onboardingState.onboarding,
      builder: (context, viewModel) {
        // Le bandeau s'affiche en haut et prend déjà en compte la barre d'état : le contenu en dessous n'a pas
        // à la compter une seconde fois.
        return MediaQuery.removePadding(context: context, removeTop: _bannerVisible, child: widget.child);
      },
      distinct: true,
      onDidChange: (previousOnboarding, onboarding) {
        if (previousOnboarding != null && onboarding != null && onboarding.showOnboarding) {
          if (!previousOnboarding.messageCompleted && onboarding.messageCompleted) {
            _showOnboardingBanner(Strings.onboardingStepFinished);
          } else if (!previousOnboarding.planActionCompleted && onboarding.planActionCompleted) {
            _showOnboardingBanner(Strings.onboardingStepFinished);
          } else if (!previousOnboarding.actionCompleted && onboarding.actionCompleted) {
            _showOnboardingBanner(Strings.onboardingStepFinished);
          } else if (!previousOnboarding.offreCompleted && onboarding.offreCompleted) {
            _showOnboardingBanner(Strings.onboardingStepFinished);
          } else if (!previousOnboarding.evenementCompleted && onboarding.evenementCompleted) {
            _showOnboardingBanner(Strings.onboardingStepFinished);
          }
        }
      },
    );
  }

  // A11y 10.2 : le message n'est plus un bandeau flottant en bas, qui recouvrait la barre d'onglets et les boutons
  // du bas d'écran, mais un bandeau en haut qui décale le contenu. Il ne disparaît toujours pas seul (11.1).
  void _showOnboardingBanner(String message) {
    clearAllSnackBars();
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearMaterialBanners();
    // A11y 10.2 : à la fermeture, le focus revient là où il était, et TalkBack avec lui.
    final previousFocus = FocusManager.instance.primaryFocus;
    // A11y 8.2 : MaterialBanner plafonne le texte à 150 % ; le bandeau garde l'agrandissement choisi.
    final textScaler = MediaQuery.textScalerOf(context);
    var confettiPlayed = false;
    setState(() => _bannerVisible = true);
    messenger.showMaterialBanner(
      MaterialBanner(
        padding: EdgeInsets.zero,
        backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
        surfaceTintColor: Colors.transparent,
        dividerColor: Colors.transparent,
        elevation: 0,
        minActionBarHeight: 0,
        // La croix de fermeture est dans l'alerte DSFR ; MaterialBanner exige au moins une action.
        actions: const [SizedBox.shrink()],
        content: ConfettiWrapper(
          builder: (bannerContext, confettiController) {
            // Les confettis ne jouent qu'une fois, même quand le bandeau est redessiné sur un autre écran.
            if (!confettiPlayed) {
              confettiPlayed = true;
              confettiController.play();
            }
            return MediaQuery(
              data: MediaQuery.of(bannerContext).copyWith(textScaler: textScaler),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(DsfrSpacings.s2w, DsfrSpacings.s1w, 0, DsfrSpacings.s1w),
                // A11y : sans cela, le message et la croix fusionnent en un seul bouton pour le lecteur d'écran.
                child: Semantics(
                  container: true,
                  explicitChildNodes: true,
                  // A11y 2.3 : la croix de l'alerte DSFR n'a qu'un voile gris au focus (1,3:1) ; le contour DSFR entoure
                  // l'alerte, dont la croix est le seul élément focalisable.
                  child: Focus(
                    canRequestFocus: false,
                    skipTraversal: true,
                    // Sans nœud d'accessibilité : il fusionnerait le message et la croix en un seul bouton.
                    includeSemantics: false,
                    child: Builder(
                      builder: (context) => DsfrFocusWidget(
                        isFocused: Focus.of(context).hasFocus,
                        child: Theme(
                          data: Theme.of(context).copyWith(focusColor: Colors.transparent),
                          child: DsfrAlert(
                            type: DsfrAlertType.success,
                            description: DsfrAlertDescriptionText(message),
                            onClose: () => _closeBanner(previousFocus),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _closeBanner(FocusNode? previousFocus) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearMaterialBanners();
    setState(() => _bannerVisible = false);
    if (previousFocus != null &&
        previousFocus is! FocusScopeNode &&
        previousFocus.context != null &&
        previousFocus.canRequestFocus) {
      previousFocus.requestFocus();
    }
  }
}
