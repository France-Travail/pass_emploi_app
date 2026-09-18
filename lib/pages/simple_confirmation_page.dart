import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/success/bottom_actions.dart';
import 'package:pass_emploi_app/widgets/success/success_illustration.dart';

class SimpleConfirmationPage extends StatelessWidget {
  const SimpleConfirmationPage._(this.title);

  static Route<void> favoris() {
    return MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => SimpleConfirmationPage._(Strings.offreFavorisConfirmationAppBar),
    );
  }

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = DsfrColorDecisions.backgroundDefaultGrey(context);
    return Theme(
      data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: SecondaryAppBar(title: title, backgroundColor: backgroundColor),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: DsfrSpacings.s3w),
                        const SuccessIllustration(size: 160),
                        const SizedBox(height: DsfrSpacings.s3w),
                        Semantics(
                          header: true,
                          child: Text(
                            Strings.offreSuivieConfirmationPageTitle,
                            textAlign: TextAlign.center,
                            style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
                          ),
                        ),
                        const SizedBox(height: DsfrSpacings.s1w),
                        Text(
                          Strings.offreSuivieConfirmationPageDescription,
                          textAlign: TextAlign.center,
                          style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                        ),
                      ],
                    ),
                  ),
                ),
                BottomActions(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: DsfrButton(
                        label: Strings.understood,
                        variant: DsfrButtonVariant.primary,
                        size: DsfrComponentSize.md,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
