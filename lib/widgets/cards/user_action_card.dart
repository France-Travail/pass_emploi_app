import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/presentation/user_action/user_action_card_view_model.dart';
import 'package:pass_emploi_app/presentation/user_action/user_action_state_source.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_card_semantics.dart';

class UserActionCard extends StatelessWidget {
  final String userActionId;
  final UserActionStateSource source;

  const UserActionCard({
    super.key,
    required this.userActionId,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, UserActionCardViewModel>(
      converter: (store) => UserActionCardViewModel.create(
        store: store,
        stateSource: source,
        actionId: userActionId,
      ),
      builder: _builder,
      distinct: true,
    );
  }

  Widget _builder(BuildContext context, UserActionCardViewModel viewModel) {
    final (badgeType, badgeLabel) = viewModel.pillule.toActionDsfrBadge();

    // A11y : to read "Action" + category + title + status
    return Semantics(
      label: Strings.accueilActionSingular,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: DsfrSpacings.s1w,
            runSpacing: DsfrSpacings.s1w,
            children: [
              DsfrCategoryTag.emploiCategory(label: viewModel.categoryText),
              DsfrStatusBadge(
                label: badgeLabel,
                type: badgeType,
                excludeSemantics: true,
              ),
            ],
          ),
          const SizedBox(height: DsfrSpacings.s1w),
          Text(
            viewModel.title,
            style: DsfrTextStyle.bodyMdBold(
              color: DsfrColorDecisions.textTitleGrey(context),
            ),
          ),
          Semantics(label: Strings.a11yStatus + badgeLabel),
        ],
      ),
    );
  }
}
