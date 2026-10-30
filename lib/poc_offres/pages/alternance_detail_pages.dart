import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/poc_offres/pages/candidature_pages.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_memoire.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_modeles.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_strings.dart';
import 'package:pass_emploi_app/poc_offres/widgets/poc_offres_widgets.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/widgets/buttons/share_button.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_card_semantics.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_actions_footer.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_header.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_section_title.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_tag.dart';

class OffreAlternanceDetailPage extends StatefulWidget {
  const OffreAlternanceDetailPage({super.key, required this.offre});

  final PocOffreAlternance offre;

  static Route<void> route(PocOffreAlternance offre) {
    return MaterialPageRoute(builder: (_) => OffreAlternanceDetailPage(offre: offre));
  }

  @override
  State<OffreAlternanceDetailPage> createState() => _OffreAlternanceDetailPageState();
}

class _OffreAlternanceDetailPageState extends State<OffreAlternanceDetailPage> {
  @override
  void dispose() {
    PocOffresMemoire.instance.noterConsultation(widget.offre.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offre = widget.offre;
    final siteWeb = offre.siteWeb;
    return _PocDetailScaffold(
      id: offre.id,
      titre: offre.titre,
      texteAPartager: "${offre.titre} - ${offre.entreprise}, ${offre.lieu.ville}",
      actions: offre.candidatureSimplifiee
          ? [OffreDetailsAction(label: PocOffresStrings.jePostuleIci, onPressed: _postuler)]
          : [
              // Offre sans candidature simplifiée (offre France Travail reprise par La bonne alternance, par exemple).
              OffreDetailsAction(
                label: PocOffresStrings.jePostule,
                icon: DsfrIcons.systemExternalLinkLine,
                semanticsLink: true,
                onPressed: () => launchExternalUrl(offre.urlPostulation!),
              ),
              OffreDetailsAction(
                label: PocOffresStrings.partagerAuConseiller,
                icon: DsfrIcons.systemShareLine,
                variant: DsfrButtonVariant.secondary,
                onPressed: () => pocPartagerAuConseiller(context),
              ),
            ],
      enfants: [
        PageTitle(PocOffresStrings.detailsOffre),
        const SizedBox(height: DsfrSpacings.s1w),
        OffreDetailsHeader(
          dateLabel: pocLibelleDerniereAction(offre.id),
          title: offre.titre,
          subtitle: offre.entreprise,
          tags: [
            OffreDetailsTag.location(offre.lieu.codePostalEtVille),
            OffreDetailsTag(
              label: PocOffresStrings.aPartirDu(offre.debut),
              icon: DsfrIcons.businessCalendarLine,
              iconSemanticLabel: Strings.iconAlternativeDateDeDebut,
            ),
            OffreDetailsTag(label: offre.duree, icon: DsfrIcons.systemTimeLine),
            OffreDetailsTag.contractType(offre.typeContrat),
            OffreDetailsTag(label: offre.niveau.libelle, icon: DsfrIcons.businessAwardLine),
          ],
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        OffreDetailsSectionTitle(PocOffresStrings.description),
        const SizedBox(height: DsfrSpacings.s2w),
        PocParagraphes(offre.description),
        const SizedBox(height: DsfrSpacings.s2w),
        OffreDetailsSectionTitle(PocOffresStrings.profilSouhaite),
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrAccordionsGroup(
          values: [
            DsfrAccordion(headerLabel: PocOffresStrings.qualites, body: PocPuces(offre.qualites)),
            DsfrAccordion(headerLabel: PocOffresStrings.competencesAcquises, body: PocPuces(offre.competencesAcquises)),
            DsfrAccordion(headerLabel: PocOffresStrings.domainesTechniques, body: PocPuces(offre.domainesTechniques)),
            DsfrAccordion(headerLabel: PocOffresStrings.accessibleA, body: PocParagraphes([offre.accessibleA])),
          ],
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        OffreDetailsSectionTitle(PocOffresStrings.presentationEntreprise),
        const SizedBox(height: DsfrSpacings.s2w),
        _Gras(offre.entreprise),
        const SizedBox(height: DsfrSpacings.s1w),
        PocParagraphes([PocOffresStrings.renseigneToi]),
        _Adresse(offre.lieu),
        const SizedBox(height: DsfrSpacings.s2w),
        OffreDetailsSectionTitle(
          PocOffresStrings.informationsComplementaires,
          size: OffreDetailsSectionTitleSize.headline6,
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        PocParagraphes([
          PocOffresStrings.tailleEntreprise(offre.tailleEntreprise),
          PocOffresStrings.secteurActivite(offre.secteur),
        ]),
        if (siteWeb != null) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          OffreDetailsSectionTitle(PocOffresStrings.siteWeb, size: OffreDetailsSectionTitleSize.headline6),
          const SizedBox(height: DsfrSpacings.s1w),
          PocLienExterne(libelle: siteWeb, onTap: () => launchExternalUrl(siteWeb)),
        ],
      ],
    );
  }

  Future<void> _postuler() async {
    final offre = widget.offre;
    await CandidaturePage.ouvrir(
      context,
      PocCibleCandidature(
        id: offre.id,
        titre: offre.titre,
        sousTitre: "${offre.entreprise} - ${offre.lieu.ville}",
        spontanee: false,
      ),
    );
    if (mounted) setState(() {});
  }
}

class EntrepriseDetailPage extends StatefulWidget {
  const EntrepriseDetailPage({super.key, required this.entreprise, required this.metier});

  final PocEntreprise entreprise;
  final PocMetier metier;

  static Route<void> route(PocEntreprise entreprise, PocMetier metier) {
    return MaterialPageRoute(builder: (_) => EntrepriseDetailPage(entreprise: entreprise, metier: metier));
  }

  @override
  State<EntrepriseDetailPage> createState() => _EntrepriseDetailPageState();
}

class _EntrepriseDetailPageState extends State<EntrepriseDetailPage> {
  @override
  void dispose() {
    PocOffresMemoire.instance.noterConsultation(widget.entreprise.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entreprise = widget.entreprise;
    final telephone = entreprise.telephone;
    return _PocDetailScaffold(
      id: entreprise.id,
      titre: entreprise.nom,
      texteAPartager: "${entreprise.nom}, ${entreprise.lieu.adresseComplete}",
      actions: [
        if (entreprise.candidatureSimplifiee)
          OffreDetailsAction(label: PocOffresStrings.envoyerCandidatureSpontanee, onPressed: _postuler)
        else if (telephone != null)
          OffreDetailsAction(
            label: PocOffresStrings.appelerEntreprise,
            icon: DsfrIcons.devicePhoneLine,
            onPressed: () => pocAppeler(telephone),
          ),
      ],
      enfants: [
        PageTitle(PocOffresStrings.detailsEntreprise),
        const SizedBox(height: DsfrSpacings.s1w),
        OffreDetailsHeader(
          dateLabel: pocLibelleDerniereAction(entreprise.id),
          leading: DsfrCategoryTag.info(label: PocOffresStrings.candidatureSpontanee),
          title: entreprise.nom,
          subtitle: entreprise.secteur,
          tags: [
            OffreDetailsTag.location(entreprise.lieu.codePostalEtVille),
            OffreDetailsTag(label: entreprise.taille, icon: DsfrIcons.userGroupLine),
          ],
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        OffreDetailsSectionTitle(PocOffresStrings.pourquoiEntreprise),
        const SizedBox(height: DsfrSpacings.s2w),
        PocParagraphes([PocOffresStrings.pourquoiEntrepriseTexte(widget.metier.libelle)]),
        const SizedBox(height: DsfrSpacings.s2w),
        OffreDetailsSectionTitle(PocOffresStrings.presentationEntreprise),
        const SizedBox(height: DsfrSpacings.s2w),
        PocParagraphes([PocOffresStrings.renseigneToi]),
        _Adresse(entreprise.lieu),
      ],
    );
  }

  Future<void> _postuler() async {
    final entreprise = widget.entreprise;
    await CandidaturePage.ouvrir(
      context,
      PocCibleCandidature(
        id: entreprise.id,
        titre: entreprise.nom,
        sousTitre: "${widget.metier.libelle} - ${entreprise.lieu.ville}",
        spontanee: true,
      ),
    );
    if (mounted) setState(() {});
  }
}

class _PocDetailScaffold extends StatelessWidget {
  const _PocDetailScaffold({
    required this.id,
    required this.titre,
    required this.texteAPartager,
    required this.actions,
    required this.enfants,
  });

  final String id;
  final String titre;
  final String texteAPartager;
  final List<OffreDetailsAction> actions;
  final List<Widget> enfants;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      appBar: BackAppBar(
        actions: [
          PocEtoile(id: id, titre: titre),
          ShareButton(
            textToShare: texteAPartager,
            semanticsLabel: Strings.a11yPartagerOffreLabel,
            subjectForEmail: titre,
            onPressed: null,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(DsfrSpacings.s2w, DsfrSpacings.s2w, DsfrSpacings.s2w, DsfrSpacings.s3w),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: enfants),
            ),
          ),
          OffreDetailsActionsFooter(actions: actions),
        ],
      ),
    );
  }
}

class _Gras extends StatelessWidget {
  const _Gras(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Text(texte, style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)));
  }
}

class _Adresse extends StatelessWidget {
  const _Adresse(this.lieu);

  final PocLieu lieu;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: DsfrSpacings.s1w),
        OffreDetailsSectionTitle(PocOffresStrings.adresse, size: OffreDetailsSectionTitleSize.headline6),
        const SizedBox(height: DsfrSpacings.s1w),
        PocParagraphes([lieu.adresseComplete]),
        PocLienExterne(libelle: PocOffresStrings.voirSurUneCarte, onTap: () => pocOuvrirCarte(lieu)),
      ],
    );
  }
}
