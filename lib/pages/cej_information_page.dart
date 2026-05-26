import 'package:flutter/material.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/buttons/secondary_button.dart';
import 'package:pass_emploi_app/widgets/cej_information_content_card.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/primary_rounded_bottom_background.dart';

class CejInformationPage extends StatefulWidget {
  static MaterialPageRoute<void> materialPageRoute() {
    return MaterialPageRoute(builder: (context) => CejInformationPage());
  }

  @override
  State<CejInformationPage> createState() => _CejInformationPageState();
}

class _CejInformationPageState extends State<CejInformationPage> {
  int _currentPage = 0;

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    PassEmploiMatomoTracker.instance.trackScreen(AnalyticsScreenNames.cejInformationPage(page + 1));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      CejInformationFirstContentCard(),
      CejInformationSecondContentCard(),
    ];

    return Scaffold(
      appBar: SecondaryAppBar(title: Strings.askAccount),
      backgroundColor: context.bg,
      body: Stack(
        children: [
          PrimaryRoundedBottomBackground(),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(Margins.spacing_m),
                    child: AnimatedSwitcher(
                      duration: AnimationDurations.medium,
                      child: pages[_currentPage],
                    ),
                  ),
                  SizedBox(height: Margins.spacing_m),
                  _Buttons(
                    onContinue: () => _onPageChanged(1),
                    onFinish: () => Navigator.of(context).pop(),
                    currentPage: _currentPage,
                  ),
                  SizedBox(height: Margins.spacing_xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons({required this.onContinue, required this.onFinish, required this.currentPage});
  final void Function() onContinue;
  final void Function() onFinish;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_m),
      child: AnimatedSwitcher(
        duration: AnimationDurations.medium,
        child: currentPage == 0
            ? _ContinueButton(onPressed: onContinue)
            : _LoginButton(
                onPressed: onFinish,
              ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.onPressed});
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: PrimaryActionButton(
        label: Strings.continueLabel,
        onPressed: onPressed,
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.onPressed});
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Strings.alreadyHaveAccount,
            style: TextStyles.textBaseRegular.copyWith(color: context.content),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Margins.spacing_base),
          SecondaryButton(
            label: Strings.loginAction,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
