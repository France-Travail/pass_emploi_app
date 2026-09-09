import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/models/brand.dart';
import 'package:pass_emploi_app/presentation/rating_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/external_links.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/utils/platform.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_profil_tile.dart';
import 'package:pass_emploi_app/widgets/snack_bar/show_snack_bar.dart';

final InAppReview inAppReview = InAppReview.instance;

class RatingPage extends StatelessWidget {
  static MaterialPageRoute<void> materialPageRoute() => MaterialPageRoute(builder: (context) => RatingPage());

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, RatingViewModel>(
      converter: (state) => RatingViewModel.create(state, PlatformUtils.getPlatform),
      builder: (context, viewModel) => _Scaffold(viewModel),
      distinct: true,
    );
  }
}

class _Scaffold extends StatelessWidget {
  final RatingViewModel viewModel;

  const _Scaffold(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      appBar: const BackAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s3w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageTitle(Strings.ratingAppLabel),
            const SizedBox(height: DsfrSpacings.s3w),
            _Body(viewModel),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final RatingViewModel viewModel;

  const _Body(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DsfrProfilTile(
          icon: DsfrIcons.systemExternalLinkLine,
          iconBackgroundColor: DsfrColors.greenEmeraude950,
          title: Strings.rateAppOnStoresLabel,
          semanticsLink: true,
          onTap: () => _sendStoreReview(context, viewModel),
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        DsfrProfilTile(
          icon: DsfrIcons.othersLightbulbLine,
          iconBackgroundColor: DsfrColors.purpleGlycine925,
          title: Strings.proposeIdeaLabel,
          description: Strings.proposeIdeaSubtitle,
          semanticsLink: true,
          onTap: () => _proposeIdea(context),
        ),
      ],
    );
  }
}

void _sendStoreReview(BuildContext context, RatingViewModel viewModel) async {
  final isAvailable = await inAppReview.isAvailable();
  if (isAvailable) inAppReview.requestReview();
  if (!context.mounted) return;
  isAvailable ? _ratingDone(context, viewModel) : openAppStore(context, viewModel);
}

void openAppStore(BuildContext context, [RatingViewModel? viewModel]) async {
  try {
    await inAppReview.openStoreListing(
      appStoreId: Brand.getAppStoreIdiOS(),
    );
    if (!context.mounted) return;
    if (viewModel != null) _ratingDone(context, viewModel);
  } catch (e) {
    if (!context.mounted) return;
    showSnackBarWithSystemError(context);
  }
}

void _proposeIdea(BuildContext context) {
  final link = ExternalLinks.proposerUneIdee;
  PassEmploiMatomoTracker.instance.trackOutlink(link);
  PassEmploiMatomoTracker.instance.trackScreen(AnalyticsActionNames.proposeIdea);
  launchExternalUrl(link);
}

void _ratingDone(BuildContext context, RatingViewModel viewModel) {
  viewModel.onDone();
  Navigator.pop(context);
  PassEmploiMatomoTracker.instance.trackScreen(AnalyticsActionNames.positiveRating);
}
