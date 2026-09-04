import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/presentation/rating_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/utils/platform.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_dismissible_tile.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_tuile_card.dart';
import 'package:pass_emploi_app/widgets/rating_page.dart';

class AccueilRatingAppCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, RatingViewModel>(
      converter: (store) => RatingViewModel.create(store, PlatformUtils.getPlatform),
      builder: (context, viewModel) => _Body(viewModel),
    );
  }
}

class _Body extends StatelessWidget {
  final RatingViewModel viewModel;

  const _Body(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return DsfrDismissibleTile(
      title: Strings.ratingLabel,
      description: Strings.ratingButton,
      leading: DsfrTuileCardSvg(asset: Drawables.ratingStar),
      onTap: () => Navigator.push(context, RatingPage.materialPageRoute()),
      onDismiss: () {
        viewModel.onDone();
        PassEmploiMatomoTracker.instance.trackScreen(AnalyticsActionNames.skipRating);
      },
      dismissSemanticLabel: '${Strings.closeDialog} ${Strings.ratingLabel}',
    );
  }
}
