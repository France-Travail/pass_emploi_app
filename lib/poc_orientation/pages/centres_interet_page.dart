import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/poc_orientation/marche_travail.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/pages/tri_page.dart';
import 'package:pass_emploi_app/poc_orientation/parcours.dart';
import 'package:pass_emploi_app/poc_orientation/pistes_pour_toi.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/rome_api_client.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/poc_widgets.dart';
import 'package:pass_emploi_app/redux/app_state.dart';

// « Choisis ce que tu aimes » : jusqu'à 3 centres d'intérêt, dont les métiers rejoignent le tri.
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
  bool _enCours = false;
  (DsfrAlertType, String)? _alerte;

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
                  enabled: !_enCours && (_selection.contains(centre) || _selection.length < _maximum),
                  onChanged: (coche) => _basculer(centre, coche),
                ),
              ),
          ],
        ),
      ),
      bottom: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DsfrSpacings.s2w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_alerte case (final type, final texte)?) ...[
                Semantics(
                  liveRegion: true,
                  child: DsfrAlert(type: type, description: DsfrAlertDescriptionText(texte)),
                ),
                const SizedBox(height: DsfrSpacings.s2w),
              ],
              DsfrButton(
                label: _enCours ? PocOrientationStrings.centresEnCours : PocOrientationStrings.centresAjouter,
                variant: DsfrButtonVariant.primary,
                size: DsfrComponentSize.lg,
                onPressed: _selection.isEmpty || _enCours ? null : _ajouterAuTri,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _basculer(RomeCentreInteret centre, bool coche) {
    setState(() {
      _alerte = null;
      if (coche) {
        _selection.add(centre);
      } else {
        _selection.remove(centre);
      }
    });
  }

  // Un appel par centre d'intérêt, l'un après l'autre : ROME n'accepte qu'un appel par seconde.
  // En démo, seuls les métiers dont la fiche est dans la démo rejoignent le tri (aucun appel réseau).
  Future<void> _ajouterAuTri() async {
    final centres = [..._selection];
    final libelles = centres.map((centre) => centre.libelle).toList();
    final demo = StoreProvider.of<AppState>(context, listen: false).state.demoState;
    setState(() {
      _enCours = true;
      _alerte = null;
    });
    try {
      final parCentre = <List<RomeMetierResume>>[];
      for (final centre in centres) {
        final metiers = await RomeApiClient.instance.metiersDuCentreInteret(centre.code);
        parCentre.add(demo ? metiers.where((metier) => aUneFicheDeDemo(metier.code)).toList() : metiers);
      }
      MesPistes.instance.enregistrerCentresInteret(libelles);
      final choisis = metiersDesCentres(parCentre, MesPistes.instance.value);
      MesPistes.instance.ajouterAuTri(SourceAjout.centresInteret, choisis, libelles.join(', '));
      if (!mounted) return;
      if (choisis.isEmpty) {
        setState(() {
          _enCours = false;
          _alerte = (DsfrAlertType.info, PocOrientationStrings.centresAucunAjout);
        });
        return;
      }
      Navigator.pushReplacement(
        context,
        TriPage.route(
          message: PocOrientationStrings.centresAjoutes(choisis.length),
          dAbord: SourcePiste.centresInteret,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _enCours = false;
        _alerte = (DsfrAlertType.error, PocOrientationStrings.erreur);
      });
    }
  }
}
