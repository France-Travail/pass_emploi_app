import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/success/success_dialog_app_bar.dart';
import 'package:pass_emploi_app/widgets/success/success_illustration.dart';

class GenericSuccessPage extends StatelessWidget {
  const GenericSuccessPage({super.key, required this.title, required this.content});
  final String title;
  final String? content;

  static Route<dynamic> route({required String title, String? content}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => GenericSuccessPage(title: title, content: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      appBar: SuccessDialogAppBar(title: title),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SuccessIllustration(size: 160),
                  const SizedBox(height: DsfrSpacings.s3w),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
                  ),
                  if (content != null) ...[
                    const SizedBox(height: DsfrSpacings.s1w),
                    Text(
                      content!,
                      textAlign: TextAlign.center,
                      style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                    ),
                  ],
                  const SizedBox(height: DsfrSpacings.s3w),
                  DsfrButton(
                    label: Strings.close,
                    variant: DsfrButtonVariant.primary,
                    size: DsfrComponentSize.lg,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: DsfrSpacings.s4w),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
