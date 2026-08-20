import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/preferences/preferences_actions.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/profil/partage_activite_page_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/retry.dart';
import 'package:pass_emploi_app/widgets/snack_bar/show_snack_bar.dart';

class PartageActivitePage extends StatelessWidget {
  static MaterialPageRoute<void> materialPageRoute() {
    return MaterialPageRoute(builder: (context) => PartageActivitePage());
  }

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.shareActivity,
      child: StoreConnector<AppState, PartageActivitePageViewModel>(
        onInit: (store) => store.dispatch(PreferencesRequestAction()),
        converter: (store) => PartageActivitePageViewModel.create(store),
        builder: (context, viewModel) => _Body(viewModel),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final PartageActivitePageViewModel viewModel;

  const _Body(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      appBar: const BackAppBar(),
      body: switch (viewModel.displayState) {
        DisplayState.CONTENT => _Content(viewModel),
        DisplayState.FAILURE => Retry(Strings.miscellaneousErrorRetry, () => viewModel.onRetry()),
        _ => const _Loading(),
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

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

class _Content extends StatelessWidget {
  const _Content(this.viewModel);

  final PartageActivitePageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          DsfrSpacings.s3w,
          0,
          DsfrSpacings.s3w,
          DsfrSpacings.s4w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageTitle(Strings.activitySharePageTitle),
            const SizedBox(height: DsfrSpacings.s2w),
            Text(
              Strings.activityShareDescription,
              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
            const SizedBox(height: DsfrSpacings.s3w),
            _PartageFavoris(
              partageFavorisEnabled: viewModel.shareFavoris,
              onPartageFavorisValueChange: viewModel.onPartageFavorisTap,
              updatedState: viewModel.updateState,
            ),
            const DsfrDivider(),
          ],
        ),
      ),
    );
  }
}

class _PartageFavoris extends StatefulWidget {
  final bool partageFavorisEnabled;
  final Function(bool) onPartageFavorisValueChange;
  final DisplayState updatedState;

  const _PartageFavoris({
    required this.partageFavorisEnabled,
    required this.onPartageFavorisValueChange,
    required this.updatedState,
  });

  @override
  State<_PartageFavoris> createState() => _PartageFavorisState();
}

class _PartageFavorisState extends State<_PartageFavoris> {
  var _partageFavorisEnabled = false;

  @override
  void initState() {
    super.initState();
    _partageFavorisEnabled = widget.partageFavorisEnabled;
  }

  void _onPartageFavorisValueChange(bool value) {
    if (widget.updatedState == DisplayState.CONTENT) {
      setState(() {
        widget.onPartageFavorisValueChange(value);
        _partageFavorisEnabled = value;
      });
    } else if (widget.updatedState == DisplayState.FAILURE) {
      showSnackBarWithSystemError(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DsfrToggleSwitch(
      label: Strings.shareFavoriteLabel,
      labelLocation: DsfrToggleSwitchLabelLocation.left,
      value: _partageFavorisEnabled,
      status: _partageFavorisEnabled ? Strings.notificationsToggleEnabled : Strings.notificationsToggleDisabled,
      enabled: widget.updatedState != DisplayState.LOADING,
      onChanged: _onPartageFavorisValueChange,
    );
  }
}
