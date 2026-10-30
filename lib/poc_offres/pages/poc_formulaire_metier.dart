import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/location.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_modeles.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_strings.dart';
import 'package:pass_emploi_app/poc_offres/widgets/poc_offres_champs.dart';
import 'package:pass_emploi_app/poc_offres/widgets/poc_offres_widgets.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/bottom_sheets.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/filtres_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/buttons/filter_button.dart';
import 'package:pass_emploi_app/widgets/slider/distance_slider.dart';

// Critères communs à l'alternance et aux formations : La bonne alternance ne cherche que par code métier
// (ROME), d'où un métier choisi dans une liste au lieu d'un mot-clé libre.
class PocFormulaireMetier extends StatefulWidget {
  const PocFormulaireMetier({
    super.key,
    required this.libelleLieu,
    required this.libelleBouton,
    required this.metier,
    required this.lieu,
    required this.rayon,
    required this.recentes,
    required this.onRechercher,
  });

  final String libelleLieu;
  final String libelleBouton;
  final PocMetier? metier;
  final Location? lieu;
  final int rayon;
  final List<PocCriteresMetier> recentes;
  final ValueChanged<PocCriteresMetier> onRechercher;

  @override
  State<PocFormulaireMetier> createState() => _PocFormulaireMetierState();
}

class _PocFormulaireMetierState extends State<PocFormulaireMetier> {
  late PocMetier? _metier = widget.metier;
  late Location? _lieu = widget.lieu;
  late int _rayon = widget.rayon;

  @override
  Widget build(BuildContext context) {
    final metier = _metier;
    final lieu = _lieu;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PocChampMetier(valeur: metier, onChange: (choix) => setState(() => _metier = choix)),
        const SizedBox(height: DsfrSpacings.s2w),
        PocChampCommune(titre: widget.libelleLieu, valeur: lieu, onChange: (choix) => setState(() => _lieu = choix)),
        const SizedBox(height: DsfrSpacings.s2w),
        DistanceSlider(initialDistanceValue: _rayon.toDouble(), onValueChange: (valeur) => _rayon = valeur.round()),
        const SizedBox(height: DsfrSpacings.s3w),
        DsfrButton(
          label: widget.libelleBouton,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: metier != null && lieu != null
              ? () => widget.onRechercher(PocCriteresMetier(metier: metier, lieu: lieu, rayon: _rayon))
              : null,
        ),
        PocRecherchesRecentes(
          libelles: [for (final recherche in widget.recentes) recherche.libelleAvecRayon],
          onTap: (index) => widget.onRechercher(widget.recentes[index]),
        ),
      ],
    );
  }
}

Future<PocFiltresNiveau?> pocOuvrirFiltresNiveau(BuildContext context, String titre, PocFiltresNiveau initiaux) {
  return showPassEmploiBottomSheet<PocFiltresNiveau>(
    context: context,
    builder: (_) => FiltresBottomSheet(title: titre, body: _FiltresNiveau(initiaux: initiaux)),
  );
}

// Pas de filtre « Type de contrat » : l'API publique de La bonne alternance ne le propose pas.
class _FiltresNiveau extends StatefulWidget {
  const _FiltresNiveau({required this.initiaux});

  final PocFiltresNiveau initiaux;

  @override
  State<_FiltresNiveau> createState() => _FiltresNiveauState();
}

class _FiltresNiveauState extends State<_FiltresNiveau> {
  late final Set<PocNiveau> _niveaux = {...widget.initiaux.niveaux};

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    PocOffresStrings.niveauEtudes,
                    style: DsfrTextStyle.bodyXlBold(color: DsfrColorDecisions.textTitleGrey(context)),
                  ),
                ),
                const SizedBox(height: DsfrSpacings.s2w),
                for (final niveau in PocNiveau.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: DsfrSpacings.s2w),
                    child: DsfrCheckbox(
                      label: niveau.libelle,
                      size: DsfrComponentSize.md,
                      value: _niveaux.contains(niveau),
                      onChanged: (coche) => setState(() => coche ? _niveaux.add(niveau) : _niveaux.remove(niveau)),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        FilterButton(
          isEnabled: true,
          onReset: () => setState(_niveaux.clear),
          onPressed: () => Navigator.pop(context, PocFiltresNiveau({..._niveaux})),
        ),
      ],
    );
  }
}
