import 'package:flutter/material.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/utils/mail_handler.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/snack_bar/show_snack_bar.dart';

class ContactPage extends StatelessWidget {
  static MaterialPageRoute<void> materialPageRoute() => MaterialPageRoute(builder: (context) => ContactPage());

  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.contactProfil,
      child: Scaffold(
        appBar: SecondaryAppBar(title: Strings.contactPageTitle),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_m),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: Margins.spacing_m),
                        Text(Strings.contactPageBody1, style: TextStyles.textBaseMedium),
                        SizedBox(height: Margins.spacing_m),
                        Text(Strings.contactPageBody2, style: TextStyles.textBaseMedium),
                        _bulletedText(Strings.contactPageBodyBullet1),
                        _bulletedText(Strings.contactPageBodyBullet2),
                        _bulletedText(Strings.contactPageBodyBullet3),
                        SizedBox(height: Margins.spacing_m),
                        Text(Strings.contactPageBody3, style: TextStyles.textBaseMedium),
                      ],
                    ),
                  ),
                ),
                PrimaryActionButton(
                  label: Strings.contactPageButton,
                  onPressed: () => _sendContactEmail(context),
                ),
                SizedBox(height: Margins.spacing_m),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bulletedText(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('•', style: TextStyles.textBaseMedium),
        SizedBox(width: Margins.spacing_s),
        Expanded(child: Text(text, style: TextStyles.textBaseMedium)),
      ],
    );
  }

  void _sendContactEmail(BuildContext context) async {
    final mailSent = await MailHandler.sendEmail(
      email: Strings.supportMail,
      subject: Strings.objetPriseDeContact,
      body: Strings.corpsPriseDeContact,
    );
    mailSent
        ? _contactDone(context)
        : showFailedSnackBar(
            context,
            Strings.miscellaneousErrorRetry,
          );
  }

  void _contactDone(BuildContext context) {
    Navigator.pop(context);
    PassEmploiMatomoTracker.instance.trackScreen(AnalyticsActionNames.contactEmailSent);
  }
}
