import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/date_consultation_offre/date_consultation_offre_actions.dart';
import 'package:pass_emploi_app/features/favori/update/favori_update_actions.dart';
import 'package:pass_emploi_app/features/offre_emploi/details/offre_emploi_details_actions.dart';
import 'package:pass_emploi_app/models/chat/message.dart';
import 'package:pass_emploi_app/models/offre_emploi.dart';
import 'package:pass_emploi_app/models/offre_emploi_details.dart';
import 'package:pass_emploi_app/network/post_evenement_engagement.dart';
import 'package:pass_emploi_app/pages/chat/chat_partage_bottom_sheet.dart';
import 'package:pass_emploi_app/pages/offre_not_found_page.dart';
import 'package:pass_emploi_app/pages/offre_page.dart';
import 'package:pass_emploi_app/presentation/chat/chat_partage_bottom_sheet_view_model.dart';
import 'package:pass_emploi_app/presentation/offre_emploi/offre_emploi_details_page_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/context_extensions.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/bottom_sheets.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/offre_suivie_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/postuler_offre_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/buttons/delete_favori_button.dart';
import 'package:pass_emploi_app/widgets/buttons/share_button.dart';
import 'package:pass_emploi_app/widgets/errors/favori_not_found_error.dart';
import 'package:pass_emploi_app/widgets/favori_heart.dart';
import 'package:pass_emploi_app/widgets/favori_state_selector.dart';
import 'package:pass_emploi_app/widgets/help_tooltip.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_actions_footer.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_app_bar.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_header.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_section_title.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_tag.dart';
import 'package:pass_emploi_app/widgets/offre_emploi_origin.dart';
import 'package:pass_emploi_app/widgets/offre_suivie_form.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';

class OffreEmploiDetailsPage extends StatelessWidget {
  final String _offreId;
  final bool _fromAlternance;
  final bool popPageWhenFavoriIsRemoved;

  OffreEmploiDetailsPage._(this._offreId, this._fromAlternance, {this.popPageWhenFavoriIsRemoved = false});

  static MaterialPageRoute<void> materialPageRoute(
    String id, {
    required bool fromAlternance,
    bool popPageWhenFavoriIsRemoved = false,
  }) {
    return MaterialPageRoute(
      builder: (context) {
        return OffreEmploiDetailsPage._(id, fromAlternance, popPageWhenFavoriIsRemoved: popPageWhenFavoriIsRemoved);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: _fromAlternance ? AnalyticsScreenNames.alternanceDetails : AnalyticsScreenNames.emploiDetails,
      child: StoreConnector<AppState, OffreEmploiDetailsPageViewModel>(
        onInit: (store) => store.dispatch(OffreEmploiDetailsRequestAction(_offreId)),
        onInitialBuild: (_) {
          context.trackEvenementEngagement(_offreAfficheeEvent());
        },
        converter: (store) => OffreEmploiDetailsPageViewModel.create(store),
        builder: (context, viewModel) => FavorisStateContext<OffreEmploi>(
          selectState: (store) => store.state.offreEmploiFavorisIdsState,
          child: viewModel.isNotFound
              ? OffreNotFoundPage()
              : _scaffold(
                  _body(context, viewModel),
                  context,
                  viewModel.urlRedirectPourPostulation,
                  viewModel.id,
                  viewModel.title,
                ),
        ),
        onDispose: (store) {
          store.dispatch(DateConsultationWriteOffreAction(_offreId));
          store.dispatch(FavoriUpdateConfirmationResetAction());
        },
        distinct: true,
      ),
    );
  }

  Widget _body(BuildContext context, OffreEmploiDetailsPageViewModel viewModel) {
    return switch (viewModel.displayState) {
      OffreEmploiDetailsPageDisplayState.SHOW_DETAILS => _content(context, viewModel),
      OffreEmploiDetailsPageDisplayState.SHOW_INCOMPLETE_DETAILS => _content(context, viewModel),
      OffreEmploiDetailsPageDisplayState.SHOW_LOADER => _loading(context),
      OffreEmploiDetailsPageDisplayState.SHOW_ERROR => _error(context),
    };
  }

  Widget _scaffold(Widget body, BuildContext context, String? url, String? offreId, String? title) {
    return Scaffold(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      appBar: OffreDetailsAppBar(
        actions: [
          if (offreId != null)
            FavoriHeart<OffreEmploi>(
              offreId: offreId,
              withBorder: false,
              from: _fromAlternance ? OffrePage.alternanceDetails : OffrePage.emploiDetails,
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

  Widget _loading(BuildContext context) => Center(
        child: CircularProgressIndicator(color: DsfrColorDecisions.backgroundActionHighBlueFrance(context)),
      );

  Widget _error(BuildContext context) => Center(
        child: Text(
          Strings.offreDetailsError,
          style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
        ),
      );

  Widget _content(BuildContext context, OffreEmploiDetailsPageViewModel viewModel) {
    final id = viewModel.id;
    final url = viewModel.urlRedirectPourPostulation;
    final showIncomplete = viewModel.displayState == OffreEmploiDetailsPageDisplayState.SHOW_INCOMPLETE_DETAILS;
    final showDetails = viewModel.displayState == OffreEmploiDetailsPageDisplayState.SHOW_DETAILS;
    final footerActions = <OffreDetailsAction>[];

    if (url != null && id != null && showDetails) {
      footerActions.add(
        OffreDetailsAction(
          label: Strings.postulerButtonTitle,
          icon: viewModel.shouldShowCvBottomSheet ? null : DsfrIcons.systemExternalLinkLine,
          semanticsLink: true,
          onPressed: () => _onPostulerPressed(context, viewModel),
        ),
      );
    }
    if (id != null && showDetails) {
      footerActions.add(
        OffreDetailsAction(
          label: Strings.partagerOffreConseiller,
          icon: DsfrIcons.systemShareLine,
          variant: DsfrButtonVariant.secondary,
          onPressed: () => ChatPartageBottomSheet.show(
            context,
            ChatPartageOffreEmploiSource(_fromAlternance ? OffreType.alternance : OffreType.emploi),
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              DsfrSpacings.s2w,
              DsfrSpacings.s2w,
              DsfrSpacings.s2w,
              footerActions.isNotEmpty || (showIncomplete && id != null) ? DsfrSpacings.s3w : DsfrSpacings.s2w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OffreDetailsPageTitle(Strings.offreDetails),
                const SizedBox(height: DsfrSpacings.s1w),
                _header(context, viewModel),
                const SizedBox(height: DsfrSpacings.s2w),
                if (viewModel.shouldShowOffreSuiviForm) ...[
                  OffreSuivieForm(
                    offreId: id!,
                    showOffreDetails: false,
                    trackingSource: OffreSuiviTrackingSource.offreDetail,
                    showPrimaryBackground: true,
                  ),
                  const SizedBox(height: DsfrSpacings.s2w),
                ],
                if (showDetails) ...[
                  _description(context, viewModel),
                  _profileDescription(context, viewModel),
                  if (viewModel.companyName != null) _companyDescription(context, viewModel),
                ],
                if (showIncomplete) FavoriNotFoundError(),
              ],
            ),
          ),
        ),
        if (footerActions.isNotEmpty)
          OffreDetailsActionsFooter(actions: footerActions)
        else if (showIncomplete && id != null)
          _incompleteDataFooter(context, id),
      ],
    );
  }

  Widget _header(BuildContext context, OffreEmploiDetailsPageViewModel viewModel) {
    final title = viewModel.title ?? '';
    final id = viewModel.id;
    final lastUpdate = viewModel.lastUpdate;
    String? dateLabel;
    if (viewModel.datePostulation != null) {
      dateLabel = Strings.offrePostulatedSeen(viewModel.datePostulation!);
    } else if (viewModel.dateDerniereConsultation != null) {
      dateLabel = Strings.offreLastSeen(viewModel.dateDerniereConsultation!);
    }

    String? metaLabel;
    if (id != null && lastUpdate != null) {
      metaLabel = Strings.offreNumberAndLastUpdate(id, lastUpdate);
    } else if (id != null) {
      metaLabel = Strings.offreDetailNumber(id);
    } else if (lastUpdate != null) {
      metaLabel = Strings.offreDetailLastUpdate(lastUpdate);
    }

    return OffreDetailsHeader(
      dateLabel: dateLabel,
      leading: viewModel.originViewModel?.toWidget(OffreEmploiOriginSize.medium),
      title: title,
      subtitle: viewModel.companyName,
      tags: _tags(viewModel),
      metaLabel: metaLabel,
    );
  }

  List<OffreDetailsTag> _tags(OffreEmploiDetailsPageViewModel viewModel) {
    return [
      if (viewModel.location != null) OffreDetailsTag.location(viewModel.location!),
      if (viewModel.contractType != null) OffreDetailsTag.contractType(viewModel.contractType!),
      if (viewModel.salary != null) OffreDetailsTag.salary(viewModel.salary!),
      if (viewModel.duration != null) OffreDetailsTag.duration(viewModel.duration!),
    ];
  }

  Widget _description(BuildContext context, OffreEmploiDetailsPageViewModel viewModel) {
    final description = viewModel.description;
    if (description == null) return const SizedBox.shrink();

    final paragraphs = description.split("\n").where((paragraph) => paragraph.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OffreDetailsSectionTitle(Strings.offreDetailsTitle),
        const SizedBox(height: DsfrSpacings.s2w),
        ...paragraphs.map(
          (paragraph) => Padding(
            padding: const EdgeInsets.only(bottom: DsfrSpacings.s1w),
            child: Text(
              paragraph,
              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
            ),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
      ],
    );
  }

  Widget _profileDescription(BuildContext context, OffreEmploiDetailsPageViewModel viewModel) {
    final experience = viewModel.experience;
    final Widget? skills = _skillsBlock(context: context, skills: viewModel.skills);
    final Widget? softSkills = _softSkillsBlock(context: context, softSkills: viewModel.softSkills);
    final Widget? educations = _educationsBlock(context: context, educations: viewModel.educations);
    final Widget? languages = _languagesBlock(context: context, languages: viewModel.languages);
    final Widget? driverLicences = _driverLicencesBlock(context: context, driverLicences: viewModel.driverLicences);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OffreDetailsSectionTitle(Strings.profileTitle),
        const SizedBox(height: DsfrSpacings.s2w),
        OffreDetailsSectionTitle(Strings.experienceTitle, size: OffreDetailsSectionTitleSize.headline6),
        const SizedBox(height: DsfrSpacings.s1w),
        if (experience != null)
          _setRequiredElement(context: context, element: experience, criteria: viewModel.requiredExperience),
        const SizedBox(height: DsfrSpacings.s2w),
        if (skills != null) skills,
        if (softSkills != null) softSkills,
        if (educations != null) educations,
        if (languages != null) languages,
        if (driverLicences != null) driverLicences,
      ],
    );
  }

  Widget _companyDescription(BuildContext context, OffreEmploiDetailsPageViewModel viewModel) {
    final companyName = viewModel.companyName;
    final companyDescription = viewModel.companyDescription;
    final companyAdapted = viewModel.companyAdapted ?? false;
    final companyAccessibility = viewModel.companyAccessibility ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OffreDetailsSectionTitle(Strings.companyTitle, size: OffreDetailsSectionTitleSize.headline6),
        const SizedBox(height: DsfrSpacings.s2w),
        if (companyName != null) _companyName(context: context, companyName: companyName, companyUrl: viewModel.companyUrl),
        if (companyAdapted) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          OffreDetailsTag(label: Strings.companyAdaptedTitle),
        ],
        if (companyAccessibility) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          OffreDetailsTag(label: Strings.companyAccessibilityTitle),
        ],
        if (companyDescription != null) ...[
          const SizedBox(height: DsfrSpacings.s2w),
          Text(
            companyDescription,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
          ),
        ],
        const SizedBox(height: DsfrSpacings.s2w),
      ],
    );
  }

  Widget? _skillsBlock({required BuildContext context, required List<Skill>? skills}) {
    if (skills == null || skills.isEmpty) return null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OffreDetailsSectionTitle(Strings.skillsTitle, size: OffreDetailsSectionTitleSize.headline5),
        const SizedBox(height: DsfrSpacings.s1w),
        for (final skill in skills)
          _setRequiredElement(context: context, element: skill.description, criteria: skill.requirement),
        const SizedBox(height: DsfrSpacings.s2w),
      ],
    );
  }

  Widget? _softSkillsBlock({required BuildContext context, required List<String>? softSkills}) {
    if (softSkills == null || softSkills.isEmpty) return null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OffreDetailsSectionTitle(Strings.softSkillsTitle, size: OffreDetailsSectionTitleSize.headline6),
        const SizedBox(height: DsfrSpacings.s1w),
        for (final soft in softSkills) _listItem(context: context, text: soft),
        const SizedBox(height: DsfrSpacings.s2w),
      ],
    );
  }

  Widget? _educationsBlock({required BuildContext context, required List<EducationViewModel>? educations}) {
    if (educations == null || educations.isEmpty) return null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OffreDetailsSectionTitle(Strings.educationTitle, size: OffreDetailsSectionTitleSize.headline6),
        const SizedBox(height: DsfrSpacings.s1w),
        for (final education in educations)
          _setRequiredElement(context: context, element: education.label, criteria: education.requirement),
        const SizedBox(height: DsfrSpacings.s2w),
      ],
    );
  }

  Widget? _languagesBlock({required BuildContext context, required List<Language>? languages}) {
    if (languages == null || languages.isEmpty) return null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OffreDetailsSectionTitle(Strings.languageTitle, size: OffreDetailsSectionTitleSize.headline6),
        const SizedBox(height: DsfrSpacings.s1w),
        for (final language in languages)
          _setRequiredElement(context: context, element: language.type, criteria: language.requirement),
        const SizedBox(height: DsfrSpacings.s2w),
      ],
    );
  }

  Widget? _driverLicencesBlock({required BuildContext context, required List<DriverLicence>? driverLicences}) {
    if (driverLicences == null || driverLicences.isEmpty) return null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OffreDetailsSectionTitle(Strings.driverLicenceTitle, size: OffreDetailsSectionTitleSize.headline6),
        const SizedBox(height: DsfrSpacings.s1w),
        for (final licence in driverLicences)
          _setRequiredElement(context: context, element: licence.category, criteria: licence.requirement),
        const SizedBox(height: DsfrSpacings.s2w),
      ],
    );
  }

  Widget _setRequiredElement({required BuildContext context, required String element, required String? criteria}) {
    return _require(criteria)
        ? _requiredElement(context: context, requiredText: element)
        : _listItem(context: context, text: element);
  }

  bool _require(String? criteria) => criteria != null && criteria == "E";

  Widget _listItem({required BuildContext context, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DsfrSpacings.s1w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context)),
          ),
          const SizedBox(width: DsfrSpacings.s1w),
          Expanded(
            child: Text(
              text,
              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _requiredElement({required BuildContext context, required String requiredText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DsfrSpacings.s1w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context)),
          ),
          const SizedBox(width: DsfrSpacings.s1w),
          Expanded(
            child: Text(
              requiredText,
              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
          ),
          HelpTooltip(message: Strings.requiredIcon, icon: AppIcons.error_rounded),
        ],
      ),
    );
  }

  Widget _companyName({required BuildContext context, required String companyName, required String? companyUrl}) {
    if (companyUrl == null || companyUrl.isEmpty) {
      return Text(
        companyName,
        style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
      );
    }
    return DsfrLink(
      label: companyName,
      icon: DsfrIcons.systemExternalLinkLine,
      onTap: () => launchExternalUrl(companyUrl),
    );
  }

  void _onPostulerPressed(BuildContext context, OffreEmploiDetailsPageViewModel viewModel) {
    final url = viewModel.urlRedirectPourPostulation;
    assert(url != null);
    final shouldShowCvBottomSheet = viewModel.shouldShowCvBottomSheet;
    final shouldShowOffreSuiviBottomSheet = viewModel.shouldShowOffreSuivieBottomSheet;
    final onPostuler = viewModel.onPostuler;

    if (shouldShowCvBottomSheet) {
      showPassEmploiBottomSheet(
        context: context,
        builder: (context) => PostulerOffreBottomSheet(
          onPostuler: () => _applyToOffer(context, url!, shouldShowOffreSuiviBottomSheet, onPostuler),
        ),
      );
    } else {
      _applyToOffer(context, url!, shouldShowOffreSuiviBottomSheet, onPostuler);
    }
  }

  Widget _incompleteDataFooter(BuildContext context, String id) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        child: SizedBox(
          width: double.infinity,
          child: DeleteFavoriButton<OffreEmploi>(offreId: id, from: OffrePage.emploiDetails),
        ),
      ),
    );
  }

  void _applyToOffer(
    BuildContext context,
    String url,
    bool shouldShowOffreSuiviBottomSheetOnPostuler,
    void Function() onPostuler,
  ) {
    context.trackEvenementEngagement(_postulerEvent());
    launchExternalUrl(url).then((_) {
      if (context.mounted && shouldShowOffreSuiviBottomSheetOnPostuler) {
        onPostuler();
        OffreSuivieBottomSheet.show(context, _offreId);
      }
    });
  }

  void _shareOffer(BuildContext context) => context.trackEvenementEngagement(_partagerEvent());

  EvenementEngagement _offreAfficheeEvent() {
    return _fromAlternance ? EvenementEngagement.OFFRE_ALTERNANCE_AFFICHEE : EvenementEngagement.OFFRE_EMPLOI_AFFICHEE;
  }

  EvenementEngagement _postulerEvent() =>
      _fromAlternance ? EvenementEngagement.OFFRE_ALTERNANCE_POSTULEE : EvenementEngagement.OFFRE_EMPLOI_POSTULEE;

  EvenementEngagement _partagerEvent() =>
      _fromAlternance ? EvenementEngagement.OFFRE_ALTERNANCE_PARTAGEE : EvenementEngagement.OFFRE_EMPLOI_PARTAGEE;
}
