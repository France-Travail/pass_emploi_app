import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/date_consultation_offre/date_consultation_offre_actions.dart';
import 'package:pass_emploi_app/features/immersion/details/immersion_details_actions.dart';
import 'package:pass_emploi_app/models/immersion.dart';
import 'package:pass_emploi_app/models/immersion_details.dart';
import 'package:pass_emploi_app/network/post_evenement_engagement.dart';
import 'package:pass_emploi_app/pages/immersion/immersion_contact_form_page.dart';
import 'package:pass_emploi_app/pages/immersion/immersion_contact_mode.dart';
import 'package:pass_emploi_app/pages/offre_not_found_page.dart';
import 'package:pass_emploi_app/pages/offre_page.dart';
import 'package:pass_emploi_app/presentation/immersion/immersion_details_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/context_extensions.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/utils/platform.dart';
import 'package:pass_emploi_app/widgets/buttons/delete_favori_button.dart';
import 'package:pass_emploi_app/widgets/cards/base_cards/widgets/card_tag.dart';
import 'package:pass_emploi_app/widgets/default_animated_switcher.dart';
import 'package:pass_emploi_app/widgets/errors/favori_not_found_error.dart';
import 'package:pass_emploi_app/widgets/favori_heart.dart';
import 'package:pass_emploi_app/widgets/favori_state_selector.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_actions_footer.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_app_bar.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_header.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_section_title.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_tag.dart';
import 'package:pass_emploi_app/widgets/retry.dart';

class ImmersionDetailsPage extends StatelessWidget {
  final String _immersionId;
  final bool popPageWhenFavoriIsRemoved;

  ImmersionDetailsPage._(this._immersionId, {this.popPageWhenFavoriIsRemoved = false});

  static MaterialPageRoute<void> materialPageRoute(String id, {bool popPageWhenFavoriIsRemoved = false}) {
    return MaterialPageRoute(
      builder: (context) => ImmersionDetailsPage._(id, popPageWhenFavoriIsRemoved: popPageWhenFavoriIsRemoved),
    );
  }

  @override
  Widget build(BuildContext context) {
    final platform = PlatformUtils.getPlatform;
    return Tracker(
      tracking: AnalyticsScreenNames.immersionDetails,
      child: StoreConnector<AppState, ImmersionDetailsViewModel>(
        onInit: (store) => store.dispatch(ImmersionDetailsRequestAction(_immersionId)),
        onInitialBuild: (_) {
          context.trackEvenementEngagement(EvenementEngagement.OFFRE_IMMERSION_AFFICHEE);
        },
        onDispose: (store) {
          store.dispatch(DateConsultationWriteOffreAction(_immersionId));
        },
        converter: (store) => ImmersionDetailsViewModel.create(store, platform),
        builder: (context, viewModel) => FavorisStateContext(
          selectState: (store) => store.state.immersionFavorisIdsState,
          child: _scaffold(_body(context, viewModel), context, viewModel.id),
        ),
        distinct: true,
      ),
    );
  }

  Widget _body(BuildContext context, ImmersionDetailsViewModel viewModel) {
    return switch (viewModel.displayState) {
      ImmersionDetailsPageDisplayState.SHOW_DETAILS =>
        viewModel.isNotFound ? OffreNotFoundPage() : _content(context, viewModel),
      ImmersionDetailsPageDisplayState.SHOW_INCOMPLETE_DETAILS => _content(context, viewModel),
      ImmersionDetailsPageDisplayState.SHOW_LOADER => Center(
          child: CircularProgressIndicator(color: DsfrColorDecisions.backgroundActionHighBlueFrance(context)),
        ),
      ImmersionDetailsPageDisplayState.SHOW_ERROR => Retry(
        Strings.offreDetailsError,
        () => viewModel.onRetry(_immersionId),
      ),
    };
  }

  Scaffold _scaffold(Widget body, BuildContext context, String offreId) {
    return Scaffold(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      appBar: OffreDetailsAppBar(
        actions: [
          FavoriHeart<Immersion>(
            offreId: offreId,
            withBorder: false,
            from: OffrePage.immersionDetails,
            onFavoriRemoved: popPageWhenFavoriIsRemoved ? () => Navigator.pop(context) : null,
            icon: DsfrIcons.systemStarLine,
            iconActive: DsfrIcons.systemStarFill,
            iconColor: DsfrColorDecisions.textActionHighBlueFrance(context),
          ),
        ],
      ),
      body: DefaultAnimatedSwitcher(child: body),
    );
  }

  Widget _content(BuildContext context, ImmersionDetailsViewModel viewModel) {
    final showIncomplete = viewModel.displayState == ImmersionDetailsPageDisplayState.SHOW_INCOMPLETE_DETAILS;
    final footerActions = <OffreDetailsAction>[];

    if (!showIncomplete) {
      footerActions.add(
        OffreDetailsAction(
          label: Strings.immersitionContactFormTitle,
          onPressed: () => Navigator.push(context, ImmersionContactFormPage.materialPageRoute()),
        ),
      );
      if (viewModel.withSecondaryCallToActions == true) {
        for (final cta in viewModel.secondaryCallToActions!) {
          footerActions.add(
            OffreDetailsAction(
              label: cta.label,
              icon: cta.icon,
              variant: DsfrButtonVariant.secondary,
              semanticsLink: true,
              onPressed: () {
                context.trackEvenementEngagement(cta.eventType);
                launchExternalUrl(cta.uri.toString());
              },
            ),
          );
        }
      }
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(DsfrSpacings.s2w, DsfrSpacings.s2w, DsfrSpacings.s2w, DsfrSpacings.s3w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OffreDetailsPageTitle(Strings.offreDetails),
                const SizedBox(height: DsfrSpacings.s1w),
                if (viewModel.fitForDisabledWorkers) ...[
                  CardTag.disabledWorkersWelcome(),
                  const SizedBox(height: DsfrSpacings.s2w),
                ],
                OffreDetailsHeader(
                  dateLabel: viewModel.dateDerniereConsultation != null
                      ? Strings.offreLastSeen(viewModel.dateDerniereConsultation!)
                      : null,
                  title: viewModel.title,
                  subtitle: viewModel.companyName,
                  tags: _tags(viewModel),
                ),
                const SizedBox(height: DsfrSpacings.s2w),
                OffreDetailsSectionTitle(Strings.lentreprise),
                const SizedBox(height: DsfrSpacings.s2w),
                ContactModeTag(contactMode: viewModel.contactMode),
                const SizedBox(height: DsfrSpacings.s2w),
                if (showIncomplete)
                  FavoriNotFoundError()
                else ...[
                  Text(
                    Strings.immersionDescriptionLabel,
                    style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                  ),
                  const SizedBox(height: DsfrSpacings.s2w),
                  if (viewModel.address != null && viewModel.address!.isNotEmpty) ...[
                    OffreDetailsSectionTitle(Strings.adresse, size: OffreDetailsSectionTitleSize.headline6),
                    const SizedBox(height: DsfrSpacings.s1w),
                    Text(
                      viewModel.address!,
                      style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                    ),
                    const SizedBox(height: DsfrSpacings.s2w),
                  ],
                  if (viewModel.informationComplementaire != null &&
                      viewModel.informationComplementaire!.isNotEmpty) ...[
                    OffreDetailsSectionTitle(
                      Strings.informationComplementaire,
                      size: OffreDetailsSectionTitleSize.headline6,
                    ),
                    const SizedBox(height: DsfrSpacings.s1w),
                    Text(
                      viewModel.informationComplementaire!,
                      style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                    ),
                    const SizedBox(height: DsfrSpacings.s2w),
                  ],
                  if (viewModel.website != null && viewModel.website!.isNotEmpty) ...[
                    OffreDetailsSectionTitle(Strings.siteWeb, size: OffreDetailsSectionTitleSize.headline6),
                    const SizedBox(height: DsfrSpacings.s1w),
                    DsfrLink(
                      label: viewModel.website!,
                      icon: DsfrIcons.systemExternalLinkLine,
                      onTap: () => launchExternalUrl(viewModel.website!),
                    ),
                    const SizedBox(height: DsfrSpacings.s2w),
                  ],
                  DsfrAlert(
                    type: DsfrAlertType.info,
                    description: DsfrAlertDescriptionText(Strings.contactWarning),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (footerActions.isNotEmpty)
          OffreDetailsActionsFooter(actions: footerActions)
        else if (showIncomplete)
          _incompleteDataFooter(viewModel),
      ],
    );
  }

  List<OffreDetailsTag> _tags(ImmersionDetailsViewModel viewModel) {
    return [
      OffreDetailsTag.location(viewModel.ville),
      OffreDetailsTag(label: viewModel.secteurActivite),
      if (viewModel.modeDistanciel != null)
        OffreDetailsTag(label: _modeDistancielLabel(viewModel.modeDistanciel!)),
    ];
  }

  String _modeDistancielLabel(ImmersionModeDistanciel mode) {
    return switch (mode) {
      ImmersionModeDistanciel.FULL_REMOTE => Strings.modeDistancielFullRemote,
      ImmersionModeDistanciel.HYBRID => Strings.modeDistancielHybrid,
      ImmersionModeDistanciel.ON_SITE => Strings.modeDistancielOnSite,
    };
  }

  Widget _incompleteDataFooter(ImmersionDetailsViewModel viewModel) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        child: SizedBox(
          width: double.infinity,
          child: DeleteFavoriButton<Immersion>(offreId: viewModel.id, from: OffrePage.immersionDetails),
        ),
      ),
    );
  }
}
