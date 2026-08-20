import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/date_consultation_offre/date_consultation_offre_actions.dart';
import 'package:pass_emploi_app/features/service_civique/detail/service_civique_detail_actions.dart';
import 'package:pass_emploi_app/models/service_civique.dart';
import 'package:pass_emploi_app/models/service_civique/domain.dart';
import 'package:pass_emploi_app/models/service_civique/service_civique_detail.dart';
import 'package:pass_emploi_app/network/post_evenement_engagement.dart';
import 'package:pass_emploi_app/pages/offre_not_found_page.dart';
import 'package:pass_emploi_app/pages/offre_page.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/service_civique/service_civique_detail_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/context_extensions.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/bottom_sheets.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/postuler_offre_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/buttons/delete_favori_button.dart';
import 'package:pass_emploi_app/widgets/buttons/share_button.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/errors/favori_not_found_error.dart';
import 'package:pass_emploi_app/widgets/favori_heart.dart';
import 'package:pass_emploi_app/widgets/favori_state_selector.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_actions_footer.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_header.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_section_title.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_tag.dart';

class ServiceCiviqueDetailPage extends StatelessWidget {
  final String idOffre;
  final bool popPageWhenFavoriIsRemoved;

  ServiceCiviqueDetailPage(this.idOffre, [this.popPageWhenFavoriIsRemoved = false]);

  static MaterialPageRoute<void> materialPageRoute(String idOffre, [bool popPageWhenFavoriIsRemoved = false]) {
    return MaterialPageRoute(builder: (context) => ServiceCiviqueDetailPage(idOffre, popPageWhenFavoriIsRemoved));
  }

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.serviceCiviqueDetail,
      child: StoreConnector<AppState, ServiceCiviqueDetailViewModel>(
        onInit: (store) => store.dispatch(GetServiceCiviqueDetailAction(idOffre)),
        onInitialBuild: (_) {
          context.trackEvenementEngagement(EvenementEngagement.OFFRE_SERVICE_CIVIQUE_AFFICHEE);
        },
        converter: (store) => ServiceCiviqueDetailViewModel.create(store),
        builder: (context, viewModel) {
          return FavorisStateContext(
            child: viewModel.isNotFound
                ? OffreNotFoundPage()
                : _scaffold(_body(context, viewModel), context, viewModel.detail?.lienAnnonce, viewModel.detail?.titre),
            selectState: (store) => store.state.serviceCiviqueFavorisIdsState,
          );
        },
        onDispose: (store) {
          store.dispatch(DateConsultationWriteOffreAction(idOffre));
        },
      ),
    );
  }

  Scaffold _scaffold(Widget body, BuildContext context, String? url, String? title) {
    return Scaffold(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      appBar: BackAppBar(
        actions: [
          FavoriHeart<ServiceCivique>(
            offreId: idOffre,
            withBorder: false,
            from: OffrePage.serviceCiviqueDetails,
            onFavoriRemoved: popPageWhenFavoriIsRemoved ? () => Navigator.pop(context) : null,
            icon: DsfrIcons.systemStarLine,
            iconActive: DsfrIcons.systemStarFill,
            iconColor: DsfrColorDecisions.textActionHighBlueFrance(context),
          ),
          if (url != null)
            ShareButton(
              textToShare: url,
              semanticsLabel: Strings.a11yPartagerOffreLabel,
              subjectForEmail: title,
              onPressed: () => _shareOffer(context),
            ),
        ],
      ),
      body: body,
    );
  }

  Widget _body(BuildContext context, ServiceCiviqueDetailViewModel viewModel) {
    return switch (viewModel.displayState) {
      DisplayState.EMPTY => _content(context, viewModel),
      DisplayState.CONTENT => _content(context, viewModel),
      DisplayState.LOADING => Center(
          child: CircularProgressIndicator(color: DsfrColorDecisions.backgroundActionHighBlueFrance(context)),
        ),
      DisplayState.FAILURE => Center(
          child: Text(
            Strings.offreDetailsError,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
          ),
        ),
    };
  }

  Widget _content(BuildContext context, ServiceCiviqueDetailViewModel viewModel) {
    final ServiceCiviqueDetail? detail = viewModel.detail;
    final ServiceCivique? serviceCivique = viewModel.serviceCivique;
    final String organisation = detail?.organisation ?? serviceCivique?.companyName ?? "";
    final String titre = detail?.titre ?? serviceCivique?.title ?? "";
    final String domaine =
        Domaine.fromTag(detail?.domaine)?.titre ?? Domaine.fromTag(serviceCivique?.domain)?.titre ?? "";
    final isEmpty = viewModel.displayState == DisplayState.EMPTY;

    final footerActions = <OffreDetailsAction>[];
    if (detail?.lienAnnonce != null) {
      footerActions.add(
        OffreDetailsAction(
          label: Strings.postulerButtonTitle,
          icon: viewModel.shouldShowCvBottomSheet ? null : DsfrIcons.systemExternalLinkLine,
          semanticsLink: true,
          onPressed: () {
            final url = detail!.lienAnnonce!;
            if (viewModel.shouldShowCvBottomSheet) {
              showPassEmploiBottomSheet(
                context: context,
                builder: (context) => PostulerOffreBottomSheet(onPostuler: () => _applyToOffer(context, url)),
              );
            } else {
              _applyToOffer(context, url);
            }
          },
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(DsfrSpacings.s2w, DsfrSpacings.s2w, DsfrSpacings.s2w, DsfrSpacings.s3w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageTitle(Strings.serviceCiviqueDetailTitle),
                const SizedBox(height: DsfrSpacings.s1w),
                if (isEmpty) ...[
                  FavoriNotFoundError(),
                  const SizedBox(height: DsfrSpacings.s2w),
                ],
                OffreDetailsHeader(
                  dateLabel: viewModel.dateDerniereConsultation != null
                      ? Strings.offreLastSeen(viewModel.dateDerniereConsultation!)
                      : null,
                  leading: domaine.isNotEmpty
                      ? Text(
                          domaine,
                          style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context)),
                        )
                      : null,
                  title: titre,
                  subtitle: organisation.isNotEmpty ? organisation : null,
                  tags: detail != null ? _tags(detail) : const [],
                ),
                if (detail != null) ...[
                  const SizedBox(height: DsfrSpacings.s2w),
                  _description(context, detail),
                  _organisation(context, detail),
                ],
              ],
            ),
          ),
        ),
        if (footerActions.isNotEmpty)
          OffreDetailsActionsFooter(actions: footerActions)
        else if (isEmpty)
          _incompleteDataFooter(),
      ],
    );
  }

  List<OffreDetailsTag> _tags(ServiceCiviqueDetail detail) {
    return [
      OffreDetailsTag.location(
        detail.codeDepartement != null ? "${detail.codeDepartement} - ${detail.ville}" : detail.ville,
      ),
      OffreDetailsTag(
        label: "Commence le ${detail.dateDeDebut}",
        icon: DsfrIcons.businessCalendarLine,
        iconSemanticLabel: Strings.iconAlternativeDateDeDebut,
      ),
      if (detail.dateDeFin != null)
        OffreDetailsTag(
          label: "Termine le ${detail.dateDeFin}",
          icon: DsfrIcons.businessCalendarLine,
          iconSemanticLabel: Strings.iconAlternativeDateDeFin,
        ),
    ];
  }

  Widget _description(BuildContext context, ServiceCiviqueDetail detail) {
    final String missionFullAdresse = detail.adresseMission != null && detail.codePostal != null
        ? "${detail.adresseMission!}, ${detail.codePostal!} ${detail.ville}"
        : detail.ville;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OffreDetailsSectionTitle(Strings.serviceCiviqueMissionTitle),
        const SizedBox(height: DsfrSpacings.s2w),
        Text(
          missionFullAdresse,
          style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
        ),
        if (detail.description != null) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          Text(
            detail.description!,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
          ),
        ],
        const SizedBox(height: DsfrSpacings.s2w),
      ],
    );
  }

  Widget _organisation(BuildContext context, ServiceCiviqueDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OffreDetailsSectionTitle(Strings.serviceCiviqueOrganisationTitle),
        const SizedBox(height: DsfrSpacings.s2w),
        Text(
          detail.organisation,
          style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        if (detail.urlOrganisation != null) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          DsfrLink(
            label: detail.urlOrganisation!,
            icon: DsfrIcons.systemExternalLinkLine,
            onTap: () => launchExternalUrl(detail.urlOrganisation!),
          ),
        ],
        if (detail.adresseOrganisation != null) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          Text(
            detail.adresseOrganisation!,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
          ),
        ],
        if (detail.descriptionOrganisation != null) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          Text(
            detail.descriptionOrganisation!,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
          ),
        ],
      ],
    );
  }

  void _applyToOffer(BuildContext context, String url) {
    launchExternalUrl(url);
    context.trackEvenementEngagement(_postulerEvent());
  }

  void _shareOffer(BuildContext context) => context.trackEvenementEngagement(_partagerEvent());

  EvenementEngagement _partagerEvent() => EvenementEngagement.OFFRE_SERVICE_CIVIQUE_PARTAGEE;

  EvenementEngagement _postulerEvent() => EvenementEngagement.OFFRE_SERVICE_CIVIQUE_POSTULEE;

  Widget _incompleteDataFooter() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        child: SizedBox(
          width: double.infinity,
          child: DeleteFavoriButton<ServiceCivique>(offreId: idOffre, from: OffrePage.serviceCiviqueDetails),
        ),
      ),
    );
  }
}
