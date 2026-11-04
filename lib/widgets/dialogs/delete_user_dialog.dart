import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/profil/suppression_compte_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/theme.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';

class DeleteAlertDialog extends StatefulWidget {
  const DeleteAlertDialog();

  static Future<void> show(BuildContext context) {
    PassEmploiMatomoTracker.instance.trackScreen(AnalyticsActionNames.suppressionAccountConfirmation);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: DsfrColorDecisions.backgroundTransparent(context),
      barrierColor: DsfrColorDecisions.backgroundOverlayGrey(context),
      barrierLabel: Strings.bottomSheetBarrierLabel,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Theme(
          data: isDarkMode ? PassEmploiTheme.darkData : PassEmploiTheme.data,
          child: DsfrModal(
            isDismissible: true,
            closeLabel: Strings.close,
            child: const DeleteAlertDialog(),
          ),
        ),
      ),
    );
  }

  @override
  State<DeleteAlertDialog> createState() => _DeleteAlertDialogState();
}

class _DeleteAlertDialogState extends State<DeleteAlertDialog> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  String? _fieldContent;
  bool _showError = false;

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SuppressionCompteViewModel>(
      converter: (store) => SuppressionCompteViewModel.create(store),
      builder: (context, viewModel) => _build(context, viewModel),
    );
  }

  Widget _build(BuildContext context, SuppressionCompteViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SvgPicture.asset(
            Drawables.illustrationWarning,
            width: 80,
            height: 80,
            excludeFromSemantics: true,
          ),
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        // A11y 7.1 / 10.2 : titre de la fenêtre, qui reçoit le focus du lecteur d'écran à l'ouverture.
        AutoFocusA11y(
          child: Semantics(
            header: true,
            child: Text(
              Strings.warning,
              style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        // A11y 9.9 : le message d'erreur, affiché sous le champ, est restitué avec le champ (même nœud).
        MergeSemantics(
          child: DsfrInput(
            label: Strings.lastWarningBeforeSuppression,
            controller: _inputController,
            focusNode: _inputFocusNode,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            componentState: _hasError
                ? DsfrComponentState.error(errorMessage: Strings.mandatorySuppressionLabelError)
                : const DsfrComponentState.none(),
            onChanged: (value) {
              setState(() {
                _fieldContent = value;
                _showError = false;
              });
            },
          ),
        ),
        const SizedBox(height: DsfrSpacings.s4w),
        DsfrButton(
          label: Strings.suppressionLabel,
          icon: DsfrIcons.systemDeleteBinLine,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.lg,
          foregroundColor: DsfrColorDecisions.textDefaultError(context),
          onPressed: _canDeleteAccount(viewModel)
              ? () {
                  viewModel.onDeleteUser();
                  Navigator.pop(context);
                }
              : () {
                  // A11y 9.9 / 10.2 : l'erreur est affichée, y compris champ vide, puis le focus revient sur le
                  // champ à corriger ; l'annonce garantit que l'erreur est entendue.
                  setState(() => _showError = true);
                  _inputFocusNode.requestFocusWithA11y();
                  A11yUtils.announce(Strings.mandatorySuppressionLabelError);
                },
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrButton(
          label: Strings.cancelLabel,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.lg,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  bool _canDeleteAccount(SuppressionCompteViewModel viewModel) {
    return _isStringValid() && viewModel.displayState != DisplayState.LOADING;
  }

  bool _isStringValid() {
    if (!_isFormValid()) return false;
    final stringToCheck = _fieldContent!.toLowerCase().trim();
    return stringToCheck == Strings.suppressionLabel.toLowerCase();
  }

  bool _isFormValid() => _fieldContent != null && _fieldContent!.isNotEmpty;

  bool get _hasError => _showError && !_isStringValid();
}
