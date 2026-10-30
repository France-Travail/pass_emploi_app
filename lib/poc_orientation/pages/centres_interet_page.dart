import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/poc_orientation/pages/metiers_liste_page.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/rome_api_client.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/poc_widgets.dart';

class CentresInteretPage extends StatefulWidget {
  const CentresInteretPage({super.key});

  static Route<void> route() => MaterialPageRoute(builder: (_) => const CentresInteretPage());

  @override
  State<CentresInteretPage> createState() => _CentresInteretPageState();
}

class _CentresInteretPageState extends State<CentresInteretPage> {
  static const _maximum = 3;

  late Future<List<RomeCentreInteret>> _centres = RomeApiClient.instance.centresInteret();
  final _selection = <RomeCentreInteret>[];

  @override
  Widget build(BuildContext context) {
    return PocScaffold(
      titre: PocOrientationStrings.centresTitre,
      body: PocFuture<List<RomeCentreInteret>>(
        future: _centres,
        onRetry: () => setState(() => _centres = RomeApiClient.instance.centresInteret()),
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        builder: (context, centres) => ListView(
          padding: const EdgeInsets.all(DsfrSpacings.s2w),
          children: [
            Text(
              PocOrientationStrings.centresIntro,
              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
            ),
            const SizedBox(height: DsfrSpacings.s1w),
            Semantics(
              liveRegion: true,
              child: Text(
                PocOrientationStrings.centresSelection(_selection.length),
                style: DsfrTextStyle.bodySmBold(color: DsfrColorDecisions.textMentionGrey(context)),
              ),
            ),
            const SizedBox(height: DsfrSpacings.s2w),
            for (final centre in centres)
              Padding(
                padding: const EdgeInsets.only(bottom: DsfrSpacings.s2w),
                child: DsfrCheckbox(
                  label: centre.libelle,
                  size: DsfrComponentSize.md,
                  value: _selection.contains(centre),
                  enabled: _selection.contains(centre) || _selection.length < _maximum,
                  onChanged: (coche) => _basculer(centre, coche),
                ),
              ),
          ],
        ),
      ),
      bottom: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DsfrSpacings.s2w),
          child: DsfrButton(
            label: PocOrientationStrings.centresVoirMetiers,
            variant: DsfrButtonVariant.primary,
            size: DsfrComponentSize.lg,
            onPressed: _selection.isEmpty ? null : _voirMetiers,
          ),
        ),
      ),
    );
  }

  void _basculer(RomeCentreInteret centre, bool coche) {
    setState(() {
      if (coche) {
        _selection.add(centre);
      } else {
        _selection.remove(centre);
      }
    });
  }

  void _voirMetiers() {
    final centres = [..._selection];
    Navigator.push(
      context,
      MetiersListePage.route(
        titre: PocOrientationStrings.centresMetiersTitre,
        intro: PocOrientationStrings.centresMetiersIntro(centres.map((centre) => centre.libelle).toList()),
        charger: () => _metiersPour(centres),
      ),
    );
  }

  // Un appel par centre d'intérêt, l'un après l'autre : ROME n'accepte qu'un appel par seconde.
  static Future<List<PocMetierAffiche>> _metiersPour(List<RomeCentreInteret> centres) async {
    final metiers = <String, RomeMetierResume>{};
    final enCommun = <String, int>{};
    for (final centre in centres) {
      for (final metier in await RomeApiClient.instance.metiersDuCentreInteret(centre.code)) {
        metiers[metier.code] = metier;
        enCommun[metier.code] = (enCommun[metier.code] ?? 0) + 1;
      }
    }
    final tries = metiers.values.toList()
      ..sort((a, b) {
        final ecart = enCommun[b.code]!.compareTo(enCommun[a.code]!);
        return ecart != 0 ? ecart : a.libelle.compareTo(b.libelle);
      });
    return [
      for (final metier in tries)
        PocMetierAffiche(
          metier,
          centres.length > 1 ? PocOrientationStrings.centresEnCommun(enCommun[metier.code]!) : null,
        ),
    ];
  }
}
