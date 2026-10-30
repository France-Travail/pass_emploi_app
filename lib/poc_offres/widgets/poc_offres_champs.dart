import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/location.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_donnees.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_modeles.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_strings.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/utils/debounce_text_form_field.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/utils/full_screen_text_form_field_scaffold.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/utils/multiline_app_bar.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/utils/read_only_text_form_field.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/utils/text_form_field_sep_line.dart';

// Mêmes champs que MetierAutocomplete et LocationAutocomplete, mais sur des listes en dur : aucun appel.

class PocChampMetier extends StatelessWidget {
  const PocChampMetier({super.key, required this.valeur, required this.onChange});

  final PocMetier? valeur;
  final ValueChanged<PocMetier?> onChange;

  @override
  Widget build(BuildContext context) {
    return _PocChamp<PocMetier>(
      titre: PocOffresStrings.metier,
      aide: PocOffresStrings.metierAide,
      heroTag: 'pocMetier',
      libelleSuppression: PocOffresStrings.metierSuppression,
      aucunResultat: PocOffresStrings.metierAucun,
      valeur: valeur,
      libelle: (metier) => metier.libelle,
      rechercher: pocMetiersCorrespondants,
      onChange: onChange,
    );
  }
}

class PocChampCommune extends StatelessWidget {
  const PocChampCommune({super.key, required this.titre, required this.valeur, required this.onChange});

  final String titre;
  final Location? valeur;
  final ValueChanged<Location?> onChange;

  @override
  Widget build(BuildContext context) {
    return _PocChamp<Location>(
      titre: titre,
      aide: PocOffresStrings.lieuAide,
      heroTag: 'pocCommune',
      libelleSuppression: PocOffresStrings.communeSuppression,
      aucunResultat: PocOffresStrings.communeAucune,
      valeur: valeur,
      libelle: (commune) => commune.codePostal != null ? "${commune.libelle} (${commune.codePostal})" : commune.libelle,
      rechercher: pocCommunesCorrespondantes,
      onChange: onChange,
    );
  }
}

class _PocChamp<T> extends StatelessWidget {
  const _PocChamp({
    required this.titre,
    required this.aide,
    required this.heroTag,
    required this.libelleSuppression,
    required this.aucunResultat,
    required this.valeur,
    required this.libelle,
    required this.rechercher,
    required this.onChange,
  });

  final String titre;
  final String aide;
  final String heroTag;
  final String libelleSuppression;
  final String aucunResultat;
  final T? valeur;
  final String Function(T) libelle;
  final List<T> Function(String saisie) rechercher;
  final ValueChanged<T?> onChange;

  @override
  Widget build(BuildContext context) {
    final valeur = this.valeur;
    return ReadOnlyTextFormField(
      title: titre,
      hint: aide,
      heroTag: heroTag,
      a11ySuppressionLabel: libelleSuppression,
      textFormFieldKey: Key(valeur != null ? libelle(valeur) : '$heroTag-vide'),
      withDeleteButton: valeur != null,
      initialValue: valeur != null ? libelle(valeur) : null,
      onDeleteTap: () => onChange(null),
      onTextTap: () async {
        final choix = await Navigator.push<T>(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => _PocChoixPage<T>(
              titre: titre,
              aide: aide,
              heroTag: heroTag,
              aucunResultat: aucunResultat,
              saisieInitiale: valeur != null ? libelle(valeur) : null,
              libelle: libelle,
              rechercher: rechercher,
            ),
          ),
        );
        if (choix != null) onChange(choix);
      },
    );
  }
}

class _PocChoixPage<T> extends StatefulWidget {
  const _PocChoixPage({
    required this.titre,
    required this.aide,
    required this.heroTag,
    required this.aucunResultat,
    required this.saisieInitiale,
    required this.libelle,
    required this.rechercher,
  });

  final String titre;
  final String aide;
  final String heroTag;
  final String aucunResultat;
  final String? saisieInitiale;
  final String Function(T) libelle;
  final List<T> Function(String saisie) rechercher;

  @override
  State<_PocChoixPage<T>> createState() => _PocChoixPageState<T>();
}

class _PocChoixPageState<T> extends State<_PocChoixPage<T>> {
  late List<T> _choix;

  @override
  void initState() {
    super.initState();
    // La saisie initiale est le libellé déjà choisi : on propose toute la liste plutôt que ce seul élément.
    _choix = widget.rechercher('');
  }

  @override
  Widget build(BuildContext context) {
    return FullScreenTextFormFieldScaffold(
      body: Column(
        children: [
          MultilineAppBar(title: widget.titre, hint: widget.aide, onCloseButtonPressed: () => Navigator.pop(context)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
            child: Semantics(
              label: widget.titre,
              child: DebounceTextFormField(
                heroTag: widget.heroTag,
                initialValue: widget.saisieInitiale,
                onChanged: (saisie) => setState(() => _choix = widget.rechercher(saisie)),
              ),
            ),
          ),
          TextFormFieldSepLine(),
          Expanded(
            child: _choix.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(DsfrSpacings.s3w),
                    child: Text(
                      widget.aucunResultat,
                      style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textMentionGrey(context)),
                    ),
                  )
                : ListView.separated(
                    itemCount: _choix.length,
                    separatorBuilder: (_, __) => TextFormFieldSepLine(),
                    itemBuilder: (context, index) {
                      final choix = _choix[index];
                      return Semantics(
                        button: true,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s3w),
                          title: Text(
                            widget.libelle(choix),
                            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                          ),
                          onTap: () => Navigator.pop(context, choix),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
