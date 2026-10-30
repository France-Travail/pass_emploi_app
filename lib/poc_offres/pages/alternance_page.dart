import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/poc_offres/pages/alternance_detail_pages.dart';
import 'package:pass_emploi_app/poc_offres/pages/poc_formulaire_metier.dart';
import 'package:pass_emploi_app/poc_offres/pages/poc_recherche_scaffold.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_criteres_utilisateur.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_donnees.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_memoire.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_modeles.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_strings.dart';
import 'package:pass_emploi_app/poc_offres/widgets/poc_offres_widgets.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/alerte_bottom_sheet_form_content.dart';

class AlternanceRecherchePage extends StatefulWidget {
  const AlternanceRecherchePage({super.key, required this.initiaux});

  final PocCriteresInitiaux initiaux;

  static Route<void> route(PocCriteresInitiaux initiaux) {
    return MaterialPageRoute(builder: (_) => AlternanceRecherchePage(initiaux: initiaux));
  }

  @override
  State<AlternanceRecherchePage> createState() => _AlternanceRecherchePageState();
}

class _AlternanceRecherchePageState extends State<AlternanceRecherchePage> {
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
      titre: PocOffresStrings.alternanceTitre,
      afficherCriteres: _afficherCriteres,
      criteres: PocFormulaireMetier(
        libelleLieu: PocOffresStrings.lieu,
        libelleBouton: PocOffresStrings.voirLesOffres,
        metier: criteres?.metier ?? widget.initiaux.metier,
        lieu: criteres?.lieu ?? widget.initiaux.lieu,
        rayon: criteres?.rayon ?? widget.initiaux.rayon,
        recentes: _memoire.recherchesAlternance,
        onRechercher: _lancer,
      ),
      resultats: criteres != null ? _resultats(criteres) : const SizedBox.shrink(),
      onRetourAuxResultats: criteres != null ? () => setState(() => _afficherCriteres = false) : null,
      onCreerAlerte: criteres != null && pocRechercherOffres(criteres, _filtres).isNotEmpty
          ? () => pocCreerAlerte(
                context,
                titre: criteres.libelle,
                tags: [
                  AlerteFormTag(PocOffresStrings.tuileAlternanceTitre),
                  AlerteFormTag(criteres.metier.libelle),
                  AlerteFormTag.location(criteres.lieu.libelle),
                ],
              )
          : null,
    );
  }

  void _lancer(PocCriteresMetier criteres) {
    PocOffresMemoire.retenirRecherche(_memoire.recherchesAlternance, criteres);
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
    final offres = pocRechercherOffres(criteres, _filtres);
    final entreprises = pocRechercherEntreprises(criteres);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PocBarreRecherche(libelle: criteres.libelle, onTap: () => setState(() => _afficherCriteres = true)),
        const SizedBox(height: DsfrSpacings.s3v),
        PocBoutonFiltres(nombre: _filtres.nombre, onPressed: _ouvrirFiltres),
        const SizedBox(height: DsfrSpacings.s3w),
        if (offres.isEmpty && entreprises.isEmpty)
          PocResultatsVides(
            explication: PocOffresStrings.aucunResultatMetier,
            onModifier: () => setState(() => _afficherCriteres = true),
          )
        else ...[
          PocTitreResultats(PocOffresStrings.nombreOffres(offres.length)),
          for (final offre in offres) ...[
            const SizedBox(height: DsfrSpacings.s2w),
            PocCarte(
              id: offre.id,
              titre: offre.titre,
              sousTitre: offre.entreprise,
              complements: [
                (icone: DsfrIcons.mapMapPin2Line, texte: offre.lieu.ville),
                (icone: DsfrIcons.businessBriefcaseLine, texte: offre.typeContrat),
              ],
              onTap: () => Navigator.push(context, OffreAlternanceDetailPage.route(offre)),
            ),
          ],
          // Choix de Steph (30/10) : les entreprises qui recrutent sans offre viennent après les offres.
          if (entreprises.isNotEmpty) ...[
            const SizedBox(height: DsfrSpacings.s5w),
            PocTitreResultats(PocOffresStrings.nombreEntreprises(entreprises.length)),
            const SizedBox(height: DsfrSpacings.s1w),
            Text(
              PocOffresStrings.entreprisesExplication,
              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
            ),
            for (final entreprise in entreprises) ...[
              const SizedBox(height: DsfrSpacings.s2w),
              PocCarte(
                id: entreprise.id,
                titre: entreprise.nom,
                sousTitre: entreprise.secteur,
                etiquette: PocOffresStrings.candidatureSpontanee,
                complements: [
                  (icone: DsfrIcons.mapMapPin2Line, texte: entreprise.lieu.ville),
                  (icone: DsfrIcons.userGroupLine, texte: entreprise.taille),
                ],
                onTap: () => Navigator.push(context, EntrepriseDetailPage.route(entreprise, criteres.metier)),
              ),
            ],
          ],
        ],
      ],
    );
  }

  Future<void> _ouvrirFiltres() async {
    final filtres = await pocOuvrirFiltresNiveau(context, PocOffresStrings.filtrerAnnonces, _filtres);
    if (filtres != null) setState(() => _filtres = filtres);
  }
}
