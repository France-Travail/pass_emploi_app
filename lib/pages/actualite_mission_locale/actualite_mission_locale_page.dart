import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/actualite_mission_locale/actualite_mission_locale_actions.dart';
import 'package:pass_emploi_app/features/date_consultation_actualite_mission_locale/date_consultation_actualite_mission_locale_actions.dart';
import 'package:pass_emploi_app/features/tracking/tracking_evenement_engagement_action.dart';
import 'package:pass_emploi_app/network/post_evenement_engagement.dart';
import 'package:pass_emploi_app/presentation/actualite_mission_locale/actualite_mission_locale_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/widgets/a11y/string_a11y_extensions.dart';
import 'package:pass_emploi_app/widgets/chat/chat_day_section.dart';
import 'package:pass_emploi_app/widgets/connectivity_widgets.dart';
import 'package:pass_emploi_app/widgets/default_animated_switcher.dart';
import 'package:pass_emploi_app/widgets/retry.dart';

class ActualiteMissionLocalePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Tracker(
      tracking: AnalyticsScreenNames.actualiteMissionLocale,
      child: Theme(
        data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
        child: Builder(
          builder: (context) => ColoredBox(
            color: DsfrColorDecisions.backgroundDefaultGrey(context),
            child: ConnectivityContainer(
              child: StoreConnector<AppState, ActualiteMissionLocaleViewModel>(
                onInit: (store) {
                  store.dispatch(ActualiteMissionLocaleRequestAction());
                  store.dispatch(DateConsultationActualiteMissionLocaleWriteAction(DateTime.now()));
                  store.dispatch(TrackingEvenementEngagementAction(EvenementEngagement.ACTUALITE_MILO_CONSULTATION));
                },
                converter: (store) => ActualiteMissionLocaleViewModel.create(store),
                builder: (context, viewModel) => _DisplayState(viewModel: viewModel),
                distinct: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DisplayState extends StatelessWidget {
  const _DisplayState({required this.viewModel});

  final ActualiteMissionLocaleViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return DefaultAnimatedSwitcher(
      child: switch (viewModel.displayState) {
        DisplayState.CONTENT => _Body(viewModel: viewModel),
        DisplayState.LOADING => const _LoadingIndicator(),
        DisplayState.FAILURE => Retry(Strings.actualiteMissionLocaleError, () => viewModel.onRetry()),
        DisplayState.EMPTY => const _Empty(),
      },
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: Strings.loadingAnnouncement,
      liveRegion: true,
      child: Center(
        child: CircularProgressIndicator(
          color: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.viewModel});

  final ActualiteMissionLocaleViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(DsfrSpacings.s2w),
      itemCount: viewModel.actualites.length,
      reverse: true,
      separatorBuilder: (_, __) => const SizedBox(height: DsfrSpacings.s1w),
      itemBuilder: (context, index) => switch (viewModel.actualites[index]) {
        final ActualiteMissionLocaleItemSupprimeViewModel actualite => _ActualiteItemSupprime(actualite),
        final ActualiteMissionLocaleItemViewModel actualite => _ActualiteItem(actualite),
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DsfrSpacings.s2w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: DsfrSpacings.s7w),
            child: Center(
              child: SvgPicture.asset(
                Drawables.illustrationActualitesEmpty,
                width: 212,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
          ),
          Semantics(
            header: true,
            child: Text(
              Strings.actualiteMissionLocaleEmptyTitle,
              style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
          ),
          const SizedBox(height: DsfrSpacings.s1w),
          Text(
            Strings.actualiteMissionLocaleEmptySubtitle,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ],
      ),
    );
  }
}

class _ActualiteItem extends StatelessWidget {
  const _ActualiteItem(this.actualite);

  final ActualiteMissionLocaleItemViewModel actualite;

  @override
  Widget build(BuildContext context) {
    final hasLink = actualite.titreLien != null && actualite.lien != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChatDaySection(dayLabel: actualite.dateCreation),
        const SizedBox(height: DsfrSpacings.s1v),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(right: 77),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: DsfrColorDecisions.backgroundAltGrey(context),
                borderRadius: const BorderRadius.all(Radius.circular(DsfrSpacings.s1v)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DsfrSpacings.s2w,
                  vertical: DsfrSpacings.s3v,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        actualite.titre,
                        style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
                      ),
                    ),
                    const SizedBox(height: DsfrSpacings.s1w),
                    Text(
                      actualite.corps,
                      style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textTitleGrey(context)),
                    ),
                    if (hasLink) ...[
                      const SizedBox(height: DsfrSpacings.s1w),
                      DsfrLink(
                        label: actualite.titreLien!,
                        icon: DsfrIcons.systemExternalLinkLine,
                        size: DsfrComponentSize.sm,
                        onTap: () => _ExternalUrlAlertDialog.show(context, actualite.lien!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s1v),
        Text(
          actualite.heureEtNomConseiller,
          style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context)),
          semanticsLabel: actualite.heureEtNomConseiller.toTimeAndDurationForScreenReaders(),
        ),
      ],
    );
  }
}

class _ExternalUrlAlertDialog extends StatelessWidget {
  const _ExternalUrlAlertDialog({required this.url});

  final String url;

  static void show(BuildContext context, String url) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: DsfrColorDecisions.backgroundTransparent(context),
      barrierColor: DsfrColorDecisions.backgroundOverlayGrey(context),
      barrierLabel: Strings.bottomSheetBarrierLabel,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Theme(
        data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
        child: DsfrModal(
          isDismissible: true,
          closeLabel: Strings.close,
          child: _ExternalUrlAlertDialog(url: url),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            Strings.externalUrlAlertTitle,
            style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s4w),
        DsfrButton(
          label: Strings.confirmLabel,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: () {
            Navigator.pop(context);
            launchExternalUrl(url);
          },
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrButton(
          label: Strings.cancelLabel,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.lg,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _ActualiteItemSupprime extends StatelessWidget {
  const _ActualiteItemSupprime(this.actualite);

  final ActualiteMissionLocaleItemSupprimeViewModel actualite;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChatDaySection(dayLabel: actualite.dateCreation),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: DsfrSpacings.s1w),
            padding: const EdgeInsets.symmetric(
              vertical: DsfrSpacings.s1w,
              horizontal: DsfrSpacings.s2w,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: DsfrColorDecisions.borderDefaultGrey(context)),
              borderRadius: BorderRadius.circular(DsfrSpacings.s1v),
            ),
            child: Text(
              Strings.actualiteMissionLocaleSupprime,
              style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
            ),
          ),
        ),
      ],
    );
  }
}
