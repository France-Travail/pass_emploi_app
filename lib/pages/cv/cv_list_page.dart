import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/cv/cv_actions.dart';
import 'package:pass_emploi_app/models/cv_pole_emploi.dart';
import 'package:pass_emploi_app/network/post_evenement_engagement.dart';
import 'package:pass_emploi_app/presentation/cv/cv_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/external_links.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/context_extensions.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/preview_file_invisible_handler.dart';
import 'package:pass_emploi_app/widgets/retry.dart';

class CvListPage extends StatelessWidget {
  final bool insideBottomSheet;

  static MaterialPageRoute<void> materialPageRoute({bool insideBottomSheet = false}) {
    return MaterialPageRoute(builder: (context) => CvListPage(insideBottomSheet: insideBottomSheet));
  }

  CvListPage({required this.insideBottomSheet});

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.cvListPage,
      child: Scaffold(
        backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
        appBar: const BackAppBar(),
        body: Semantics(
          container: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DsfrSpacings.s2w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageTitle(Strings.cvListPageTitle),
                const SizedBox(height: DsfrSpacings.s2w),
                CvList(insideBottomSheet: insideBottomSheet),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CvList extends StatelessWidget {
  final bool insideBottomSheet;

  const CvList({required this.insideBottomSheet});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, CvViewModel>(
      onInit: (store) => store.dispatch(CvRequestAction()),
      converter: (store) => CvViewModel.create(store),
      builder: (context, viewModel) => _Body(viewModel, insideBottomSheet),
      distinct: true,
    );
  }
}

class _Body extends StatelessWidget {
  final bool insideBottomSheet;
  final CvViewModel viewModel;

  const _Body(this.viewModel, this.insideBottomSheet);

  @override
  Widget build(BuildContext context) {
    if (viewModel.apiPeKo) return _ApiPeKo(viewModel);
    return switch (viewModel.displayState) {
      DisplayState.LOADING => const _LoadingIndicator(),
      DisplayState.CONTENT => _Content(viewModel),
      DisplayState.EMPTY => _EmptyListPlaceholder(insideBottomSheet),
      DisplayState.FAILURE => Retry(Strings.cvError, () => viewModel.retry()),
    };
  }
}

class _Content extends StatelessWidget {
  final CvViewModel viewModel;

  const _Content(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.cvListPageSubtitle,
          style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        _CvListView(viewModel),
        PreviewFileInvisibleHandler(),
      ],
    );
  }
}

class _CvListView extends StatelessWidget {
  final CvViewModel viewModel;

  const _CvListView(this.viewModel);

  @override
  Widget build(BuildContext context) {
    final List<CvPoleEmploi> cvList = viewModel.cvList;
    return ListView.separated(
      itemCount: cvList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: DsfrSpacings.s2w),
      itemBuilder: (context, index) {
        final cv = cvList[index];
        final isLoading = viewModel.downloadStatus(cv.url).isLoading();
        if (isLoading) return const _LoadingIndicator();
        return Semantics(
          hint: Strings.cvDownload,
          child: DsfrDownloadFiles.tile(
            size: DsfrComponentSize.md,
            label: cv.titre,
            details: cv.nomFichier,
            onTap: () => _downloadCv(context, cv),
          ),
        );
      },
    );
  }

  void _downloadCv(BuildContext context, CvPoleEmploi cv) {
    viewModel.onDownload(cv);
    context.trackEvenementEngagement(EvenementEngagement.CV_PE_TELECHARGE);
  }
}

class _ApiPeKo extends StatelessWidget {
  const _ApiPeKo(this.viewModel);

  final CvViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DsfrAlert(
          type: DsfrAlertType.error,
          description: DsfrAlertDescriptionText(Strings.cvErrorApiPeKoMessage),
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        DsfrButton(
          label: Strings.cvErrorApiPeKoButton,
          icon: DsfrIcons.systemRefreshLine,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.lg,
          onPressed: viewModel.retry,
        ),
      ],
    );
  }
}

class _EmptyListPlaceholder extends StatelessWidget {
  final bool insideBottomSheet;

  _EmptyListPlaceholder(this.insideBottomSheet);

  @override
  Widget build(BuildContext context) {
    if (insideBottomSheet) return _minimalistEmpty(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _EmptyIllustration(),
        const SizedBox(height: DsfrSpacings.s2w),
        Semantics(
          header: true,
          child: Text(
            Strings.cvListEmptyTitle,
            style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        Text(
          Strings.cvListEmptySubitle,
          style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        _FranceTravailLinkButton(variant: DsfrButtonVariant.primary),
      ],
    );
  }

  Widget _minimalistEmpty(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Text(
            Strings.cvListEmptyTitle,
            style: DsfrTextStyle.bodyMdMedium(color: DsfrColorDecisions.textTitleGrey(context)),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        _FranceTravailLinkButton(variant: DsfrButtonVariant.secondary),
      ],
    );
  }
}

class _EmptyIllustration extends StatelessWidget {
  const _EmptyIllustration();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: DsfrColorDecisions.backgroundContrastBlueFrance(context),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: SizedBox.square(
            dimension: 80,
            child: Icon(
              DsfrIcons.documentFileLine,
              size: 40,
              color: DsfrColorDecisions.textTitleBlueFrance(context),
            ),
          ),
        ),
      ),
    );
  }
}

class _FranceTravailLinkButton extends StatelessWidget {
  const _FranceTravailLinkButton({required this.variant});

  final DsfrButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      button: false,
      label: '${Strings.cvEmptyButton}, ${Strings.link}',
      onTap: _launchAndTrackExternalLink,
      child: ExcludeSemantics(
        child: DsfrButton(
          label: Strings.cvEmptyButton,
          icon: DsfrIcons.systemExternalLinkLine,
          iconLocation: DsfrButtonIconLocation.right,
          variant: variant,
          size: DsfrComponentSize.lg,
          onPressed: _launchAndTrackExternalLink,
        ),
      ),
    );
  }

  void _launchAndTrackExternalLink() {
    PassEmploiMatomoTracker.instance.trackOutlink(ExternalLinks.espaceCandidats);
    launchExternalUrl(ExternalLinks.espaceCandidats);
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: Strings.loadingAnnouncement,
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DsfrSpacings.s3w),
        child: Center(
          child: CircularProgressIndicator(
            color: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
          ),
        ),
      ),
    );
  }
}
