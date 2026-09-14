import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/widgets/success/bottom_actions.dart';
import 'package:pass_emploi_app/widgets/success/success_illustration.dart';

class CreationConfirmationBody extends StatelessWidget {
  const CreationConfirmationBody({
    super.key,
    this.header,
    this.tag,
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  final Widget? header;
  final Widget? tag;
  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final titleColor = DsfrColorDecisions.textTitleGrey(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (header != null) ...[
                      const SizedBox(height: DsfrSpacings.s3w),
                      header!,
                      const SizedBox(height: DsfrSpacings.s3w),
                    ],
                    const SizedBox(height: DsfrSpacings.s3w),
                    const SuccessIllustration(),
                    const SizedBox(height: DsfrSpacings.s3v),
                    if (tag != null) ...[
                      tag!,
                      const SizedBox(height: DsfrSpacings.s3v),
                    ],
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: DsfrTextStyle.headline3(color: titleColor),
                    ),
                    const SizedBox(height: DsfrSpacings.s1w),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: DsfrTextStyle.bodyMd(color: titleColor),
                    ),
                  ],
                ),
              ),
            ),
            BottomActions(children: actions),
          ],
        ),
      ),
    );
  }
}
