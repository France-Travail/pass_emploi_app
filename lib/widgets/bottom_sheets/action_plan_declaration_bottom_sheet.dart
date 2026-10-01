import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_actions.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_form_step2.dart';
import 'package:pass_emploi_app/presentation/action_plan/action_plan_declaration_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/model/date_input_source.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/date_pickers/past_date_choice.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_card_semantics.dart';

class ActionPlanDeclarationBottomSheet extends StatelessWidget {
  const ActionPlanDeclarationBottomSheet({super.key, required this.actionId});

  final String actionId;

  static Future<void> show(BuildContext context, String actionId) {
    StoreProvider.of<AppState>(context).dispatch(ActionPlanDeclarationResetAction());
    return showDsfrBottomSheet<void>(
      context: context,
      name: AnalyticsScreenNames.actionPlanDeclaration,
      builder: (context) => ActionPlanDeclarationBottomSheet(actionId: actionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DsfrBottomSheet(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(DsfrSpacings.s2w, 0, DsfrSpacings.s2w, DsfrSpacings.s2w),
        child: ActionPlanDeclarationContent(actionId: actionId),
      ),
    );
  }
}

class ActionPlanDeclarationContent extends StatelessWidget {
  const ActionPlanDeclarationContent({super.key, required this.actionId});

  final String actionId;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ActionPlanDeclarationViewModel>(
      converter: (store) => ActionPlanDeclarationViewModel.create(store, actionId),
      distinct: true,
      builder: (context, viewModel) => viewModel.displayState == DisplayState.CONTENT
          ? _Succes(viewModel: viewModel)
          : _Formulaire(viewModel: viewModel),
    );
  }
}

class _Formulaire extends StatefulWidget {
  const _Formulaire({required this.viewModel});

  final ActionPlanDeclarationViewModel viewModel;

  @override
  State<_Formulaire> createState() => _FormulaireState();
}

class _FormulaireState extends State<_Formulaire> {
  DateInputSource _date = DateNotInitialized();
  final TextEditingController _commentaire = TextEditingController();

  @override
  void dispose() {
    _commentaire.dispose();
    super.dispose();
  }

  bool get _peutDeclarer {
    final viewModel = widget.viewModel;
    if (viewModel.displayState == DisplayState.LOADING) return false;
    if (!_date.isValid) return false;
    return !viewModel.commentaireRequis || _commentaire.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (viewModel.categorie != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: DsfrCategoryTag.emploiCategory(label: viewModel.categorie!),
            ),
            const SizedBox(height: DsfrSpacings.s1w),
          ],
          Text(
            viewModel.titre,
            style: DsfrTextStyle.headline5(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
          const SizedBox(height: DsfrSpacings.s3w),
          PastDateChoice(
            title: Strings.actionPlanDeclarationQuand,
            onDateChanged: (date) => setState(() => _date = date),
          ),
          if (viewModel.commentaireRequis) ...[
            const SizedBox(height: DsfrSpacings.s3w),
            UserActionDescriptionField(
              descriptionController: _commentaire,
              onDescriptionChanged: (_) => setState(() {}),
              onClear: () => setState(_commentaire.clear),
              hintText: Strings.actionPlanDeclarationDecrireExemple,
              isInvalid: false,
            ),
          ],
          if (viewModel.messageErreur != null) ...[
            const SizedBox(height: DsfrSpacings.s2w),
            DsfrAlert(
              type: DsfrAlertType.error,
              description: DsfrAlertDescriptionText(viewModel.messageErreur!),
            ),
          ],
          const SizedBox(height: DsfrSpacings.s3w),
          DsfrButton(
            label: Strings.markActionAsDone,
            icon: DsfrIcons.systemCheckLine,
            variant: DsfrButtonVariant.primary,
            size: DsfrComponentSize.lg,
            onPressed: _peutDeclarer ? () => viewModel.onDeclare(_date.selectedDate, _commentaire.text) : null,
          ),
        ],
      ),
    );
  }
}

class _Succes extends StatelessWidget {
  const _Succes({required this.viewModel});

  final ActionPlanDeclarationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final texte = DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SvgPicture.asset(Drawables.illustrationSuccess, width: 56, height: 56, excludeFromSemantics: true),
        ),
        const SizedBox(height: DsfrSpacings.s3v),
        Center(child: DsfrCategoryTag.actionDone()),
        const SizedBox(height: DsfrSpacings.s3v),
        Text(
          Strings.userActionConfirmationTitle(viewModel.prenom),
          textAlign: TextAlign.center,
          style: DsfrTextStyle.headline3(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        Text(Strings.actionPlanDeclarationSuccesEnregistree, textAlign: TextAlign.center, style: texte),
        const SizedBox(height: DsfrSpacings.s2w),
        Text(Strings.actionPlanDeclarationSuccesConseiller, textAlign: TextAlign.center, style: texte),
        const SizedBox(height: DsfrSpacings.s4w),
        DsfrButton(
          label: Strings.actionPlanDeclarationVoirAgenda,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: () {
            Navigator.of(context).pop();
            viewModel.onVoirAgenda();
          },
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrButton(
          label: Strings.actionPlanDeclarationRetourPlan,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.lg,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
