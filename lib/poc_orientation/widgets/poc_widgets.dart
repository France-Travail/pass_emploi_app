import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/poc_orientation/pages/fiche_metier_page.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';
import 'package:pass_emploi_app/widgets/a11y/external_link_semantics.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';

class PocScaffold extends StatelessWidget {
  const PocScaffold({super.key, required this.titre, required this.body, this.bottom});

  final String titre;
  final Widget body;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
      child: Builder(
        builder: (context) {
          final backgroundColor = DsfrColorDecisions.backgroundDefaultGrey(context);
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: SecondaryAppBar(title: titre, backgroundColor: backgroundColor),
            body: SafeArea(child: body),
            bottomNavigationBar: bottom,
          );
        },
      ),
    );
  }
}

class PocSectionTitre extends StatelessWidget {
  const PocSectionTitre(this.texte, {super.key});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(texte, style: DsfrTextStyle.headline5(color: DsfrColorDecisions.textTitleGrey(context))),
    );
  }
}

class PocPuces extends StatelessWidget {
  const PocPuces(this.lignes, {super.key});

  final List<String> lignes;

  @override
  Widget build(BuildContext context) {
    final style = DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final ligne in lignes)
          Padding(
            padding: const EdgeInsets.only(bottom: DsfrSpacings.s1w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(child: Text('•  ', style: style)),
                Expanded(child: Text(ligne, style: style)),
              ],
            ),
          ),
      ],
    );
  }
}

class PocMention extends StatelessWidget {
  const PocMention(this.texte, {super.key});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Text(texte, style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textMentionGrey(context)));
  }
}

class PocFuture<T> extends StatelessWidget {
  const PocFuture({
    super.key,
    required this.future,
    required this.onRetry,
    required this.builder,
    this.padding = EdgeInsets.zero,
  });

  final Future<T> future;
  final VoidCallback onRetry;
  final Widget Function(BuildContext context, T data) builder;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Padding(padding: padding, child: _PocErreur(onRetry: onRetry));
        if (!snapshot.hasData) {
          return Padding(
            padding: padding + const EdgeInsets.all(DsfrSpacings.s2w),
            child: Center(child: CircularProgressIndicator(semanticsLabel: PocOrientationStrings.chargement)),
          );
        }
        return builder(context, snapshot.data as T);
      },
    );
  }
}

class _PocErreur extends StatelessWidget {
  const _PocErreur({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DsfrAlert(type: DsfrAlertType.error, description: DsfrAlertDescriptionText(PocOrientationStrings.erreur)),
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrButton(
          label: PocOrientationStrings.reessayer,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.md,
          onPressed: onRetry,
        ),
      ],
    );
  }
}

class PocMetierAffiche {
  const PocMetierAffiche(this.metier, [this.detail]);

  final RomeMetierResume metier;
  final String? detail;
}

class PocListeMetiers extends StatefulWidget {
  const PocListeMetiers({super.key, required this.metiers});

  final List<PocMetierAffiche> metiers;

  @override
  State<PocListeMetiers> createState() => _PocListeMetiersState();
}

class _PocListeMetiersState extends State<PocListeMetiers> {
  static const _parPage = 20;
  int _visibles = _parPage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          PocOrientationStrings.nombreMetiers(widget.metiers.length),
          style: DsfrTextStyle.bodySmBold(color: DsfrColorDecisions.textMentionGrey(context)),
        ),
        for (final affiche in widget.metiers.take(_visibles)) PocMetierTuile(metier: affiche.metier, detail: affiche.detail),
        if (_visibles < widget.metiers.length) ...[
          const SizedBox(height: DsfrSpacings.s2w),
          DsfrButton(
            label: PocOrientationStrings.voirPlus,
            variant: DsfrButtonVariant.secondary,
            size: DsfrComponentSize.md,
            onPressed: () => setState(() => _visibles += _parPage),
          ),
        ],
      ],
    );
  }
}

class PocMetierTuile extends StatelessWidget {
  const PocMetierTuile({super.key, required this.metier, this.detail});

  final RomeMetierResume metier;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: [metier.libelle, if (detail != null) detail!].join('. '),
      excludeSemantics: true,
      onTap: () => _ouvrir(context),
      child: Material(
        color: DsfrColorDecisions.backgroundDefaultGrey(context),
        child: InkWell(
          onTap: () => _ouvrir(context),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: DsfrColorDecisions.borderDefaultGrey(context))),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: DsfrSpacings.s2w),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          metier.libelle,
                          style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleBlueFrance(context)),
                        ),
                        if (detail != null) ...[
                          const SizedBox(height: DsfrSpacings.s1v),
                          Text(detail!, style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context))),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: DsfrSpacings.s1w),
                  Icon(
                    DsfrIcons.systemArrowRightSLine,
                    size: 16,
                    color: DsfrColorDecisions.textTitleBlueFrance(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _ouvrir(BuildContext context) => Navigator.push(context, FicheMetierPage.route(metier));
}

class PocLienExterne extends StatelessWidget {
  const PocLienExterne({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final couleur = DsfrColorDecisions.textActionHighBlueFrance(context);
    return ExternalLinkSemantics(
      label: label,
      onTap: onTap,
      destination: LinkDestination.website,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DsfrSpacings.s1w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: DsfrTextStyle.bodyMd(color: couleur).copyWith(decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(width: DsfrSpacings.s1w),
              Icon(DsfrIcons.systemExternalLinkLine, size: 16, color: couleur),
            ],
          ),
        ),
      ),
    );
  }
}
