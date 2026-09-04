import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/presentation/email_subject_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/mail_handler.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/snack_bar/show_snack_bar.dart';

class ContactPage extends StatelessWidget {
  static MaterialPageRoute<void> materialPageRoute() => MaterialPageRoute(builder: (context) => ContactPage());

  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.contactProfil,
      child: StoreConnector<AppState, EmailObjectViewModel>(
        converter: (store) => EmailObjectViewModel.create(store),
        builder: (context, viewModel) {
          return Scaffold(
            backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
            appBar: const BackAppBar(),
            body: Column(
              children: [
                Expanded(child: _Body()),
                _ContactButton(viewModel: viewModel),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle = DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context));
    return Semantics(
      container: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s3w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageTitle(Strings.contactPageTitle),
            const SizedBox(height: DsfrSpacings.s2w),
            Text(Strings.contactPageBody1, style: textStyle),
            const SizedBox(height: DsfrSpacings.s3w),
            Text(Strings.contactPageBody2, style: textStyle),
            _ListedItems(
              items: [
                Strings.contactPageBodyBullet1,
                Strings.contactPageBodyBullet2,
                Strings.contactPageBodyBullet3,
              ],
            ),
            const SizedBox(height: DsfrSpacings.s3w),
            Text(Strings.contactPageBody3, style: textStyle),
            const SizedBox(height: DsfrSpacings.s3w),
            const DsfrDivider(),
          ],
        ),
      ),
    );
  }
}

class _ListedItems extends StatelessWidget {
  final List<String> items;

  const _ListedItems({required this.items});

  @override
  Widget build(BuildContext context) {
    final textStyle = DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Semantics(
            container: true,
            child: Padding(
              padding: const EdgeInsets.only(left: DsfrSpacings.s3w, bottom: DsfrSpacings.s1v),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(child: Text('•', style: textStyle)),
                  const SizedBox(width: DsfrSpacings.s1w),
                  Expanded(child: Text(item, style: textStyle)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  final EmailObjectViewModel viewModel;

  const _ContactButton({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: DsfrSpacings.s5w),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
        child: SizedBox(
          width: double.infinity,
          child: DsfrButton(
            label: Strings.contactPageButton,
            icon: DsfrIcons.businessMailLine,
            variant: DsfrButtonVariant.primary,
            size: DsfrComponentSize.lg,
            onPressed: () => _sendContactEmail(context, viewModel),
          ),
        ),
      ),
    );
  }

  void _sendContactEmail(BuildContext context, EmailObjectViewModel viewModel) async {
    final mailSent = await MailHandler.sendEmail(
      email: Strings.supportMail,
      object: viewModel.contactEmailObject,
      body: Strings.corpsPriseDeContact,
    );
    if (!context.mounted) return;
    mailSent ? _contactDone(context) : showSnackBarWithSystemError(context, Strings.miscellaneousErrorRetry);
  }

  void _contactDone(BuildContext context) {
    Navigator.pop(context);
    PassEmploiMatomoTracker.instance.trackScreen(AnalyticsActionNames.contactEmailSent);
  }
}
