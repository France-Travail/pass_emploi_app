import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/pages/generic_success_page.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_memoire.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_modeles.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_strings.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/platform.dart';
import 'package:pass_emploi_app/utils/uri_handler.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/alerte_bottom_sheet_form_content.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/bottom_sheets.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/filtres_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_card_semantics.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_event_card.dart';
import 'package:url_launcher/url_launcher.dart';

typedef PocComplement = ({IconData icone, String texte});

// Reprend la barre de recherche des résultats d'offres (EditCriteresButton), sans le store.
class PocBarreRecherche extends StatelessWidget {
  const PocBarreRecherche({super.key, required this.libelle, required this.onTap});

  final String libelle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(DsfrSpacings.s1v);
    return Semantics(
      button: true,
      label: '$libelle, ${Strings.rechercheEditButton}',
      onTap: onTap,
      excludeSemantics: true,
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: DsfrColorDecisions.backgroundDefaultGreyHover(context),
              borderRadius: const BorderRadius.only(topLeft: radius),
              child: InkWell(
                onTap: onTap,
                borderRadius: const BorderRadius.only(topLeft: radius),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: DsfrColorDecisions.borderPlainBlueFrance(context),
                        width: DsfrSpacings.s0v5,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
                    child: SizedBox(
                      height: DsfrSpacings.s6w,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          libelle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Material(
            color: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
            borderRadius: const BorderRadius.only(topRight: radius),
            child: InkWell(
              onTap: onTap,
              canRequestFocus: false,
              borderRadius: const BorderRadius.only(topRight: radius),
              child: SizedBox(
                width: DsfrSpacings.s6w,
                height: DsfrSpacings.s6w,
                child: Icon(
                  DsfrIcons.systemSearchLine,
                  color: DsfrColorDecisions.textInvertedBlueFrance(context),
                  size: DsfrSpacings.s3w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PocBoutonFiltres extends StatelessWidget {
  const PocBoutonFiltres({super.key, required this.nombre, required this.onPressed});

  final int nombre;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DsfrButton(
      label: nombre > 0 ? "${Strings.filtrerLesResultats} ($nombre)" : Strings.filtrerLesResultats,
      icon: DsfrIcons.mediaEqualizerLine,
      variant: DsfrButtonVariant.secondary,
      size: DsfrComponentSize.lg,
      onPressed: onPressed,
    );
  }
}

class PocEtoile extends StatelessWidget {
  const PocEtoile({super.key, required this.id, required this.titre});

  final String id;
  final String titre;

  @override
  Widget build(BuildContext context) {
    final memoire = PocOffresMemoire.instance;
    return ValueListenableBuilder<Set<String>>(
      valueListenable: memoire.suivis,
      builder: (context, suivis, _) {
        final suivi = suivis.contains(id);
        return IconButton(
          tooltip: suivi ? PocOffresStrings.retirerDuSuivi(titre) : PocOffresStrings.ajouterAuSuivi(titre),
          onPressed: () => memoire.basculerSuivi(id),
          icon: Icon(
            suivi ? DsfrIcons.systemStarFill : DsfrIcons.systemStarLine,
            color: DsfrColorDecisions.textActionHighBlueFrance(context),
          ),
        );
      },
    );
  }
}

// Même rendu que DataCard, avec une étoile gardée en mémoire au lieu des favoris de l'API.
class PocCarte extends StatelessWidget {
  const PocCarte({
    super.key,
    required this.id,
    required this.titre,
    this.sousTitre,
    this.etiquette,
    this.complements = const [],
    required this.onTap,
  });

  final String id;
  final String titre;
  final String? sousTitre;
  final String? etiquette;
  final List<PocComplement> complements;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(4));
    final semantique = [
      if (etiquette != null) etiquette!,
      titre,
      if (sousTitre != null) sousTitre!,
      for (final complement in complements) complement.texte,
    ].join('. ');
    return Material(
      color: DsfrColorDecisions.backgroundDefaultGrey(context),
      borderRadius: radius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: DsfrColorDecisions.borderDefaultGrey(context)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Semantics(
                  container: true,
                  button: true,
                  label: semantique,
                  onTap: onTap,
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: radius,
                    focusColor: Colors.transparent,
                    child: Builder(
                      builder: (context) => DsfrFocusWidget(
                        isFocused: Focus.of(context).hasPrimaryFocus,
                        borderRadius: radius,
                        child: Padding(
                          padding: const EdgeInsets.all(DsfrSpacings.s3v),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (etiquette != null) ...[
                                DsfrCategoryTag.info(label: etiquette!),
                                const SizedBox(height: DsfrSpacings.s1w),
                              ],
                              Text(
                                titre,
                                style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
                              ),
                              if (sousTitre != null)
                                Text(
                                  sousTitre!,
                                  style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textTitleGrey(context)),
                                ),
                              for (final complement in complements) ...[
                                const SizedBox(height: DsfrSpacings.s1v),
                                DsfrEventCardComplement(icon: complement.icone, text: complement.texte),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(alignment: Alignment.topRight, widthFactor: 1, child: PocEtoile(id: id, titre: titre)),
            ],
          ),
        ),
      ),
    );
  }
}

class PocTitreResultats extends StatelessWidget {
  const PocTitreResultats(this.texte, {super.key});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(texte, style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context))),
    );
  }
}

class PocRecherchesRecentes extends StatelessWidget {
  const PocRecherchesRecentes({super.key, required this.libelles, required this.onTap});

  final List<String> libelles;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    if (libelles.isEmpty) return const SizedBox.shrink();
    final bordure = DsfrColorDecisions.artworkDecorativeBlueFrance(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: DsfrSpacings.s2w),
          child: Row(
            children: [
              Icon(DsfrIcons.systemTimeLine, size: 16, color: DsfrColorDecisions.textTitleGrey(context)),
              const SizedBox(width: DsfrSpacings.s1w),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    Strings.rechercheRecentesTitle,
                    style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
                  ),
                ),
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DsfrSpacings.s1w),
            border: Border.all(color: bordure),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < libelles.length; i++) ...[
                if (i > 0) Divider(height: 1, thickness: 1, color: bordure),
                Semantics(
                  button: true,
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Padding(
                      padding: const EdgeInsets.all(DsfrSpacings.s2w),
                      child: Text(
                        libelles[i],
                        style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textActionHighBlueFrance(context)),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class PocResultatsVides extends StatelessWidget {
  const PocResultatsVides({super.key, required this.explication, required this.onModifier});

  final String explication;
  final VoidCallback onModifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: DsfrSpacings.s1w, bottom: DsfrSpacings.s3w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Image.asset(
              Drawables.illustrationRechercheEmpty,
              width: 212,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
          PocTitreResultats(PocOffresStrings.aucunResultatTitre),
          const SizedBox(height: DsfrSpacings.s1w),
          Text(explication, style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context))),
          const SizedBox(height: DsfrSpacings.s2w),
          DsfrButton(
            label: Strings.modifierMesCriteres,
            icon: DsfrIcons.designEditLine,
            variant: DsfrButtonVariant.primary,
            size: DsfrComponentSize.lg,
            onPressed: onModifier,
          ),
        ],
      ),
    );
  }
}

class PocParagraphes extends StatelessWidget {
  const PocParagraphes(this.paragraphes, {super.key});

  final List<String> paragraphes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final paragraphe in paragraphes)
          Padding(
            padding: const EdgeInsets.only(bottom: DsfrSpacings.s1w),
            child: Text(paragraphe, style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context))),
          ),
      ],
    );
  }
}

class PocPuces extends StatelessWidget {
  const PocPuces(this.elements, {super.key, this.numerotees = false});

  final List<String> elements;
  final bool numerotees;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < elements.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: DsfrSpacings.s1w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A11y 7.2 : la puce décorative n'est pas lue séparément.
                ExcludeSemantics(
                  child: Text(
                    numerotees ? '${i + 1}.' : '•',
                    style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                  ),
                ),
                const SizedBox(width: DsfrSpacings.s1w),
                Expanded(
                  child: Text(
                    elements[i],
                    style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// « Mise en avant » du DSFR : fond bleu clair et barre verticale à gauche.
class PocMiseEnAvant extends StatelessWidget {
  const PocMiseEnAvant({super.key, this.titre, required this.texte});

  final String? titre;
  final String texte;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: DsfrColorDecisions.backgroundContrastBlueFrance(context)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: DsfrColorDecisions.borderDefaultBlueFrance(context)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(DsfrSpacings.s2w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (titre != null) ...[
                      Text(titre!, style: DsfrTextStyle.bodyLgBold(color: DsfrColorDecisions.textTitleGrey(context))),
                      const SizedBox(height: DsfrSpacings.s1w),
                    ],
                    Text(texte, style: DsfrTextStyle.bodyLg(color: DsfrColorDecisions.textDefaultGrey(context))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PocLienExterne extends StatelessWidget {
  const PocLienExterne({super.key, required this.libelle, required this.onTap});

  final String libelle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DsfrLink(label: libelle, icon: DsfrIcons.systemExternalLinkLine, onTap: onTap);
  }
}

String? pocLibelleDerniereAction(String id) {
  final memoire = PocOffresMemoire.instance;
  final candidature = memoire.dateCandidature(id);
  if (candidature != null) return Strings.offrePostulatedSeen(candidature);
  final consultation = memoire.derniereConsultation(id);
  return consultation != null ? Strings.offreLastSeen(consultation) : null;
}

// Même page de succès qu'après un vrai partage d'offre ; rien n'est envoyé dans la messagerie.
void pocPartagerAuConseiller(BuildContext context) {
  Navigator.push(
    context,
    GenericSuccessPage.route(title: PocOffresStrings.partageTitre, content: PocOffresStrings.partageEffectue),
  );
}

// Même formulaire que la création d'alerte de l'app ; rien n'est enregistré.
void pocCreerAlerte(BuildContext context, {required String titre, required List<AlerteFormTag> tags}) {
  showPassEmploiBottomSheet<void>(
    context: context,
    builder: (sheetContext) => FiltresBottomSheet(
      title: Strings.createAlerteTitle,
      body: AlerteBottomSheetFormContent(
        initialTitle: titre,
        tags: tags,
        savingFailure: false,
        onCreate: (_) {
          Navigator.pop(sheetContext);
          Navigator.push(
            context,
            GenericSuccessPage.route(title: Strings.createAlertSuccessTitle, content: Strings.alerteSuccessfullyCreated),
          );
        },
      ),
    ),
  );
}

void pocOuvrirCarte(PocLieu lieu) {
  launchUrl(UriHandler().mapsUri(lieu.adresseComplete, PlatformUtils.getPlatform), mode: LaunchMode.externalApplication);
}

void pocAppeler(String numero) => launchUrl(UriHandler().phoneUri(numero.replaceAll(' ', '')));

void pocEcrire(String email, String sujet) => launchUrl(UriHandler().mailUri(to: email, subject: sujet));
