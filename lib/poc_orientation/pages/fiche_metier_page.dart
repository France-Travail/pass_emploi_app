import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/poc_orientation/mes_metiers.dart';
import 'package:pass_emploi_app/poc_orientation/pages/formations_metier_page.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/poc_passerelles.dart';
import 'package:pass_emploi_app/poc_orientation/riasec.dart';
import 'package:pass_emploi_app/poc_orientation/rome_api_client.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/poc_widgets.dart';

class FicheMetierPage extends StatefulWidget {
  const FicheMetierPage({super.key, required this.metier});

  final RomeMetierResume metier;

  static Route<void> route(RomeMetierResume metier) => MaterialPageRoute(builder: (_) => FicheMetierPage(metier: metier));

  @override
  State<FicheMetierPage> createState() => _FicheMetierPageState();
}

class _FicheMetierPageState extends State<FicheMetierPage> {
  late Future<RomeFicheMetier> _fiche = RomeApiClient.instance.ficheMetier(widget.metier.code);

  @override
  Widget build(BuildContext context) {
    return PocScaffold(
      titre: PocOrientationStrings.ficheTitre,
      body: PocFuture<RomeFicheMetier>(
        future: _fiche,
        onRetry: () => setState(() => _fiche = RomeApiClient.instance.ficheMetier(widget.metier.code)),
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        builder: (context, fiche) => _Contenu(fiche: fiche),
      ),
    );
  }
}

class _Contenu extends StatelessWidget {
  const _Contenu({required this.fiche});

  final RomeFicheMetier fiche;

  @override
  Widget build(BuildContext context) {
    final texte = DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context));
    final badges = [
      if (fiche.emploiReglemente)
        DsfrBadge(label: PocOrientationStrings.ficheReglemente, type: DsfrBadgeType.warning, size: DsfrComponentSize.sm),
      if (fiche.transitionEcologique)
        DsfrBadge(
          label: PocOrientationStrings.ficheTransitionEcologique,
          type: DsfrBadgeType.success,
          size: DsfrComponentSize.sm,
        ),
      if (fiche.transitionNumerique)
        DsfrBadge(
          label: PocOrientationStrings.ficheTransitionNumerique,
          type: DsfrBadgeType.information,
          size: DsfrComponentSize.sm,
        ),
    ];
    return ListView(
      padding: const EdgeInsets.all(DsfrSpacings.s2w),
      children: [
        if (badges.isNotEmpty) ...[
          Wrap(spacing: DsfrSpacings.s1w, runSpacing: DsfrSpacings.s1w, children: badges),
          const SizedBox(height: DsfrSpacings.s2w),
        ],
        Semantics(
          header: true,
          child: Text(fiche.libelle, style: DsfrTextStyle.headline3(color: DsfrColorDecisions.textTitleGrey(context))),
        ),
        if (fiche.domaine case final domaine?) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          Text(domaine, style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context))),
        ],
        const SizedBox(height: DsfrSpacings.s2w),
        Align(alignment: Alignment.centerLeft, child: _BoutonMesMetiers(fiche: fiche)),
        if (fiche.enBref case final enBref? when !_enBrefAnnonceLaListe) ...[
          const SizedBox(height: DsfrSpacings.s3w),
          PocSectionTitre(PocOrientationStrings.ficheEnBref),
          const SizedBox(height: DsfrSpacings.s2w),
          DsfrHighlight(text: enBref, size: DsfrComponentSize.md),
        ],
        if (fiche.auQuotidien.isNotEmpty) ...[
          const SizedBox(height: DsfrSpacings.s4w),
          PocSectionTitre(PocOrientationStrings.ficheQuotidien),
          const SizedBox(height: DsfrSpacings.s2w),
          if (_enBrefAnnonceLaListe) ...[
            Text(fiche.enBref!, style: texte),
            const SizedBox(height: DsfrSpacings.s1w),
          ],
          PocPuces(fiche.auQuotidien),
        ],
        ..._section(PocOrientationStrings.ficheCompetences, fiche.competences),
        ..._section(PocOrientationStrings.ficheQualites, fiche.qualites),
        if (fiche.acces.isNotEmpty) ...[
          const SizedBox(height: DsfrSpacings.s4w),
          PocSectionTitre(PocOrientationStrings.ficheAcces),
          const SizedBox(height: DsfrSpacings.s2w),
          for (final ligne in fiche.acces)
            Padding(padding: const EdgeInsets.only(bottom: DsfrSpacings.s1w), child: Text(ligne, style: texte)),
        ],
        if (fiche.contextes.isNotEmpty) ...[
          const SizedBox(height: DsfrSpacings.s4w),
          PocSectionTitre(PocOrientationStrings.ficheConditions),
          const SizedBox(height: DsfrSpacings.s2w),
          for (final groupe in fiche.contextes) ...[
            Text(groupe.categorie, style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context))),
            const SizedBox(height: DsfrSpacings.s1w),
            PocPuces(groupe.libelles),
          ],
        ],
        ..._section(PocOrientationStrings.ficheCentresInteret, fiche.centresInteret),
        if (_profilRiasec() case final profil?) ...[
          const SizedBox(height: DsfrSpacings.s4w),
          PocSectionTitre(PocOrientationStrings.ficheProfil),
          const SizedBox(height: DsfrSpacings.s1w),
          Text(profil, style: texte),
        ],
        if (fiche.appellations.isNotEmpty) ...[
          const SizedBox(height: DsfrSpacings.s4w),
          PocSectionTitre(PocOrientationStrings.ficheAussiAppele),
          const SizedBox(height: DsfrSpacings.s1w),
          Text(fiche.appellations.join(' · '), style: texte),
        ],
        const SizedBox(height: DsfrSpacings.s4w),
        _EtMaintenant(fiche: fiche),
        const SizedBox(height: DsfrSpacings.s3w),
        PocMention(PocOrientationStrings.ficheSource(fiche.code)),
      ],
    );
  }

  // Certaines définitions ROME s'arrêtent sur « Ainsi, il : » et annoncent la liste qui suit.
  bool get _enBrefAnnonceLaListe => fiche.auQuotidien.isNotEmpty && (fiche.enBref?.trimRight().endsWith(':') ?? false);

  List<Widget> _section(String titre, List<String> lignes) {
    if (lignes.isEmpty) return [];
    return [
      const SizedBox(height: DsfrSpacings.s4w),
      PocSectionTitre(titre),
      const SizedBox(height: DsfrSpacings.s2w),
      PocPuces(lignes),
    ];
  }

  String? _profilRiasec() {
    final types = [fiche.riasecMajeur, fiche.riasecMineur]
        .map((lettre) => Riasec.values.where((type) => type.lettre == lettre).firstOrNull)
        .nonNulls
        .toList();
    if (types.isEmpty) return null;
    return '${types.map((type) => type.lettre).join(' + ')} : ${types.map((type) => type.nom).join(' et ')}';
  }
}

class _BoutonMesMetiers extends StatelessWidget {
  const _BoutonMesMetiers({required this.fiche});

  final RomeFicheMetier fiche;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<RomeMetierResume>>(
      valueListenable: MesMetiers.instance,
      builder: (context, _, __) {
        final retenu = MesMetiers.instance.contient(fiche.code);
        return DsfrButton(
          label: retenu ? PocOrientationStrings.ficheRetirer : PocOrientationStrings.ficheAjouter,
          icon: retenu ? DsfrIcons.businessBookmarkFill : DsfrIcons.businessBookmarkLine,
          variant: DsfrButtonVariant.tertiary,
          size: DsfrComponentSize.md,
          onPressed: () => MesMetiers.instance.basculer(fiche.resume),
        );
      },
    );
  }
}

class _EtMaintenant extends StatelessWidget {
  const _EtMaintenant({required this.fiche});

  final RomeFicheMetier fiche;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PocSectionTitre(PocOrientationStrings.ficheEtMaintenant),
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrButton(
          label: PocOrientationStrings.ficheVoirOffres,
          icon: DsfrIcons.businessBriefcaseLine,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: () => ouvrirRechercheOffres(context, fiche, alternance: false),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrButton(
          label: PocOrientationStrings.ficheImmersion,
          icon: DsfrIcons.mapMapPin2Line,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.lg,
          onPressed: () => ouvrirRechercheImmersion(context, fiche),
        ),
        if (peutChercherAlternance(context)) ...[
          const SizedBox(height: DsfrSpacings.s2w),
          DsfrButton(
            label: PocOrientationStrings.ficheAlternance,
            variant: DsfrButtonVariant.secondary,
            size: DsfrComponentSize.lg,
            onPressed: () => ouvrirRechercheOffres(context, fiche, alternance: true),
          ),
        ],
        const SizedBox(height: DsfrSpacings.s4w),
        PocSectionTitre(PocOrientationStrings.ficheSeFormer),
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrButton(
          label: PocOrientationStrings.ficheVoirFormations,
          icon: DsfrIcons.documentBook2Line,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.lg,
          onPressed: () => Navigator.push(context, FormationsMetierPage.route(fiche)),
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        Text(
          PocOrientationStrings.ficheAutresSources,
          style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        PocLienExterne(
          label: PocOrientationStrings.ficheFormationAlternance,
          onTap: () => ouvrirFormationsAlternance(fiche),
        ),
        PocLienExterne(
          label: PocOrientationStrings.ficheFormationContinue,
          onTap: () => ouvrirFormationsFranceTravail(fiche),
        ),
        PocLienExterne(label: PocOrientationStrings.ficheFormationInitiale, onTap: ouvrirFormationsOnisep),
      ],
    );
  }
}
