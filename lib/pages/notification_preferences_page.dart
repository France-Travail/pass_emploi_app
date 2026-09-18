import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/preferences/preferences_actions.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/preferences/notification_preferences_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_profil_tile.dart';
import 'package:pass_emploi_app/widgets/retry.dart';
import 'package:pass_emploi_app/widgets/snack_bar/show_snack_bar.dart';

class NotificationPreferencesPage extends StatelessWidget {
  static MaterialPageRoute<void> materialPageRoute() {
    return MaterialPageRoute(builder: (context) => NotificationPreferencesPage());
  }

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.notificationPreferences,
      child: StoreConnector<AppState, NotificationPreferencesViewModel>(
        onInit: (store) => store.dispatch(PreferencesRequestAction()),
        converter: (store) => NotificationPreferencesViewModel.create(store),
        builder: (context, viewModel) => _Body(viewModel),
        onDidChange: (previousViewModel, viewModel) => _onDidChange(previousViewModel, viewModel, context),
        distinct: true,
      ),
    );
  }

  void _onDidChange(
    NotificationPreferencesViewModel? previousViewModel,
    NotificationPreferencesViewModel viewModel,
    BuildContext context,
  ) {
    if (previousViewModel?.withUpdateError != viewModel.withUpdateError && viewModel.withUpdateError) {
      showSnackBarWithSystemError(context);
    }
  }
}

class _Body extends StatelessWidget {
  final NotificationPreferencesViewModel viewModel;

  const _Body(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      appBar: const BackAppBar(),
      body: switch (viewModel.displayState) {
        DisplayState.CONTENT => _Content(viewModel),
        DisplayState.FAILURE => Retry(Strings.miscellaneousErrorRetry, () => viewModel.retry()),
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

  final NotificationPreferencesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          DsfrSpacings.s2w,
          0,
          DsfrSpacings.s2w,
          DsfrSpacings.s4w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageTitle(Strings.notificationsLabel),
            const SizedBox(height: DsfrSpacings.s2w),
            DsfrToggleSwitchGroup(
              label: Strings.notificationsSettingsSubtitle,
              children: [
                _notificationSwitch(
                  title: Strings.notificationsSettingsAlertesTitle,
                  description: Strings.notificationsSettingsAlertesSubtitle,
                  value: viewModel.withAlertesOffres,
                  onChanged: viewModel.onAlertesOffresChanged,
                ),
                _notificationSwitch(
                  title: Strings.notificationsSettingsMonSuiviTitle,
                  description: Strings.notificationsSettingsMonSuiviSubtitle(viewModel.withMiloWording),
                  value: viewModel.withCreationAction,
                  onChanged: viewModel.onCreationActionChanged,
                ),
                _notificationSwitch(
                  title: Strings.notificationsSettingsRendezVoussTitle(viewModel.withMiloWording),
                  description: Strings.notificationsSettingsRendezVousSubtitle,
                  value: viewModel.withRendezvousSessions,
                  onChanged: viewModel.onRendezvousSessionsChanged,
                ),
                _notificationSwitch(
                  title: Strings.notificationsSettingsRappelsTitle,
                  description: Strings.notificationsSettingsRappelsSubtitle(viewModel.withMiloWording),
                  value: viewModel.withRappelActions,
                  onChanged: viewModel.onRappelActionsChanged,
                ),
                if (viewModel.withActuMiloPreference)
                  _notificationSwitch(
                    title: Strings.notificationsSettingsActuMiloTitle,
                    description: Strings.notificationsSettingsActuMiloSubtitle,
                    value: viewModel.withActuMilo,
                    onChanged: viewModel.onActuMiloChanged,
                  ),
              ],
            ),
            const SizedBox(height: DsfrSpacings.s2w),
            Semantics(
              header: true,
              child: Text(
                Strings.settingsLabel,
                style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
            ),
            const SizedBox(height: DsfrSpacings.s4w),
            Text(
              Strings.notificationsSettingsTitle,
              style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
            const SizedBox(height: DsfrSpacings.s1w),
            DsfrProfilTile(
              icon: DsfrIcons.systemExternalLinkLine,
              iconBackgroundColor: DsfrColors.greenEmeraude950,
              title: Strings.openNotificationsSettings,
              semanticsLink: true,
              onTap: viewModel.onOpenAppSettings,
            ),
          ],
        ),
      ),
    );
  }

  DsfrToggleSwitch _notificationSwitch({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return DsfrToggleSwitch(
      label: title,
      description: description,
      labelLocation: DsfrToggleSwitchLabelLocation.left,
      value: value,
      status: value ? Strings.notificationsToggleEnabled : Strings.notificationsToggleDisabled,
      onChanged: onChanged,
    );
  }
}
