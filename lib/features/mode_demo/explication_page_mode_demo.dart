import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/presentation/choix_mode_demo_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';

class ExplicationModeDemoPage extends StatelessWidget {
  static MaterialPageRoute<void> materialPageRoute() {
    return MaterialPageRoute(
      builder: (context) => ExplicationModeDemoPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.explicationModeDemo,
      child: StoreConnector<AppState, ChoixModeDemoViewModel>(
        converter: (store) => ChoixModeDemoViewModel.create(store),
        builder: (context, viewModel) {
          final backgroundColor = DsfrColorDecisions.backgroundDefaultGrey(context);
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: SecondaryAppBar(title: Strings.modeDemoExplicationTitre, backgroundColor: backgroundColor),
            body: SafeArea(
              child: _Contenu(viewModel),
            ),
          );
        },
      ),
    );
  }
}

class _Contenu extends StatelessWidget {
  final ChoixModeDemoViewModel viewModel;

  const _Contenu(this.viewModel);

  @override
  Widget build(BuildContext context) {
    final textColor = DsfrColorDecisions.textDefaultGrey(context);
    final regularStyle = DsfrTextStyle.bodyMd(color: textColor);
    final boldStyle = DsfrTextStyle.bodyMdBold(color: textColor);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w, vertical: DsfrSpacings.s3w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Icon(
              DsfrIcons.systemLockLine,
              size: 56,
              color: DsfrColorDecisions.artworkMajorBlueFrance(context),
            ),
          ),
          const SizedBox(height: DsfrSpacings.s3w),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: Strings.modeDemoExplicationPremierPoint1, style: regularStyle),
                TextSpan(text: Strings.modeDemoExplicationPremierPoint2, style: boldStyle),
                TextSpan(text: Strings.modeDemoExplicationPremierPoint3, style: regularStyle),
              ],
            ),
          ),
          const SizedBox(height: DsfrSpacings.s1w),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: Strings.modeDemoExplicationSecondPoint1, style: regularStyle),
                TextSpan(text: Strings.modeDemoExplicationSecondPoint2, style: boldStyle),
              ],
            ),
          ),
          const SizedBox(height: DsfrSpacings.s1w),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: Strings.modeDemoExplicationTroisiemePoint1, style: regularStyle),
                TextSpan(text: Strings.modeDemoExplicationTroisiemePoint2, style: boldStyle),
              ],
            ),
          ),
          const SizedBox(height: DsfrSpacings.s4w),
          Text(
            Strings.modeDemoExplicationChoix,
            style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
          DsfrButton(
            label: Strings.loginPoleEmploi,
            variant: DsfrButtonVariant.secondary,
            size: DsfrComponentSize.lg,
            onPressed: () => StoreProvider.of<AppState>(context).dispatch(RequestLoginAction(LoginMode.DEMO_PE)),
          ),
          if (viewModel.shouldDisplayMiloMode) ...[
            const SizedBox(height: DsfrSpacings.s2w),
            DsfrButton(
              label: Strings.loginMissionLocale,
              variant: DsfrButtonVariant.secondary,
              size: DsfrComponentSize.lg,
              onPressed: () => StoreProvider.of<AppState>(context).dispatch(RequestLoginAction(LoginMode.DEMO_MILO)),
            ),
          ],
        ],
      ),
    );
  }
}
