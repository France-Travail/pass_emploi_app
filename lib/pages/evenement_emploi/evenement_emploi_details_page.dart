import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/evenement_emploi/details/evenement_emploi_details_actions.dart';
import 'package:pass_emploi_app/network/post_evenement_engagement.dart';
import 'package:pass_emploi_app/pages/chat/chat_partage_bottom_sheet.dart';
import 'package:pass_emploi_app/presentation/chat/chat_partage_bottom_sheet_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/evenement_emploi/evenement_emploi_details_page_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/context_extensions.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/widgets/a11y/string_a11y_extensions.dart';
import 'package:pass_emploi_app/widgets/buttons/share_button.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_actions_footer.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_header.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_section_title.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_tag.dart';
import 'package:pass_emploi_app/widgets/retry.dart';

class EvenementEmploiDetailsPage extends StatelessWidget {
  final String eventId;

  EvenementEmploiDetailsPage({required this.eventId});

  static MaterialPageRoute<void> materialPageRoute(String eventId) {
    return MaterialPageRoute(
      builder: (context) {
        return EvenementEmploiDetailsPage(eventId: eventId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.evenementEmploiDetails,
      child: StoreConnector<AppState, EvenementEmploiDetailsPageViewModel>(
        onInit: (store) => store.dispatch(EvenementEmploiDetailsRequestAction(eventId)),
        converter: (store) => EvenementEmploiDetailsPageViewModel.create(store),
        builder: (context, viewModel) {
          return Scaffold(
            backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
            appBar: BackAppBar(
              actions: [
                if (viewModel.url != null)
                  ShareButton(
                    textToShare: viewModel.url!,
                    semanticsLabel: Strings.a11yPartagerEvenementLabel,
                    subjectForEmail: viewModel.titre,
                    onPressed: () => context.trackEvenementEngagement(
                      EvenementEngagement.EVENEMENT_EXTERNE_PARTAGE,
                    ),
                  ),
              ],
            ),
            body: _Body(viewModel: viewModel, eventId: eventId),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final EvenementEmploiDetailsPageViewModel viewModel;
  final String eventId;

  const _Body({required this.viewModel, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return switch (viewModel.displayState) {
      DisplayState.LOADING => Center(
        child: CircularProgressIndicator(
          color: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
        ),
      ),
      DisplayState.CONTENT => _Content(viewModel: viewModel),
      DisplayState.EMPTY || DisplayState.FAILURE => Retry(
        Strings.miscellaneousErrorRetry,
        () => viewModel.retry(eventId),
      ),
    };
  }
}

class _Content extends StatelessWidget {
  final EvenementEmploiDetailsPageViewModel viewModel;

  _Content({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final footerActions = <OffreDetailsAction>[
      if (viewModel.url != null)
        OffreDetailsAction(
          label: Strings.eventEmploiDetailsInscription,
          icon: DsfrIcons.systemExternalLinkLine,
          semanticsLink: true,
          onPressed: () => _openInscriptionUrl(context),
        ),
      OffreDetailsAction(
        label: Strings.eventEmploiDetailsPartagerConseiller,
        icon: DsfrIcons.systemShareLine,
        variant: DsfrButtonVariant.secondary,
        onPressed: () => _partagerConseiller(context),
      ),
    ];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              DsfrSpacings.s2w,
              DsfrSpacings.s2w,
              DsfrSpacings.s2w,
              DsfrSpacings.s3w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageTitle(Strings.eventEmploiDetailsAppBarTitle),
                const SizedBox(height: DsfrSpacings.s1w),
                _Header(viewModel: viewModel),
                if (viewModel.description != null) ...[
                  const SizedBox(height: DsfrSpacings.s2w),
                  _Details(description: viewModel.description!),
                ],
              ],
            ),
          ),
        ),
        OffreDetailsActionsFooter(actions: footerActions),
      ],
    );
  }

  void _partagerConseiller(BuildContext context) {
    context.trackEvenementEngagement(
      EvenementEngagement.EVENEMENT_EXTERNE_PARTAGE_CONSEILLER,
    );
    ChatPartageBottomSheet.show(context, ChatPartageEvenementEmploiSource());
  }

  void _openInscriptionUrl(BuildContext context) {
    if (viewModel.url == null) return;
    context.trackEvenementEngagement(
      EvenementEngagement.EVENEMENT_EXTERNE_INSCRIPTION,
    );
    launchExternalUrl(viewModel.url!);
  }
}

class _Header extends StatelessWidget {
  final EvenementEmploiDetailsPageViewModel viewModel;

  _Header({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final tag = viewModel.tag;
    return OffreDetailsHeader(
      leading: tag != null && tag.isNotEmpty
          ? Semantics(
              label: tag,
              child: ExcludeSemantics(
                child: DsfrBadge(
                  label: tag,
                  type: DsfrBadgeType.information,
                  size: DsfrComponentSize.sm,
                ),
              ),
            )
          : null,
      title: viewModel.titre,
      tags: [
        if (viewModel.date.isNotEmpty) OffreDetailsTag.date(viewModel.date),
        if (viewModel.heure.isNotEmpty)
          OffreDetailsTag.hour(
            viewModel.heure,
            semanticsLabel: '${Strings.iconAlternativeHour} : ${viewModel.heure.toTimeAndDurationForScreenReaders()}',
          ),
        if (viewModel.lieu.isNotEmpty) OffreDetailsTag.location(viewModel.lieu),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  final String description;

  _Details({required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OffreDetailsSectionTitle(Strings.evenementEmploiDetails),
        const SizedBox(height: DsfrSpacings.s2w),
        Text(
          description,
          style: DsfrTextStyle.bodyMd(
            color: DsfrColorDecisions.textDefaultGrey(context),
          ),
        ),
      ],
    );
  }
}
