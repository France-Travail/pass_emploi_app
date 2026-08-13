import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/network/post_evenement_engagement.dart';
import 'package:pass_emploi_app/pages/rendezvous/rendezvous_details_page.dart';
import 'package:pass_emploi_app/presentation/rendezvous/rendezvous_card_view_model.dart';
import 'package:pass_emploi_app/presentation/rendezvous/rendezvous_state_source.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/context_extensions.dart';
import 'package:pass_emploi_app/widgets/a11y/string_a11y_extensions.dart';
import 'package:pass_emploi_app/widgets/cards/base_cards/base_card.dart';
import 'package:pass_emploi_app/widgets/cards/base_cards/widgets/card_complement.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_card_semantics.dart';
import 'package:redux/redux.dart';

class RendezvousCard extends StatelessWidget {
  final RendezvousCardViewModel Function(Store<AppState>) converter;
  final VoidCallback onTap;
  final bool withChrome;

  const RendezvousCard({
    super.key,
    required this.converter,
    required this.onTap,
    this.withChrome = true,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, RendezvousCardViewModel>(
      converter: converter,
      builder: (context, viewModel) =>
          withChrome ? _ChromeContent(viewModel, onTap) : _EmbeddedContent(viewModel, onTap),
    );
  }
}

class _ChromeContent extends StatelessWidget {
  final RendezvousCardViewModel viewModel;
  final VoidCallback onTap;

  const _ChromeContent(this.viewModel, this.onTap);

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: onTap,
      imagePath: viewModel.assetImage,
      title: viewModel.title,
      tag: DsfrCategoryTag.evenement(label: viewModel.tag, typeCode: viewModel.typeCode),
      pillule: viewModel.isAnnule ? DsfrStatusBadge.canceled() : null,
      complements: [
        CardComplement.date(text: viewModel.date),
        CardComplement.hour(text: viewModel.hourAndDuration),
        if (viewModel.place != null) CardComplement.place(text: viewModel.place!),
        if (viewModel.nombreDePlacesRestantes != null) CardComplement.person(text: viewModel.nombreDePlacesRestantes!),
      ],
      secondaryTags: secondaryTags(viewModel.inscriptionStatus),
    );
  }

  List<Widget>? secondaryTags(InscriptionStatus inscriptionStatus) => switch (inscriptionStatus) {
        InscriptionStatus.inscrit => [
            DsfrCategoryTag.secondary(
              label: Strings.eventVousEtesDejaInscrit,
              icon: DsfrIcons.systemCheckboxCircleFill,
            ),
          ],
        InscriptionStatus.autodesinscription => [
            DsfrCategoryTag.secondary(label: Strings.eventAnnulerMonInscription),
          ],
        InscriptionStatus.notInscrit => [
            DsfrCategoryTag.secondary(label: Strings.eventInscrivezVousPourParticiper),
          ],
        InscriptionStatus.autoinscription => [
            DsfrCategoryTag.secondary(label: Strings.eventAutoInscription),
          ],
        InscriptionStatus.full => [
            DsfrStatusBadge.complet(),
          ],
        InscriptionStatus.hidden => null,
      };
}

class _EmbeddedContent extends StatelessWidget {
  final RendezvousCardViewModel viewModel;
  final VoidCallback onTap;

  const _EmbeddedContent(this.viewModel, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: DsfrSpacings.s1w,
                runSpacing: DsfrSpacings.s1w,
                children: [
                  DsfrCategoryTag.evenement(label: viewModel.tag, typeCode: viewModel.typeCode),
                  if (viewModel.isAnnule) DsfrStatusBadge.canceled(),
                ],
              ),
              const SizedBox(height: DsfrSpacings.s1w),
              Text(
                viewModel.title,
                style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
              const SizedBox(height: DsfrSpacings.s1v),
              _Complement(
                icon: DsfrIcons.systemTimeLine,
                text: viewModel.hourAndDuration,
                semanticsLabel: viewModel.hourAndDuration.toTimeAndDurationForScreenReaders(),
              ),
              if (viewModel.place != null) ...[
                const SizedBox(height: DsfrSpacings.s1v),
                _Complement(
                  icon: DsfrIcons.mapMapPin2Line,
                  text: viewModel.place!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Complement extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? semanticsLabel;

  const _Complement({
    required this.icon,
    required this.text,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final color = DsfrColorDecisions.textDefaultGrey(context);
    return Semantics(
      label: semanticsLabel,
      child: Row(
        children: [
          Icon(icon, size: DsfrSpacings.s2w, color: color),
          const SizedBox(width: DsfrSpacings.s1v),
          Expanded(
            child: ExcludeSemantics(
              excluding: semanticsLabel != null,
              child: Text(
                text,
                style: DsfrTextStyle.bodySm(color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension RendezvousCardFromId on String {
  Widget rendezvousCard({
    required BuildContext context,
    required RendezvousStateSource stateSource,
    required EvenementEngagement evenementEngagement,
    bool withChrome = true,
  }) {
    return RendezvousCard(
      converter: (store) => RendezvousCardViewModel.create(store, stateSource, this),
      withChrome: withChrome,
      onTap: () {
        context.trackEvenementEngagement(evenementEngagement);
        Navigator.push(
          context,
          RendezvousDetailsPage.materialPageRoute(_stateSource(stateSource), this),
        );
      },
    );
  }
}

RendezvousStateSource _stateSource(RendezvousStateSource stateSource) {
  // Pourquoi un switch ? Pour être sûr (compilation) de ne pas oublier un futur cas ajouté.
  return switch (stateSource) {
    RendezvousStateSource.eventListSessionsMilo ||
    RendezvousStateSource.accueilProchaineSession ||
    RendezvousStateSource.accueilLesEvenementsSession ||
    RendezvousStateSource.monSuiviSessionMilo ||
    RendezvousStateSource.sessionMiloDetails =>
      RendezvousStateSource.sessionMiloDetails,
    RendezvousStateSource.noSource ||
    RendezvousStateSource.accueilProchainRendezvous ||
    RendezvousStateSource.monSuivi ||
    RendezvousStateSource.eventListAnimationsCollectives ||
    RendezvousStateSource.accueilLesEvenements =>
      stateSource,
  };
}
