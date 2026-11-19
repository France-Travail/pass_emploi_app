import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/poc_orientation/donnees_parcours.dart';
import 'package:pass_emploi_app/poc_orientation/marche_travail.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/pages/fiche_metier_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/trouver_des_idees_page.dart';
import 'package:pass_emploi_app/poc_orientation/parcours.dart';
import 'package:pass_emploi_app/poc_orientation/pistes_pour_toi.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/poc_passerelles.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/carte_a_trier.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/piste_widgets.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/poc_widgets.dart';
import 'package:pass_emploi_app/redux/app_state.dart';

// « Faire le tri » : les métiers pour toi, un à la fois. « Ça me tente » ou « Pas pour moi » (boutons, ou glisser du
// doigt à droite ou à gauche). La liste est figée à l'ouverture : les métiers qui arrivent pendant le tri (voisins d'une
// piste aimée) attendent le prochain tri. Un métier trié ailleurs (depuis sa fiche) est sauté.
class TriPage extends StatefulWidget {
  const TriPage({super.key, this.message, this.dAbord});

  // Rappel affiché sur la première carte, par exemple « 8 métiers ajoutés à ton tri, d'après ce que tu aimes ».
  final String? message;

  // Les métiers venus du test (ou de ce que le jeune aime) passent en premier quand il arrive de là.
  final SourcePiste? dAbord;

  static Route<void> route({String? message, SourcePiste? dAbord}) {
    return MaterialPageRoute(builder: (_) => TriPage(message: message, dAbord: dAbord));
  }

  @override
  State<TriPage> createState() => _TriPageState();
}

class _TriPageState extends State<TriPage> {
  late final Future<DonneesParcours> _donnees;
  List<PisteProposee>? _lot;
  Set<RaisonPasPourMoi> _raisonsEnAttente = const {};

  @override
  void initState() {
    super.initState();
    ouvrirMesPistes(context);
    _donnees = chargerDonneesParcours(StoreProvider.of<AppState>(context, listen: false).state);
    demanderLesDonneesDuJeune(context);
  }

  @override
  Widget build(BuildContext context) {
    return PocScaffold(
      titre: PocOrientationStrings.triTitre,
      body: StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) => FutureBuilder<DonneesParcours>(
          future: _donnees,
          builder: (context, snapshot) {
            if (!snapshot.hasData || (_lot == null && donneesDuJeuneEnChargement(state))) {
              return Center(child: CircularProgressIndicator(semanticsLabel: PocOrientationStrings.chargement));
            }
            final donnees = snapshot.data!;
            return ValueListenableBuilder<MesPistesEtat>(
              valueListenable: MesPistes.instance,
              builder: (context, etat, _) {
                final lot = _lot ??= mettreDevant(metiersATrier(state, etat, donnees), widget.dAbord);
                if (lot.isEmpty) return const _TriVide();
                final restants = [
                  for (final piste in lot)
                    if (etat.piste(piste.metier.code) == null) piste,
                ];
                if (restants.isEmpty) return _FinDuTri(lot: lot, etat: etat);
                return _Tri(
                  courant: restants.first,
                  position: lot.length - restants.length + 1,
                  total: lot.length,
                  marche: marchePourLeJeune(state, donnees.marche),
                  message: restants.length == lot.length ? widget.message : null,
                  onConfirmerGlisser: _confirmerGlisser,
                  onGlisse: _glisse,
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Glisser à gauche demande les raisons (le jeune peut annuler : la carte revient) ; à droite, c'est « Ça me tente ».
  Future<bool> _confirmerGlisser(DismissDirection direction) async {
    if (direction == DismissDirection.startToEnd) return true;
    final raisons = await choisirRaisons(context);
    if (raisons == null) return false;
    _raisonsEnAttente = raisons;
    return true;
  }

  void _glisse(PisteProposee piste, DismissDirection direction) {
    if (direction == DismissDirection.startToEnd) {
      MesPistes.instance.meTente(piste.metier);
    } else {
      MesPistes.instance.pasPourMoi(piste.metier, _raisonsEnAttente);
    }
  }
}

class _Tri extends StatelessWidget {
  const _Tri({
    required this.courant,
    required this.position,
    required this.total,
    required this.marche,
    required this.message,
    required this.onConfirmerGlisser,
    required this.onGlisse,
  });

  final PisteProposee courant;
  final int position;
  final int total;
  final MarcheTravail? marche;
  final String? message;
  final Future<bool> Function(DismissDirection direction) onConfirmerGlisser;
  final void Function(PisteProposee piste, DismissDirection direction) onGlisse;

  @override
  Widget build(BuildContext context) {
    final metier = courant.metier;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(DsfrSpacings.s2w, DsfrSpacings.s1w, DsfrSpacings.s2w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      PocOrientationStrings.triGlisser,
                      style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textMentionGrey(context)),
                    ),
                  ),
                  const SizedBox(width: DsfrSpacings.s2w),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      PocOrientationStrings.triCompteur(position, total),
                      style: DsfrTextStyle.bodySmBold(color: DsfrColorDecisions.textMentionGrey(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DsfrSpacings.s1w),
              ExcludeSemantics(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: position / total,
                    minHeight: 6,
                    color: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
                    backgroundColor: DsfrColorDecisions.backgroundContrastGrey(context),
                  ),
                ),
              ),
              if (message case final message?) ...[
                const SizedBox(height: DsfrSpacings.s2w),
                DsfrAlert(type: DsfrAlertType.success, description: DsfrAlertDescriptionText(message)),
              ],
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DsfrSpacings.s2w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Dismissible(
                  key: ValueKey(metier.code),
                  confirmDismiss: onConfirmerGlisser,
                  onDismissed: (direction) => onGlisse(courant, direction),
                  background: _FondGlisser(
                    texte: PocOrientationStrings.avisMeTente,
                    icone: DsfrIcons.healthHeartLine,
                    alignement: Alignment.centerLeft,
                    couleur: DsfrColorDecisions.backgroundContrastSuccess(context),
                  ),
                  secondaryBackground: _FondGlisser(
                    texte: PocOrientationStrings.avisPasPourMoi,
                    icone: DsfrIcons.systemCloseLine,
                    alignement: Alignment.centerRight,
                    couleur: DsfrColorDecisions.backgroundContrastGrey(context),
                  ),
                  child: CarteATrier(piste: courant, marche: marche),
                ),
                const SizedBox(height: DsfrSpacings.s1w),
                Align(
                  alignment: Alignment.centerLeft,
                  child: DsfrButton(
                    label: PocOrientationStrings.triVoirFiche,
                    icon: DsfrIcons.systemArrowRightSLine,
                    iconLocation: DsfrButtonIconLocation.right,
                    variant: DsfrButtonVariant.tertiaryWithoutBorder,
                    size: DsfrComponentSize.md,
                    onPressed: () => Navigator.push(context, FicheMetierPage.route(metier)),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Les deux boutons restent sous le pouce, séparés de la carte qui défile.
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: DsfrColorDecisions.borderDefaultGrey(context))),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(DsfrSpacings.s2w),
              child: Row(
                children: [
                  Expanded(
                    child: DsfrButton(
                      label: PocOrientationStrings.avisPasPourMoi,
                      icon: DsfrIcons.systemCloseLine,
                      variant: DsfrButtonVariant.secondary,
                      size: DsfrComponentSize.md,
                      onPressed: () => mettreDeCote(context, metier),
                    ),
                  ),
                  const SizedBox(width: DsfrSpacings.s2w),
                  Expanded(
                    child: DsfrButton(
                      label: PocOrientationStrings.avisMeTente,
                      icon: DsfrIcons.healthHeartLine,
                      variant: DsfrButtonVariant.primary,
                      size: DsfrComponentSize.md,
                      onPressed: () => MesPistes.instance.meTente(metier),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FondGlisser extends StatelessWidget {
  const _FondGlisser({required this.texte, required this.icone, required this.alignement, required this.couleur});

  final String texte;
  final IconData icone;
  final Alignment alignement;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    final encre = DsfrColorDecisions.textTitleGrey(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: couleur, borderRadius: BorderRadius.circular(12)),
      child: Align(
        alignment: alignement,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s3w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, color: encre),
              const SizedBox(width: DsfrSpacings.s1w),
              Text(texte, style: DsfrTextStyle.bodyMdBold(color: encre)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinDuTri extends StatelessWidget {
  const _FinDuTri({required this.lot, required this.etat});

  final List<PisteProposee> lot;
  final MesPistesEtat etat;

  @override
  Widget build(BuildContext context) {
    final tentent = [
      for (final piste in lot)
        if (etat.piste(piste.metier.code)?.avis == AvisMetier.meTente) piste.metier,
    ];
    final misDeCote = lot.where((piste) => etat.piste(piste.metier.code)?.avis == AvisMetier.pasPourMoi).length;
    return ListView(
      padding: const EdgeInsets.all(DsfrSpacings.s3w),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: DsfrColorDecisions.backgroundContrastSuccess(context),
              shape: BoxShape.circle,
            ),
            child: Icon(DsfrIcons.systemCheckLine, color: DsfrColorDecisions.textDefaultSuccess(context), size: 28),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        Semantics(
          headingLevel: 1,
          child: Text(
            PocOrientationStrings.finTriTitre,
            style: DsfrTextStyle.headline3(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        PocSectionTitre(PocOrientationStrings.finTriTentent(tentent.length)),
        const SizedBox(height: DsfrSpacings.s1w),
        for (final metier in tentent)
          Padding(
            padding: const EdgeInsets.only(bottom: DsfrSpacings.s1w),
            child: Text(
              metier.libelle,
              style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textActionHighBlueFrance(context)),
            ),
          ),
        if (misDeCote > 0) ...[
          const SizedBox(height: DsfrSpacings.s2w),
          Text(
            PocOrientationStrings.finTriMisDeCote(misDeCote),
            style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
          ),
        ],
        const SizedBox(height: DsfrSpacings.s4w),
        DsfrButton(
          label: tentent.isEmpty ? PocOrientationStrings.autresIdeesTitre : PocOrientationStrings.finTriAvancer,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: () {
            final navigateur = Navigator.of(context);
            revenirAExplorerMetiers(navigateur);
            if (tentent.isEmpty) navigateur.push(TrouverDesIdeesPage.route());
          },
        ),
      ],
    );
  }
}

class _TriVide extends StatelessWidget {
  const _TriVide();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(DsfrSpacings.s3w),
      children: [
        Semantics(
          headingLevel: 1,
          child: Text(
            PocOrientationStrings.triVideTitre,
            style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        Text(
          PocOrientationStrings.triVideTexte,
          style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        DsfrButton(
          label: PocOrientationStrings.heroIdeesTitre,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: () => Navigator.pushReplacement(context, TrouverDesIdeesPage.route()),
        ),
      ],
    );
  }
}
