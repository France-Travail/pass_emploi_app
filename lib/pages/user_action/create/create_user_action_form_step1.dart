import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/models/user_action_type.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/dsfr/emoji_solution_tile.dart';

class CreateUserActionFormStep1 extends StatelessWidget {
  const CreateUserActionFormStep1({super.key, required this.onActionTypeSelected});

  final void Function(UserActionReferentielType) onActionTypeSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Tracker(
        tracking: AnalyticsScreenNames.createUserActionStep1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DsfrSpacings.s2w),
              Semantics(
                sortKey: const OrdinalSortKey(1),
                child: Text(
                  Strings.userActionSubtitleStep1,
                  style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
                ),
              ),
              const SizedBox(height: DsfrSpacings.s2w),
              Semantics(
                sortKey: const OrdinalSortKey(2),
                child: ActionCategorySelector(onActionSelected: onActionTypeSelected),
              ),
              const SizedBox(height: DsfrSpacings.s2w),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionCategorySelector extends StatelessWidget {
  const ActionCategorySelector({super.key, required this.onActionSelected});

  final void Function(UserActionReferentielType) onActionSelected;

  @override
  Widget build(BuildContext context) {
    return EmojiSolutionGrid(
      tiles: UserActionReferentielTypePresentation.all
          .map(
            (type) => EmojiSolutionTile(
              onTap: () => onActionSelected(type),
              emoji: type.emoji,
              emojiBackground: type.emojiBackground,
              title: type.label,
              subtitle: type.description,
            ),
          )
          .toList(),
    );
  }
}
