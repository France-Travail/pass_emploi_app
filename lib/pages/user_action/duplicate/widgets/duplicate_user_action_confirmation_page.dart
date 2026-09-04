import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_form_page.dart';
import 'package:pass_emploi_app/presentation/user_action/user_action_state_source.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';

class DuplicateUserActionConfirmationPage extends StatelessWidget {
  final String userActionId;
  final UserActionStateSource source;

  const DuplicateUserActionConfirmationPage({
    super.key,
    required this.userActionId,
    required this.source,
  });

  static Route<CreateActionFormResult> route(String userActionId, UserActionStateSource source) {
    return MaterialPageRoute<CreateActionFormResult>(
      fullscreenDialog: true,
      builder: (_) => DuplicateUserActionConfirmationPage(
        userActionId: userActionId,
        source: source,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = DsfrColorDecisions.backgroundDefaultGrey(context);
    return Theme(
      data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: SecondaryAppBar(
          title: Strings.duplicateUserActionConfirmationTitle,
          backgroundColor: backgroundColor,
        ),
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
                        Center(
                          child: SvgPicture.asset(
                            Drawables.illustrationSuccess,
                            width: 160,
                            height: 160,
                            excludeFromSemantics: true,
                          ),
                        ),
                        const SizedBox(height: DsfrSpacings.s3w),
                        Text(
                          Strings.duplicateUserActionConfirmationTitle,
                          textAlign: TextAlign.center,
                          style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
                        ),
                      ],
                    ),
                  ),
                ),
                _Buttons(
                  onGoActionDetail: () => Navigator.pop(context, NavigateToUserActionDetails(userActionId, source)),
                  onClose: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons({required this.onGoActionDetail, required this.onClose});

  final void Function() onGoActionDetail;
  final void Function() onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DsfrSpacings.s2w, top: DsfrSpacings.s4w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: double.infinity,
            child: DsfrButton(
              label: Strings.userActionConfirmationSeeDetailButton,
              variant: DsfrButtonVariant.primary,
              size: DsfrComponentSize.md,
              onPressed: onGoActionDetail,
            ),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
          SizedBox(
            width: double.infinity,
            child: DsfrButton(
              label: Strings.close,
              variant: DsfrButtonVariant.secondary,
              size: DsfrComponentSize.md,
              onPressed: onClose,
            ),
          ),
        ],
      ),
    );
  }
}
