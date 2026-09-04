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
import 'package:pass_emploi_app/widgets/dsfr/dsfr_card_semantics.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_event_card.dart';
import 'package:redux/redux.dart';

class RendezvousCard extends StatelessWidget {
  final RendezvousCardViewModel Function(Store<AppState>) converter;
  final VoidCallback? onTap;
  final bool withChrome;
  final bool showDate;

  const RendezvousCard({
    super.key,
    required this.converter,
    this.onTap,
    this.withChrome = true,
    this.showDate = false,
  }) : assert(!withChrome || onTap != null);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, RendezvousCardViewModel>(
      converter: converter,
      builder: (context, viewModel) => withChrome
          ? _ChromeContent(viewModel, onTap!, showDate: showDate)
          : _EmbeddedContent(viewModel, showDate: showDate),
    );
  }
}

class _ChromeContent extends StatelessWidget {
  final RendezvousCardViewModel viewModel;
  final VoidCallback onTap;
  final bool showDate;

  const _ChromeContent(this.viewModel, this.onTap, {required this.showDate});

  @override
  Widget build(BuildContext context) {
    return DsfrEventCard(
      onTap: onTap,
      emoji: viewModel.emoji,
      emojiBackgroundColor: viewModel.emojiBackground,
      semanticsLabel: [
        viewModel.tag,
        viewModel.title,
        viewModel.date,
        viewModel.hourAndDuration,
        if (viewModel.place != null) viewModel.place!,
      ].join('. '),
      child: _EventBody(viewModel, showInscriptionTags: true, showDate: showDate),
    );
  }
}

class _EmbeddedContent extends StatelessWidget {
  final RendezvousCardViewModel viewModel;
  final bool showDate;

  const _EmbeddedContent(this.viewModel, {required this.showDate});

  @override
  Widget build(BuildContext context) {
    return _EventBody(viewModel, showInscriptionTags: false, showDate: showDate);
  }
}

class _EventBody extends StatelessWidget {
  final RendezvousCardViewModel viewModel;
  final bool showInscriptionTags;
  final bool showDate;

  const _EventBody(this.viewModel, {required this.showInscriptionTags, required this.showDate});

  @override
  Widget build(BuildContext context) {
    final inscriptionTags = showInscriptionTags ? _inscriptionTags(viewModel.inscriptionStatus) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: DsfrSpacings.s1w,
          runSpacing: DsfrSpacings.s1w,
          children: [
            DsfrCategoryTag.evenement(
              label: viewModel.tag,
              typeCode: viewModel.typeCode,
            ),
            if (viewModel.isAnnule) DsfrStatusBadge.canceled(),
            if (inscriptionTags != null && inscriptionTags.isNotEmpty) ...[...inscriptionTags],
          ],
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        Text(
          viewModel.title,
          style: DsfrTextStyle.bodyMdBold(
            color: DsfrColorDecisions.textTitleGrey(context),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s1v),
        if (showDate) ...[
          DsfrEventCardComplement(
            icon: DsfrIcons.businessCalendarEventLine,
            text: viewModel.date,
          ),
          const SizedBox(height: DsfrSpacings.s1v),
        ],
        DsfrEventCardComplement(
          icon: DsfrIcons.systemTimeLine,
          text: viewModel.hourAndDuration,
          semanticsLabel: viewModel.hourAndDuration.toTimeAndDurationForScreenReaders(),
        ),
        if (viewModel.place != null) ...[
          const SizedBox(height: DsfrSpacings.s1v),
          DsfrEventCardComplement(
            icon: DsfrIcons.mapMapPin2Line,
            text: viewModel.place!,
          ),
        ],
        if (viewModel.nombreDePlacesRestantes != null) ...[
          const SizedBox(height: DsfrSpacings.s1v),
          DsfrEventCardComplement(
            icon: DsfrIcons.userGroupLine,
            text: viewModel.nombreDePlacesRestantes!,
          ),
        ],
      ],
    );
  }

  List<Widget> _inscriptionTags(InscriptionStatus inscriptionStatus) => switch (inscriptionStatus) {
    InscriptionStatus.inscrit => [
      DsfrCategoryTag.success(
        label: Strings.eventVousEtesDejaInscrit,
        icon: DsfrIcons.systemCheckboxCircleFill,
      ),
    ],
    InscriptionStatus.autodesinscription => [
      DsfrCategoryTag.secondary(label: Strings.eventAnnulerMonInscription),
    ],
    InscriptionStatus.notInscrit => [
      DsfrCategoryTag.secondary(
        label: Strings.eventInscrivezVousPourParticiper,
      ),
    ],
    InscriptionStatus.autoinscription => [
      DsfrCategoryTag.secondary(label: Strings.eventAutoInscription),
    ],
    InscriptionStatus.full => [
      DsfrStatusBadge.complet(),
    ],
    InscriptionStatus.hidden => [],
  };
}

extension RendezvousCardFromId on String {
  Widget rendezvousCard({
    required BuildContext context,
    required RendezvousStateSource stateSource,
    required EvenementEngagement evenementEngagement,
    bool withChrome = true,
    bool showDate = false,
  }) {
    return RendezvousCard(
      converter: (store) => RendezvousCardViewModel.create(store, stateSource, this),
      withChrome: withChrome,
      showDate: showDate,
      onTap: () {
        context.trackEvenementEngagement(evenementEngagement);
        RendezvousDetailsPage.show(context, _stateSource(stateSource), this);
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
    RendezvousStateSource.sessionMiloDetails => RendezvousStateSource.sessionMiloDetails,
    RendezvousStateSource.noSource ||
    RendezvousStateSource.accueilProchainRendezvous ||
    RendezvousStateSource.monSuivi ||
    RendezvousStateSource.eventListAnimationsCollectives ||
    RendezvousStateSource.accueilLesEvenements => stateSource,
  };
}
