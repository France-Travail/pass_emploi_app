// ignore_for_file: use_decorated_box

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/presentation/choix_mode_demo_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/widgets/buttons/colored_action_button.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/illustration/illustration.dart';

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
          return Scaffold(
            backgroundColor: context.grey100,
            appBar: SecondaryAppBar(title: Strings.modeDemoExplicationTitre),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_m, vertical: Margins.spacing_base),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: Margins.spacing_m),
            Center(
              child: SizedBox(
                height: 130,
                width: 130,
                child: Illustration.blue(AppIcons.lock_rounded),
              ),
            ),
            SizedBox(height: Margins.spacing_m),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_m),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: Strings.modeDemoExplicationPremierPoint1,
                      style: TextStyles.textBaseRegular.copyWith(color: context.content),
                    ),
                    TextSpan(
                      text: Strings.modeDemoExplicationPremierPoint2,
                      style: TextStyles.textBaseBold.copyWith(color: context.content),
                    ),
                    TextSpan(
                      text: Strings.modeDemoExplicationPremierPoint3,
                      style: TextStyles.textBaseRegular.copyWith(color: context.content),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: Margins.spacing_s),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_m),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: Strings.modeDemoExplicationSecondPoint1,
                      style: TextStyles.textBaseRegular.copyWith(color: context.content),
                    ),
                    TextSpan(
                      text: Strings.modeDemoExplicationSecondPoint2,
                      style: TextStyles.textBaseBold.copyWith(color: context.content),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: Margins.spacing_s),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_m),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: Strings.modeDemoExplicationTroisiemePoint1,
                      style: TextStyles.textBaseRegular.copyWith(color: context.content),
                    ),
                    TextSpan(
                      text: Strings.modeDemoExplicationTroisiemePoint2,
                      style: TextStyles.textBaseBold.copyWith(color: context.content),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: Margins.spacing_m,
                right: Margins.spacing_m,
                top: Margins.spacing_xl,
              ),
              child: Text(
                Strings.modeDemoExplicationChoix,
                style: TextStyles.textBaseBold.copyWith(color: context.content),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Margins.spacing_m),
              child: ColoredActionButton(
                label: Strings.loginPoleEmploi,
                backgroundColor: AppColors.primaryDarken,
                textColor: AppColors.contentOnPrimary,
                onPressed: () => StoreProvider.of<AppState>(context).dispatch(RequestLoginAction(LoginMode.DEMO_PE)),
              ),
            ),
            if (viewModel.shouldDisplayMiloMode)
              Padding(
                padding: const EdgeInsets.only(
                  left: Margins.spacing_m,
                  right: Margins.spacing_m,
                  bottom: Margins.spacing_m,
                ),
                child: ColoredActionButton(
                  label: Strings.loginMissionLocale,
                  backgroundColor: AppColors.accent1,
                  textColor: AppColors.contentOnPrimary,
                  onPressed: () =>
                      StoreProvider.of<AppState>(context).dispatch(RequestLoginAction(LoginMode.DEMO_MILO)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
