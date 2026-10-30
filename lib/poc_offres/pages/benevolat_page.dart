import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/models/location.dart';
import 'package:pass_emploi_app/poc_offres/pages/benevolat_detail_page.dart';
import 'package:pass_emploi_app/poc_offres/pages/poc_recherche_scaffold.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_criteres_utilisateur.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_donnees.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_memoire.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_modeles.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_strings.dart';
import 'package:pass_emploi_app/poc_offres/widgets/poc_offres_champs.dart';
import 'package:pass_emploi_app/poc_offres/widgets/poc_offres_widgets.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/utils/date_extensions.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/alerte_bottom_sheet_form_content.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/bottom_sheets.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/filtres_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/buttons/filter_button.dart';

class BenevolatRecherchePage extends StatefulWidget {
  const BenevolatRecherchePage({super.key, required this.initiaux});

  final PocCriteresInitiaux initiaux;

  static Route<void> route(PocCriteresInitiaux initiaux) {
    return MaterialPageRoute(builder: (_) => BenevolatRecherchePage(initiaux: initiaux));
  }

  @override
  State<BenevolatRecherchePage> createState() => _BenevolatRecherchePageState();
}

class _BenevolatRecherchePageState extends State<BenevolatRecherchePage> {
  static const _toutes = '';

  final _memoire = PocOffresMemoire.instance;
  String _activite = _toutes;
  Location? _lieu;
  PocCriteresBenevolat? _criteres;
  PocFiltresBenevolat _filtres = const PocFiltresBenevolat();
  bool _afficherCriteres = true;

  @override
  void initState() {
    super.initState();
    _lieu = widget.initiaux.lieu;
    // Comme les autres recherches de l'onglet Offres : avec une ville connue, on montre directement les résultats.
    final lieu = _lieu;
    if (lieu != null) {
      _criteres = PocCriteresBenevolat(activite: null, lieu: lieu);
      _afficherCriteres = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final criteres = _criteres;
    return PocRechercheScaffold(
      titre: PocOffresStrings.benevolatTitre,
      afficherCriteres: _afficherCriteres,
      criteres: _formulaire(),
      resultats: criteres != null ? _resultats(criteres) : const SizedBox.shrink(),
      onRetourAuxResultats: criteres != null ? () => setState(() => _afficherCriteres = false) : null,
      onCreerAlerte: criteres != null && pocRechercherMissions(criteres, _filtres).isNotEmpty
          ? () => pocCreerAlerte(
                context,
                titre: criteres.libelle,
                tags: [
                  AlerteFormTag(PocOffresStrings.benevolatTitre),
                  if (criteres.activite != null) AlerteFormTag(criteres.activite!),
                  AlerteFormTag.location(criteres.lieu.libelle),
                ],
              )
          : null,
    );
  }

  Widget _formulaire() {
    final recentes = _memoire.recherchesBenevolat;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DsfrSelect<String>(
          label: PocOffresStrings.activite,
          initialSelection: _activite,
          dropdownMenuEntries: [
            DropdownMenuEntry(value: _toutes, label: PocOffresStrings.toutesLesActivites),
            for (final activite in pocActivites) DropdownMenuEntry(value: activite, label: activite),
          ],
          onSelected: (activite) => setState(() => _activite = activite ?? _toutes),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        PocChampCommune(
          titre: PocOffresStrings.lieuMission,
          valeur: _lieu,
          onChange: (lieu) => setState(() => _lieu = lieu),
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        DsfrButton(
          label: PocOffresStrings.voirLesMissions,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: _lieu != null ? _rechercher : null,
        ),
        PocRecherchesRecentes(
          libelles: [for (final recherche in recentes) recherche.libelle],
          onTap: (index) => _lancer(recentes[index]),
        ),
      ],
    );
  }

  void _rechercher() {
    _lancer(PocCriteresBenevolat(activite: _activite == _toutes ? null : _activite, lieu: _lieu!));
  }

  void _lancer(PocCriteresBenevolat criteres) {
    PocOffresMemoire.retenirRecherche(_memoire.recherchesBenevolat, criteres);
    pocRetenirCriteres(StoreProvider.of<AppState>(context), lieu: criteres.lieu);
    setState(() {
      _criteres = criteres;
      _activite = criteres.activite ?? _toutes;
      _lieu = criteres.lieu;
      _afficherCriteres = false;
    });
  }

  Widget _resultats(PocCriteresBenevolat criteres) {
    final missions = pocRechercherMissions(criteres, _filtres);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PocBarreRecherche(libelle: criteres.libelle, onTap: () => setState(() => _afficherCriteres = true)),
        const SizedBox(height: DsfrSpacings.s3v),
        PocBoutonFiltres(nombre: _filtres.nombre, onPressed: _ouvrirFiltres),
        const SizedBox(height: DsfrSpacings.s3w),
        if (missions.isEmpty)
          PocResultatsVides(
            explication: PocOffresStrings.aucunResultatBenevolat,
            onModifier: () => setState(() => _afficherCriteres = true),
          )
        else ...[
          PocTitreResultats(PocOffresStrings.nombreMissions(missions.length)),
          for (final mission in missions) ...[
            const SizedBox(height: DsfrSpacings.s2w),
            PocCarte(
              id: mission.id,
              titre: mission.titre,
              sousTitre: mission.organisation,
              complements: [
                (icone: DsfrIcons.mapMapPin2Line, texte: mission.lieu?.ville ?? PocOffresStrings.missionADistance),
                (icone: DsfrIcons.systemTimeLine, texte: mission.rythme),
              ],
              onTap: () => Navigator.push(context, MissionDetailPage.route(mission)),
            ),
          ],
        ],
      ],
    );
  }

  Future<void> _ouvrirFiltres() async {
    final filtres = await showPassEmploiBottomSheet<PocFiltresBenevolat>(
      context: context,
      builder: (_) => FiltresBottomSheet(
        title: PocOffresStrings.filtrerMissions,
        body: _FiltresBenevolat(initiaux: _filtres),
      ),
    );
    if (filtres != null) setState(() => _filtres = filtres);
  }
}

class _FiltresBenevolat extends StatefulWidget {
  const _FiltresBenevolat({required this.initiaux});

  final PocFiltresBenevolat initiaux;

  @override
  State<_FiltresBenevolat> createState() => _FiltresBenevolatState();
}

class _FiltresBenevolatState extends State<_FiltresBenevolat> {
  late Set<PocTypeMission> _types;
  late Set<String> _domaines;
  late bool _mineurs;
  late bool _pmr;
  DateTime? _aPartirDu;
  late final TextEditingController _date;
  int _version = 0;

  @override
  void initState() {
    super.initState();
    _types = {...widget.initiaux.types};
    _domaines = {...widget.initiaux.domaines};
    _mineurs = widget.initiaux.ouverteAuxMineurs;
    _pmr = widget.initiaux.accessiblePmr;
    _aPartirDu = widget.initiaux.aPartirDu;
    _date = TextEditingController(text: _aPartirDu?.toDay() ?? '');
  }

  @override
  void dispose() {
    _date.dispose();
    super.dispose();
  }

  void _reinitialiser() {
    setState(() {
      _types = {};
      _domaines = {};
      _mineurs = false;
      _pmr = false;
      _aPartirDu = null;
      _date.text = '';
      _version++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TitreFiltre(PocOffresStrings.typeDeMissions),
              const SizedBox(height: DsfrSpacings.s1w),
              Wrap(
                spacing: DsfrSpacings.s1w,
                runSpacing: DsfrSpacings.s1w,
                children: [
                  for (final (type, libelle) in [
                    (PocTypeMission.presDeChezMoi, PocOffresStrings.presDeChezMoi),
                    (PocTypeMission.depuisChezMoi, PocOffresStrings.depuisChezMoi),
                  ])
                    DsfrTag(
                      label: libelle,
                      size: DsfrComponentSize.md,
                      isSelected: _types.contains(type),
                      onSelectionChanged: (choisi) => setState(() => choisi ? _types.add(type) : _types.remove(type)),
                    ),
                ],
              ),
              const SizedBox(height: DsfrSpacings.s3w),
              _TitreFiltre(PocOffresStrings.domaines),
              const SizedBox(height: DsfrSpacings.s2w),
              for (final domaine in pocDomaines)
                Padding(
                  padding: const EdgeInsets.only(bottom: DsfrSpacings.s2w),
                  child: DsfrCheckbox(
                    label: domaine,
                    size: DsfrComponentSize.md,
                    value: _domaines.contains(domaine),
                    onChanged: (coche) => setState(() => coche ? _domaines.add(domaine) : _domaines.remove(domaine)),
                  ),
                ),
              const SizedBox(height: DsfrSpacings.s1w),
              _TitreFiltre(PocOffresStrings.typeDePublic),
              const SizedBox(height: DsfrSpacings.s1w),
              Wrap(
                spacing: DsfrSpacings.s1w,
                runSpacing: DsfrSpacings.s1w,
                children: [
                  DsfrTag(
                    label: PocOffresStrings.ouvertAuxMineurs,
                    size: DsfrComponentSize.md,
                    isSelected: _mineurs,
                    onSelectionChanged: (choisi) => setState(() => _mineurs = choisi),
                  ),
                  DsfrTag(
                    label: PocOffresStrings.accessiblePmr,
                    size: DsfrComponentSize.md,
                    isSelected: _pmr,
                    onSelectionChanged: (choisi) => setState(() => _pmr = choisi),
                  ),
                ],
              ),
              const SizedBox(height: DsfrSpacings.s3w),
              // Pas de « Jusqu'au » : l'API Engagement ne filtre que sur la date de début.
              _TitreFiltre(PocOffresStrings.periode),
              const SizedBox(height: DsfrSpacings.s1w),
              DsfrDateInput(
                key: ValueKey('date-$_version'),
                label: PocOffresStrings.aPartirDe,
                controller: _date,
                firstDate: DateTime(2026),
                lastDate: DateTime(2028, 12, 31),
                initialDate: _aPartirDu ?? DateTime.now(),
                locale: const Locale('fr', 'FR'),
                onChanged: (date) => setState(() {
                  _aPartirDu = date;
                  _date.text = date.toDay();
                }),
              ),
              const SizedBox(height: 200),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ColoredBox(
            color: DsfrColorDecisions.backgroundDefaultGrey(context),
            child: FilterButton(
              isEnabled: true,
              onReset: _reinitialiser,
              onPressed: () => Navigator.pop(
                context,
                PocFiltresBenevolat(
                  types: _types,
                  domaines: _domaines,
                  ouverteAuxMineurs: _mineurs,
                  accessiblePmr: _pmr,
                  aPartirDu: _aPartirDu,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TitreFiltre extends StatelessWidget {
  const _TitreFiltre(this.titre);

  final String titre;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(titre, style: DsfrTextStyle.bodyXlBold(color: DsfrColorDecisions.textTitleGrey(context))),
    );
  }
}
