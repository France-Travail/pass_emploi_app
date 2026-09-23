import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_form_page.dart';
import 'package:pass_emploi_app/pages/user_action/user_action_detail_page.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/user_action/create_user_action_confirmation_view_model.dart';
import 'package:pass_emploi_app/presentation/user_action/user_action_state_source.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_card_semantics.dart';
import 'package:pass_emploi_app/widgets/errors/error_text.dart';
import 'package:pass_emploi_app/widgets/success/creation_confirmation_body.dart';

class CreateUserActionConfirmationOffreSuiviPage extends StatelessWidget {
  const CreateUserActionConfirmationOffreSuiviPage({super.key});

  static Route<CreateActionFormResult> route() {
    return MaterialPageRoute<CreateActionFormResult>(
      fullscreenDialog: true,
      builder: (_) => CreateUserActionConfirmationOffreSuiviPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, CreateActionSuccessViewModel>(
      converter: (store) => CreateActionSuccessViewModel.create(store),
      builder: (context, viewModel) {
        final backgroundColor = DsfrColorDecisions.backgroundDefaultGrey(context);
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: SecondaryAppBar(
            title: Strings.createActionAppBarTitle,
            backgroundColor: backgroundColor,
          ),
          body: _Content(viewModel: viewModel),
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.viewModel});
  final CreateActionSuccessViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return switch (viewModel.displayState) {
      DisplayState.CONTENT => CreationConfirmationBody(
        tag: DsfrCategoryTag.actionDone(),
        title: Strings.userActionConfirmationTitleSingular,
        subtitle: Strings.userActionConfirmationSubtitleLegacy,
        actions: [
          AutoFocusA11y(
            child: DsfrButton(
              label: Strings.userActionConfirmationSeeDetailButton,
              variant: DsfrButtonVariant.primary,
              size: DsfrComponentSize.lg,
              onPressed: () => _goToActionDetail(context),
            ),
          ),
        ],
      ),
      DisplayState.FAILURE => Center(
        child: ErrorText(Strings.genericCreationError),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  void _goToActionDetail(BuildContext context) {
    final navigator = Navigator.of(context);
    final actionId = viewModel.actionId;
    navigator.pop();
    UserActionDetailPage.show(
      navigator.context,
      actionId,
      UserActionStateSource.noSource,
    );
  }
}
