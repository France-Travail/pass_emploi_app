import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/pages/cv/cv_list_page.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';
import 'package:pass_emploi_app/widgets/a11y/external_link_semantics.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_bottom_sheet.dart';

class PostulerOffreBottomSheet extends StatelessWidget {
  final void Function() onPostuler;
  final String url;

  PostulerOffreBottomSheet({super.key, required this.onPostuler, required this.url});

  static Future<void> show(BuildContext context, {required VoidCallback onPostuler, required String url}) {
    return showDsfrBottomSheet<void>(
      context: context,
      name: AnalyticsScreenNames.cvListPage,
      builder: (context) => PostulerOffreBottomSheet(onPostuler: onPostuler, url: url),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DsfrBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Title(),
          const SizedBox(height: DsfrSpacings.s2w),
          CvList(insideBottomSheet: true),
          const SizedBox(height: DsfrSpacings.s2w),
          _ContinueButton(onPostuler: onPostuler, url: url),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AutoFocusA11y(
      child: Semantics(
        header: true,
        child: Text(
          Strings.postulerTitle,
          style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.onPostuler, required this.url});

  final VoidCallback onPostuler;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ExternalLinkSemantics(
      label: Strings.postulerContinueButton,
      url: url,
      onTap: onPostuler,
      child: DsfrButton(
        label: Strings.postulerContinueButton,
        icon: DsfrIcons.systemExternalLinkLine,
        variant: DsfrButtonVariant.primary,
        size: DsfrComponentSize.lg,
        onPressed: onPostuler,
      ),
    );
  }
}
