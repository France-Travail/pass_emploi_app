import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/poc_offres/pages/poc_formulaire_metier.dart';
import 'package:pass_emploi_app/poc_offres/pages/poc_recherche_scaffold.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_criteres_utilisateur.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_donnees.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_memoire.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_modeles.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_strings.dart';
import 'package:pass_emploi_app/poc_offres/widgets/poc_offres_widgets.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/alerte_bottom_sheet_form_content.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/bottom_sheets.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/filtres_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/buttons/share_button.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_card_semantics.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_actions_footer.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_header.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_section_title.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_tag.dart';

class FormationRecherchePage extends StatefulWidget {
  const FormationRecherchePage({super.key, required this.initiaux});

  final PocCriteresInitiaux initiaux;

  static Route<void> route(PocCriteresInitiaux initiaux) {
    return MaterialPageRoute(builder: (_) => FormationRecherchePage(initiaux: initiaux));
  }

  @override
  State<FormationRecherchePage> createState() => _FormationRecherchePageState();
}

class _FormationRecherchePageState extends State<FormationRecherchePage> {
  final _memoire = PocOffresMemoire.instance;
  PocCriteresMetier? _criteres;
  PocFiltresNiveau _filtres = const PocFiltresNiveau();
  bool _afficherCriteres = true;

  @override
  void initState() {
    super.initState();
    final metier = widget.initiaux.metier;
    final lieu = widget.initiaux.lieu;
    if (metier != null && lieu != null) {
      _criteres = PocCriteresMetier(metier: metier, lieu: lieu, rayon: widget.initiaux.rayon);
      _afficherCriteres = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final criteres = _criteres;
    return PocRechercheScaffold(
      titre: PocOffresStrings.formationTitre,
      afficherCriteres: _afficherCriteres,
      // Pas de recherche par département : l'API formation de La bonne alternance n'a que lieu et rayon.
      criteres: PocFormulaireMetier(
        libelleLieu: PocOffresStrings.lieuFormation,
        libelleBouton: PocOffresStrings.voirLesFormations,
        metier: criteres?.metier ?? widget.initiaux.metier,
        lieu: criteres?.lieu ?? widget.initiaux.lieu,
        rayon: criteres?.rayon ?? widget.initiaux.rayon,
        recentes: _memoire.recherchesFormation,
        onRechercher: _lancer,
      ),
      resultats: criteres != null ? _resultats(criteres) : const SizedBox.shrink(),
      onRetourAuxResultats: criteres != null ? () => setState(() => _afficherCriteres = false) : null,
      onCreerAlerte: criteres != null && pocRechercherFormations(criteres, _filtres).isNotEmpty
          ? () => pocCreerAlerte(
                context,
                titre: criteres.libelle,
                tags: [
                  AlerteFormTag(PocOffresStrings.tuileFormationTitre),
                  AlerteFormTag(criteres.metier.libelle),
                  AlerteFormTag.location(criteres.lieu.libelle),
                ],
              )
          : null,
    );
  }

  void _lancer(PocCriteresMetier criteres) {
    PocOffresMemoire.retenirRecherche(_memoire.recherchesFormation, criteres);
    pocRetenirCriteres(
      StoreProvider.of<AppState>(context),
      metier: criteres.metier,
      lieu: criteres.lieu,
      rayon: criteres.rayon,
    );
    setState(() {
      _criteres = criteres;
      _afficherCriteres = false;
    });
  }

  Widget _resultats(PocCriteresMetier criteres) {
    final formations = pocRechercherFormations(criteres, _filtres);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PocBarreRecherche(libelle: criteres.libelle, onTap: () => setState(() => _afficherCriteres = true)),
        const SizedBox(height: DsfrSpacings.s3v),
        PocBoutonFiltres(nombre: _filtres.nombre, onPressed: _ouvrirFiltres),
        const SizedBox(height: DsfrSpacings.s3w),
        if (formations.isEmpty)
          PocResultatsVides(
            explication: PocOffresStrings.aucunResultatMetier,
            onModifier: () => setState(() => _afficherCriteres = true),
          )
        else ...[
          PocTitreResultats(PocOffresStrings.nombreFormations(formations.length)),
          for (final formation in formations) ...[
            const SizedBox(height: DsfrSpacings.s2w),
            PocCarte(
              id: formation.id,
              titre: formation.intitule,
              sousTitre: formation.organisme,
              complements: [
                (icone: DsfrIcons.mapMapPin2Line, texte: formation.lieu.codePostalEtVille),
                (icone: DsfrIcons.systemTimeLine, texte: formation.duree),
              ],
              onTap: () => Navigator.push(context, FormationDetailPage.route(formation)),
            ),
          ],
        ],
      ],
    );
  }

  Future<void> _ouvrirFiltres() async {
    final filtres = await pocOuvrirFiltresNiveau(context, PocOffresStrings.filtrerFormations, _filtres);
    if (filtres != null) setState(() => _filtres = filtres);
  }
}

class FormationDetailPage extends StatefulWidget {
  const FormationDetailPage({super.key, required this.formation});

  final PocFormation formation;

  static Route<void> route(PocFormation formation) {
    return MaterialPageRoute(builder: (_) => FormationDetailPage(formation: formation));
  }

  @override
  State<FormationDetailPage> createState() => _FormationDetailPageState();
}

class _FormationDetailPageState extends State<FormationDetailPage> {
  late final String? _derniereAction = pocLibelleDerniereAction(widget.formation.id);

  @override
  void dispose() {
    PocOffresMemoire.instance.noterConsultation(widget.formation.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formation = widget.formation;
    return Scaffold(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      appBar: BackAppBar(
        actions: [
          PocEtoile(id: formation.id, titre: formation.intitule),
          ShareButton(
            textToShare: "${formation.intitule} - ${formation.organisme}, ${formation.lieu.ville}",
            semanticsLabel: Strings.a11yPartagerOffreLabel,
            subjectForEmail: formation.intitule,
            onPressed: null,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(DsfrSpacings.s2w, DsfrSpacings.s2w, DsfrSpacings.s2w, DsfrSpacings.s3w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageTitle(PocOffresStrings.detailsFormation),
                  const SizedBox(height: DsfrSpacings.s1w),
                  OffreDetailsHeader(
                    dateLabel: _derniereAction,
                    leading: DsfrCategoryTag.secteur(label: formation.diplome),
                    title: formation.intitule,
                    subtitle: formation.organisme,
                    tags: [
                      OffreDetailsTag.location(formation.lieu.codePostalEtVille),
                      OffreDetailsTag(
                        label: PocOffresStrings.aPartirDu(formation.debut),
                        icon: DsfrIcons.businessCalendarLine,
                        iconSemanticLabel: Strings.iconAlternativeDateDeDebut,
                      ),
                      OffreDetailsTag(label: formation.duree, icon: DsfrIcons.systemTimeLine),
                      OffreDetailsTag.contractType("Apprentissage"),
                    ],
                  ),
                  const SizedBox(height: DsfrSpacings.s3w),
                  OffreDetailsSectionTitle(PocOffresStrings.descriptionFormation),
                  const SizedBox(height: DsfrSpacings.s2w),
                  OffreDetailsSectionTitle(PocOffresStrings.competences, size: OffreDetailsSectionTitleSize.headline6),
                  const SizedBox(height: DsfrSpacings.s1w),
                  PocParagraphes(formation.competences),
                  const SizedBox(height: DsfrSpacings.s1w),
                  OffreDetailsSectionTitle(PocOffresStrings.objectifs, size: OffreDetailsSectionTitleSize.headline6),
                  const SizedBox(height: DsfrSpacings.s1w),
                  PocParagraphes(formation.objectifs),
                  const SizedBox(height: DsfrSpacings.s2w),
                  OffreDetailsSectionTitle(
                    PocOffresStrings.informationsEtablissement,
                    size: OffreDetailsSectionTitleSize.headline6,
                  ),
                  const SizedBox(height: DsfrSpacings.s1w),
                  PocParagraphes([formation.lieu.adresseComplete]),
                  PocLienExterne(libelle: PocOffresStrings.voirSurUneCarte, onTap: () => pocOuvrirCarte(formation.lieu)),
                  const SizedBox(height: DsfrSpacings.s2w),
                  DsfrLink(
                    label: PocOffresStrings.telephone(formation.telephone),
                    icon: DsfrIcons.devicePhoneLine,
                    onTap: () => pocAppeler(formation.telephone),
                  ),
                  const SizedBox(height: DsfrSpacings.s2w),
                  Text(
                    PocOffresStrings.rechercheGoogle,
                    style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                  ),
                  const SizedBox(height: DsfrSpacings.s1w),
                  PocLienExterne(
                    libelle: formation.organisme,
                    onTap: () => launchExternalUrl(
                      "https://www.google.fr/search?q=${Uri.encodeQueryComponent("${formation.organisme} ${formation.lieu.ville}")}",
                    ),
                  ),
                ],
              ),
            ),
          ),
          OffreDetailsActionsFooter(
            actions: [
              // Choix de Steph (28/10) : « Demander un rendez-vous » au lieu de « Je postule » ;
              // sans rendez-vous en ligne, on propose d'appeler ou d'écrire au CFA.
              if (formation.rendezVousPossible)
                OffreDetailsAction(
                  label: PocOffresStrings.demanderRendezVous,
                  icon: DsfrIcons.systemExternalLinkLine,
                  semanticsLink: true,
                  onPressed: () => launchExternalUrl(
                    "https://labonnealternance.apprentissage.beta.gouv.fr/recherche?romes=${formation.codesRome.first}",
                  ),
                )
              else
                OffreDetailsAction(
                  label: PocOffresStrings.contacterCfa,
                  icon: DsfrIcons.businessMailLine,
                  onPressed: () => _contacter(context, formation),
                ),
              OffreDetailsAction(
                label: PocOffresStrings.partagerAuConseiller,
                icon: DsfrIcons.systemShareLine,
                variant: DsfrButtonVariant.secondary,
                onPressed: () => pocPartagerAuConseiller(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _contacter(BuildContext context, PocFormation formation) {
    showPassEmploiBottomSheet<void>(
      context: context,
      builder: (sheetContext) => FiltresBottomSheet(
        title: PocOffresStrings.contacterCfa,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PocParagraphes([
              PocOffresStrings.contacterCfaTexte,
              PocOffresStrings.telephone(formation.telephone),
              PocOffresStrings.emailCfa(formation.email),
            ]),
            const SizedBox(height: DsfrSpacings.s2w),
            DsfrButton(
              label: PocOffresStrings.appelerCfa,
              icon: DsfrIcons.devicePhoneLine,
              variant: DsfrButtonVariant.primary,
              size: DsfrComponentSize.lg,
              onPressed: () => pocAppeler(formation.telephone),
            ),
            const SizedBox(height: DsfrSpacings.s2w),
            DsfrButton(
              label: PocOffresStrings.ecrireCfa,
              icon: DsfrIcons.businessMailLine,
              variant: DsfrButtonVariant.secondary,
              size: DsfrComponentSize.lg,
              onPressed: () => pocEcrire(formation.email, formation.intitule),
            ),
            const SizedBox(height: DsfrSpacings.s2w),
          ],
        ),
      ),
    );
  }
}
