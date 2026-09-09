import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_form_page.dart';
import 'package:pass_emploi_app/pages/user_action/duplicate/widgets/duplicate_user_action_confirmation_page.dart';
import 'package:pass_emploi_app/pages/user_action/edit/edit_user_action_form.dart';
import 'package:pass_emploi_app/pages/user_action/user_action_detail_page.dart';
import 'package:pass_emploi_app/presentation/user_action/duplicate_form/duplicate_user_action_view_model.dart';
import 'package:pass_emploi_app/presentation/user_action/user_action_create_view_model.dart';
import 'package:pass_emploi_app/presentation/user_action/user_action_state_source.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';

class DuplicateUserActionPage extends StatelessWidget {
  final UserActionStateSource source;
  final String userActionId;

  const DuplicateUserActionPage({
    super.key,
    required this.source,
    required this.userActionId,
  });

  static MaterialPageRoute<void> route(
    UserActionStateSource source,
    String userActionId,
  ) {
    return MaterialPageRoute<void>(
      builder: (_) => DuplicateUserActionPage(source: source, userActionId: userActionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.userActionDuplicate,
      child: StoreConnector<AppState, DuplicateUserActionViewModel>(
        converter: (store) => DuplicateUserActionViewModel.create(store, source, userActionId),
        builder: (context, viewModel) => _Body(viewModel),
        onWillChange: (previousVm, newVm) => _handleDisplayState(context, newVm),
        distinct: true,
      ),
    );
  }

  Future<void> _handleDisplayState(
    BuildContext context,
    DuplicateUserActionViewModel viewModel,
  ) async {
    final displayState = viewModel.displayState;
    final navigator = Navigator.of(context);
    if (displayState is DismissWithFailure) {
      navigator.pop();
      CreateUserActionFormPage.showSuccessPageForOfflineCreation(navigator.context);
    } else if (displayState is ShowConfirmationPage) {
      final result = await navigator.push(
        DuplicateUserActionConfirmationPage.route(
          displayState.userActionCreatedId,
          source,
        ),
      );
      if (!navigator.mounted) return;
      navigator.pop();
      if (result is NavigateToUserActionDetails) {
        UserActionDetailPage.show(
          navigator.context,
          result.userActionId,
          result.source,
        );
      }
    }
  }
}

class _Body extends StatelessWidget {
  const _Body(this.viewModel);

  final DuplicateUserActionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = DsfrColorDecisions.backgroundDefaultGrey(context);
    return Theme(
      data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: backgroundColor,
            appBar: SecondaryAppBar(
              title: Strings.duplicateUserAction,
              backgroundColor: backgroundColor,
            ),
            body: SafeArea(
              child: EditUserActionForm(
                confirmationLabel: Strings.duplicateUserAction,
                requireUpdate: false,
                actionDto: EditUserActionFormDto(
                  date: viewModel.date,
                  title: viewModel.title,
                  description: viewModel.description,
                  type: viewModel.type,
                ),
                onSaved: (actionDto) => viewModel.duplicate(
                  actionDto.date,
                  actionDto.title,
                  actionDto.description,
                  actionDto.type,
                ),
              ),
            ),
          ),
          if (viewModel.showLoading)
            Positioned.fill(
              child: ColoredBox(
                color: backgroundColor.withValues(alpha: 0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
