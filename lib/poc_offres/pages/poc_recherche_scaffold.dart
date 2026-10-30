import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/theme.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';

// Même enchaînement que RechercheOffrePage : critères en plein écran, puis résultats avec le bouton
// « Créer une alerte » en bas. Ici, l'état vit dans la page et non dans le store.
class PocRechercheScaffold extends StatelessWidget {
  const PocRechercheScaffold({
    super.key,
    required this.titre,
    required this.afficherCriteres,
    required this.criteres,
    required this.resultats,
    required this.onRetourAuxResultats,
    required this.onCreerAlerte,
  });

  final String titre;
  final bool afficherCriteres;
  final Widget criteres;
  final Widget resultats;

  // Non nul quand des résultats existent déjà : « Retour » y ramène au lieu de quitter la recherche.
  final VoidCallback? onRetourAuxResultats;
  final VoidCallback? onCreerAlerte;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final retourAuxResultats = afficherCriteres ? onRetourAuxResultats : null;
    return Theme(
      data: isDarkMode ? PassEmploiTheme.darkData : PassEmploiTheme.data,
      child: Builder(
        builder: (context) {
          return PopScope(
            canPop: retourAuxResultats == null,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) retourAuxResultats?.call();
            },
            child: Scaffold(
              backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
              appBar: const BackAppBar(),
              floatingActionButton: !afficherCriteres && onCreerAlerte != null
                  ? FocusTraversalGroup(child: _BoutonAlerte(onPressed: onCreerAlerte!))
                  : null,
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              resizeToAvoidBottomInset: false,
              body: AnimatedSwitcher(
                duration: AnimationDurations.fast,
                child: afficherCriteres
                    ? SingleChildScrollView(
                        key: const ValueKey('pocCriteres'),
                        padding: const EdgeInsets.all(DsfrSpacings.s2w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [PageTitle(titre), const SizedBox(height: DsfrSpacings.s2w), criteres],
                        ),
                      )
                    : SingleChildScrollView(
                        key: const ValueKey('pocResultats'),
                        padding: const EdgeInsets.fromLTRB(DsfrSpacings.s2w, DsfrSpacings.s2w, DsfrSpacings.s2w, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [PageTitle(titre), const SizedBox(height: DsfrSpacings.s2w), resultats],
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BoutonAlerte extends StatelessWidget {
  const _BoutonAlerte({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const marge = DsfrSpacings.s2w;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: marge),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width - (marge * 2),
        child: DsfrButton(
          label: Strings.createAlert,
          icon: DsfrIcons.mediaNotification3Line,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
