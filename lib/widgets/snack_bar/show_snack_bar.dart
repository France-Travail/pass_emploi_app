import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';

final GlobalKey<ScaffoldMessengerState> snackBarKey = GlobalKey<ScaffoldMessengerState>();
final GlobalKey<ScaffoldMessengerState> modeDemoSnackBarKey = GlobalKey<ScaffoldMessengerState>();

@Deprecated('Do not use snackbar for a11y reasons')
void showSnackBarWithSuccess(BuildContext context, String label, [VoidCallback? onActionTap]) {
  _showSnackBar(context: context, type: DsfrAlertType.success, label: label, onActionTap: onActionTap);
}

void showSnackBarWithInformation(BuildContext context, String label) {
  _showSnackBar(context: context, type: DsfrAlertType.info, label: label, onActionTap: null);
}

void showSnackBarWithSystemError(BuildContext context, [String? label]) {
  _showSnackBar(
    context: context,
    type: DsfrAlertType.error,
    label: label ?? Strings.miscellaneousErrorRetry,
    onActionTap: null,
  );
}

void showSnackBarWithUserError(BuildContext context, String label) {
  _showSnackBar(context: context, type: DsfrAlertType.error, label: label, onActionTap: null);
}

void _showSnackBar({
  required BuildContext context,
  required DsfrAlertType type,
  required String label,
  required VoidCallback? onActionTap,
}) {
  clearAllSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      // a11y : 11.1 - bloquant: Le message de succès disparaît automatiquement après quelques secondes
      duration: Duration(minutes: 60),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      // AutoFocusA11y pose un Semantics(container: true, explicitChildNodes: true) : sans lui, la snackbar fusionne
      // le message et la croix en un seul bouton pour le lecteur d'écran.
      content: AutoFocusA11y(
        // a11y : 11.1 - bloquant: Pour s'assurer que le focus reste sur la snackbar même en cas de changement d'écran
        duration: Duration(milliseconds: 500),
        child: ColoredBox(
          color: DsfrColorDecisions.backgroundDefaultGrey(context),
          child: DsfrAlert(
            type: type,
            description: onActionTap == null
                ? DsfrAlertDescriptionText(label)
                : DsfrAlertDescriptionWidget(_SnackBarDescriptionWithAction(label: label, onActionTap: onActionTap)),
            semanticCloseLabel: Strings.closeInformationMessage,
            onClose: onActionTap == null ? clearAllSnackBars : null,
          ),
        ),
      ),
    ),
  );
}

class _SnackBarDescriptionWithAction extends StatelessWidget {
  const _SnackBarDescriptionWithAction({required this.label, required this.onActionTap});

  final String label;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context))),
        const SizedBox(height: DsfrSpacings.s1w),
        DsfrLink(
          label: Strings.consulter,
          size: DsfrComponentSize.md,
          onTap: () {
            clearAllSnackBars();
            onActionTap();
          },
        ),
      ],
    );
  }
}

void clearAllSnackBars() {
  snackBarKey.currentState?.clearSnackBars();
  modeDemoSnackBarKey.currentState?.clearSnackBars();
}
