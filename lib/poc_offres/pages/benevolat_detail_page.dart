import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:intl/intl.dart';
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

// « 7 novembre 2026 », sans le zéro de toDayWithFullMonth.
final _jourMoisAnnee = DateFormat('d MMMM yyyy', 'fr');

class MissionDetailPage extends StatefulWidget {
  const MissionDetailPage({super.key, required this.mission});

  final PocMission mission;

  static Route<void> route(PocMission mission) => MaterialPageRoute(builder: (_) => MissionDetailPage(mission: mission));

  @override
  State<MissionDetailPage> createState() => _MissionDetailPageState();
}

class _MissionDetailPageState extends State<MissionDetailPage> {
  late final String? _derniereAction = pocLibelleDerniereAction(widget.mission.id);

  @override
  void dispose() {
    PocOffresMemoire.instance.noterConsultation(widget.mission.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mission = widget.mission;
    return Scaffold(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      appBar: BackAppBar(
        actions: [
          PocEtoile(id: mission.id, titre: mission.titre),
          ShareButton(
            textToShare: mission.url,
            semanticsLabel: Strings.a11yPartagerOffreLabel,
            subjectForEmail: mission.titre,
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
                  PageTitle(PocOffresStrings.detailsMission),
                  const SizedBox(height: DsfrSpacings.s1w),
                  OffreDetailsHeader(
                    dateLabel: _derniereAction,
                    leading: DsfrCategoryTag.secteur(label: mission.domaine),
                    title: mission.titre,
                    subtitle: mission.organisation,
                    tags: _tags(mission),
                  ),
                  if (mission.prerequis.isNotEmpty) ...[
                    const SizedBox(height: DsfrSpacings.s3w),
                    _Prerequis(mission.prerequis),
                  ],
                  const SizedBox(height: DsfrSpacings.s3w),
                  OffreDetailsSectionTitle(PocOffresStrings.publicAide),
                  const SizedBox(height: DsfrSpacings.s2w),
                  Wrap(
                    spacing: DsfrSpacings.s1w,
                    runSpacing: DsfrSpacings.s1w,
                    children: [for (final public in mission.publicAide) OffreDetailsTag(label: public)],
                  ),
                  const SizedBox(height: DsfrSpacings.s3w),
                  OffreDetailsSectionTitle(PocOffresStrings.missionOuverte),
                  const SizedBox(height: DsfrSpacings.s2w),
                  Wrap(
                    spacing: DsfrSpacings.s1w,
                    runSpacing: DsfrSpacings.s1w,
                    children: [
                      OffreDetailsTag(
                        label: mission.ouverteAuxMineurs ? PocOffresStrings.auxMineurs : PocOffresStrings.auxMajeurs,
                      ),
                      if (mission.accessiblePmr) OffreDetailsTag(label: PocOffresStrings.accessiblePmr),
                    ],
                  ),
                  const SizedBox(height: DsfrSpacings.s3w),
                  OffreDetailsSectionTitle(PocOffresStrings.presentationMission),
                  const SizedBox(height: DsfrSpacings.s2w),
                  PocParagraphes(mission.description),
                  if (mission.accroche != null) ...[
                    const SizedBox(height: DsfrSpacings.s1w),
                    PocMiseEnAvant(texte: mission.accroche!),
                  ],
                  const SizedBox(height: DsfrSpacings.s3w),
                  OffreDetailsSectionTitle(PocOffresStrings.laStructure),
                  const SizedBox(height: DsfrSpacings.s2w),
                  OffreDetailsSectionTitle(
                    PocOffresStrings.decouvrez(mission.organisation),
                    size: OffreDetailsSectionTitleSize.headline6,
                  ),
                  const SizedBox(height: DsfrSpacings.s1w),
                  PocParagraphes([mission.organisationDescription]),
                ],
              ),
            ),
          ),
          OffreDetailsActionsFooter(
            actions: [
              OffreDetailsAction(
                label: PocOffresStrings.jeProposeMonAide,
                icon: DsfrIcons.systemExternalLinkLine,
                semanticsLink: true,
                onPressed: () => launchExternalUrl(mission.url),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<OffreDetailsTag> _tags(PocMission mission) {
    final dateFin = mission.dateFin;
    final engagement = mission.engagement;
    final rythmeDetail = mission.rythmeDetail;
    return [
      OffreDetailsTag.location(mission.lieu?.ville ?? PocOffresStrings.missionADistance),
      OffreDetailsTag(
        label: PocOffresStrings.aPartirDu(_jourMoisAnnee.format(mission.dateDebut)),
        icon: DsfrIcons.businessCalendarLine,
        iconSemanticLabel: Strings.iconAlternativeDateDeDebut,
      ),
      if (dateFin != null)
        OffreDetailsTag(
          label: PocOffresStrings.jusquAu(_jourMoisAnnee.format(dateFin)),
          icon: DsfrIcons.businessCalendarLine,
          iconSemanticLabel: Strings.iconAlternativeDateDeFin,
        ),
      if (engagement != null) OffreDetailsTag(label: engagement, icon: DsfrIcons.healthHeartPulseLine),
      OffreDetailsTag(
        label: rythmeDetail != null ? "${mission.rythme} · $rythmeDetail" : mission.rythme,
        icon: DsfrIcons.systemTimeLine,
        iconSemanticLabel: Strings.iconAlternativeHour,
      ),
      OffreDetailsTag(label: PocOffresStrings.benevolesRecherches(mission.places), icon: DsfrIcons.userGroupLine),
    ];
  }
}

class _Prerequis extends StatelessWidget {
  const _Prerequis(this.prerequis);

  final List<String> prerequis;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DsfrColorDecisions.backgroundAltBlueFrance(context),
        border: Border.all(color: DsfrColorDecisions.artworkDecorativeBlueFrance(context)),
        borderRadius: BorderRadius.circular(DsfrSpacings.s1v),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(DsfrIcons.userUserSearchLine, size: DsfrSpacings.s4w, color: DsfrColorDecisions.textActionHighBlueFrance(context)),
            const SizedBox(width: DsfrSpacings.s2w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      PocOffresStrings.prerequis,
                      style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textActionHighBlueFrance(context)),
                    ),
                  ),
                  const SizedBox(height: DsfrSpacings.s1w),
                  PocPuces(prerequis, numerotees: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
