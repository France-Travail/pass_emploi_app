import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';

class InviteActionPlanSection extends StatelessWidget {
  const InviteActionPlanSection({
    super.key,
    required this.plan,
    required this.locked,
    required this.onToggleDone,
    required this.onDelete,
  });

  final ActionPlan? plan;
  final bool locked;
  final void Function(String actionId) onToggleDone;
  final void Function(String actionId) onDelete;

  @override
  Widget build(BuildContext context) {
    if (locked) {
      return _LockedPlaceholders();
    }
    final objectives = plan?.objectives ?? const <ActionPlanObjective>[];
    if (objectives.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (var i = 0; i < objectives.length; i++) ...[
          if (i > 0) const DsfrDivider(),
          _ObjectiveAccordion(
            objective: objectives[i],
            onToggleDone: onToggleDone,
            onDelete: onDelete,
          ),
        ],
        const DsfrDivider(),
      ],
    );
  }
}

class _LockedPlaceholders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: 0.35,
          child: Column(
            children: [
              _LockedRow(emoji: '💼', title: Strings.inviteAccueilLockedPlanEmploi),
              const DsfrDivider(),
              _LockedRow(emoji: '🔎', title: Strings.inviteAccueilLockedPlanMetiers),
              const DsfrDivider(),
            ],
          ),
        ),
        Semantics(
          label: Strings.inviteAccueilLockedPlanSemantics,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: DsfrColorDecisions.backgroundDefaultGrey(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: DsfrColorDecisions.borderActionHighBlueFrance(context)),
            ),
            child: Padding(
              padding: EdgeInsets.all(Margins.spacing_s),
              child: Image.asset(
                'assets/dsfr/padlock.webp',
                width: 80,
                height: 80,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LockedRow extends StatelessWidget {
  const _LockedRow({required this.emoji, required this.title});

  final String emoji;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_base, vertical: Margins.spacing_s),
      child: Row(
        children: [
          _EmojiAvatar(emoji: emoji, color: DsfrColors.greenEmeraude950),
          const SizedBox(width: Margins.spacing_base),
          Expanded(
            child: Text(
              title,
              style: DsfrTextStyle.bodyMdMedium(color: DsfrColorDecisions.textTitleBlueFrance(context)),
            ),
          ),
          DsfrBadge(
            label: '0/6',
            type: DsfrBadgeType.news,
            size: DsfrComponentSize.sm,
            withIcon: true,
          ),
          const SizedBox(width: Margins.spacing_s),
          Icon(DsfrIcons.systemArrowDownSLine, color: DsfrColorDecisions.textActionHighBlueFrance(context)),
        ],
      ),
    );
  }
}

class _ObjectiveAccordion extends StatefulWidget {
  const _ObjectiveAccordion({
    required this.objective,
    required this.onToggleDone,
    required this.onDelete,
  });

  final ActionPlanObjective objective;
  final void Function(String actionId) onToggleDone;
  final void Function(String actionId) onDelete;

  @override
  State<_ObjectiveAccordion> createState() => _ObjectiveAccordionState();
}

class _ObjectiveAccordionState extends State<_ObjectiveAccordion> {
  bool _expanded = false;
  bool _showAll = false;
  static const _initialVisible = 5;
  static const _animationCurve = Curves.ease;

  @override
  Widget build(BuildContext context) {
    final objective = widget.objective;
    final visibleActions = _showAll ? objective.actions : objective.actions.take(_initialVisible).toList();
    final hasMore = objective.actions.length > _initialVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: AnimatedContainer(
            duration: AnimationDurations.medium,
            curve: _animationCurve,
            color: _expanded
                ? DsfrColorDecisions.backgroundActionLowBlueFrance(context)
                : DsfrColorDecisions.backgroundDefaultGrey(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_base, vertical: Margins.spacing_s),
              child: Row(
                children: [
                  _EmojiAvatar(
                    emoji: _emojiForTheme(objective.theme),
                    color: _colorForTheme(objective.theme),
                  ),
                  const SizedBox(width: Margins.spacing_base),
                  Expanded(
                    child: Text(
                      objective.title,
                      style: DsfrTextStyle.bodyMdMedium(color: DsfrColorDecisions.textTitleBlueFrance(context)),
                    ),
                  ),
                  DsfrBadge(
                    label: Strings.inviteAccueilProgressBadge(objective.doneCount, objective.totalCount),
                    type: objective.isComplete ? DsfrBadgeType.success : DsfrBadgeType.news,
                    size: DsfrComponentSize.sm,
                    withIcon: true,
                  ),
                  const SizedBox(width: Margins.spacing_base),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: AnimationDurations.medium,
                    curve: _animationCurve,
                    child: Icon(
                      DsfrIcons.systemArrowDownSLine,
                      color: DsfrColorDecisions.textActionHighBlueFrance(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(Margins.spacing_s, 0, Margins.spacing_s, Margins.spacing_s),
            child: AnimatedSize(
              duration: AnimationDurations.medium,
              curve: _animationCurve,
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  for (final action in visibleActions) ...[
                    const SizedBox(height: Margins.spacing_s),
                    InviteActionPlanActionTile(
                      action: action,
                      onToggleDone: () => widget.onToggleDone(action.id),
                      onDelete: () => widget.onDelete(action.id),
                    ),
                  ],
                  if (hasMore && !_showAll) ...[
                    const SizedBox(height: Margins.spacing_s),
                    DsfrButton(
                      label: Strings.inviteAccueilAfficherPlus,
                      variant: DsfrButtonVariant.secondary,
                      size: DsfrComponentSize.lg,
                      onPressed: () => setState(() => _showAll = true),
                    ),
                  ],
                ],
              ),
            ),
          ),
          crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: AnimationDurations.medium,
          sizeCurve: _animationCurve,
        ),
      ],
    );
  }
}

class InviteActionPlanActionTile extends StatelessWidget {
  const InviteActionPlanActionTile({
    super.key,
    required this.action,
    required this.onToggleDone,
    required this.onDelete,
  });

  final ActionPlanAction action;
  final VoidCallback onToggleDone;
  final VoidCallback onDelete;

  bool get _hasLink => action.kind == ActionPlanActionKind.link && action.url != null && action.url!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DsfrColorDecisions.backgroundDefaultGrey(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DsfrColorDecisions.borderDefaultGrey(context)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _hasLink ? _openLink : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(Margins.spacing_base),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Semantics(
                  checked: action.done,
                  label: action.label,
                  hint: action.serviceName,
                  button: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onToggleDone,
                    child: Padding(
                      padding: const EdgeInsets.only(right: Margins.spacing_base),
                      child: DsfrCheckboxIcon(value: action.done, size: DsfrComponentSize.md),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.label,
                        style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textLabelGrey(context)),
                      ),
                      if (action.serviceName != null)
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                action.serviceName!,
                                style: DsfrTextStyle.bodyXs(
                                  color: DsfrColorDecisions.textActionHighBlueFrance(context),
                                ),
                              ),
                            ),
                            if (_hasLink) ...[
                              const SizedBox(width: Margins.spacing_xs),
                              Padding(
                                // manually ajusted to match the text
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Icon(
                                  DsfrIcons.systemExternalLinkLine,
                                  size: 12,
                                  color: DsfrColorDecisions.textActionHighBlueFrance(context),
                                ),
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    DsfrIcons.systemDeleteBinFill,
                    color: DsfrColorDecisions.textActionHighBlueFrance(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openLink() => launchExternalUrl(action.url!);
}

class _EmojiAvatar extends StatelessWidget {
  const _EmojiAvatar({required this.emoji, required this.color});

  final String emoji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
      child: Text(emoji, style: const TextStyle(fontSize: 24)),
    );
  }
}

// Emojis/colors mirror QuestionnaireObjectif / QuestionnaireFrein in
// onboarding_questionnaire_answers.dart, keyed by BayesImpactProfileMapper slugs
// (Goal | Obstacle from 1jeune-des-solutions api-contracts).
String _emojiForTheme(String theme) => switch (theme) {
  // Goals
  'orientation' => '🧭',
  'discover-jobs' => '🔎',
  'training' => '📚',
  'internship-immersion' => '👀',
  'apprenticeship' => '🔧',
  'job' => '💼',
  'civic-engagement' => '🤝',
  'international-mobility' => '✈️',
  'guidance-support' => '🩹',
  'start-business' => '🚀',
  'dont-know' => '🍿',
  // Obstacles
  'transport' => '🚗',
  'housing' => '🏠',
  'confidence' => '😟',
  'money' => '💶',
  'no-diploma' => '🎓',
  'disability' => '♿',
  'health' => '🩺',
  'childcare' => '👶',
  'no-device' => '💻',
  _ => '🎯',
};

Color _colorForTheme(String theme) => switch (theme) {
  // Goals
  'orientation' => DsfrColors.pinkTuile950,
  'discover-jobs' => DsfrColors.greenTilleulVerveine950,
  'training' => DsfrColors.purpleGlycine950,
  'internship-immersion' => DsfrColors.blueCumulus950,
  'apprenticeship' => DsfrColors.blueFrance925,
  'job' => DsfrColors.greenEmeraude950,
  'civic-engagement' => DsfrColors.greenTilleulVerveine925,
  'international-mobility' => DsfrColors.purpleGlycine925,
  'guidance-support' => DsfrColors.pinkTuile925,
  'start-business' => DsfrColors.greenEmeraude925,
  'dont-know' => DsfrColors.pinkTuile950,
  // Obstacles
  'transport' => DsfrColors.greenTilleulVerveine950,
  'housing' => DsfrColors.greenEmeraude950,
  'confidence' => DsfrColors.pinkTuile950,
  'money' => DsfrColors.greenTilleulVerveine925,
  'no-diploma' => DsfrColors.blueFrance925,
  'disability' => DsfrColors.blueCumulus950,
  'health' => DsfrColors.purpleGlycine950,
  'childcare' => DsfrColors.pinkTuile925,
  'no-device' => DsfrColors.greenTilleulVerveine950,
  _ => DsfrColors.blueCumulus950,
};
