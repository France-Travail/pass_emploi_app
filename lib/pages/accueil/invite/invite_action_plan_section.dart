import 'package:flutter/foundation.dart';
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
    required this.onToggleDone,
    required this.onDelete,
  });

  final ActionPlan? plan;
  final void Function(String actionId) onToggleDone;
  final void Function(String actionId) onDelete;

  @override
  Widget build(BuildContext context) {
    final objectives = (plan?.objectives ?? const <ActionPlanObjective>[])
        .where((objective) => objective.actions.isNotEmpty)
        .toList();
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
              padding: const EdgeInsets.symmetric(
                horizontal: Margins.spacing_base,
                vertical: Margins.spacing_s,
              ),
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
                      style: DsfrTextStyle.bodyMdMedium(
                        color: DsfrColorDecisions.textTitleBlueFrance(context),
                      ),
                    ),
                  ),
                  DsfrBadge(
                    label: Strings.inviteAccueilProgressBadge(
                      objective.doneCount,
                      objective.totalCount,
                    ),
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
                      color: DsfrColorDecisions.textActionHighBlueFrance(
                        context,
                      ),
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
            padding: const EdgeInsets.fromLTRB(
              Margins.spacing_s,
              0,
              Margins.spacing_s,
              Margins.spacing_s,
            ),
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
        border: Border.all(
          color: DsfrColorDecisions.borderDefaultGrey(context),
        ),
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
                      padding: const EdgeInsets.only(
                        right: Margins.spacing_base,
                      ),
                      child: DsfrCheckboxIcon(
                        value: action.done,
                        size: DsfrComponentSize.md,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.label,
                        style: DsfrTextStyle.bodyMd(
                          color: DsfrColorDecisions.textLabelGrey(context),
                        ),
                      ),
                      if (action.serviceName != null)
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                action.serviceName!,
                                style:
                                    DsfrTextStyle.bodySm(
                                      color: DsfrColorDecisions.textActionHighBlueFrance(
                                        context,
                                      ),
                                    ).copyWith(
                                      decoration: _hasLink ? TextDecoration.underline : null,
                                      decorationColor: _hasLink
                                          ? DsfrColorDecisions.textActionHighBlueFrance(
                                              context,
                                            )
                                          : null,
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
                                  color: DsfrColorDecisions.textActionHighBlueFrance(
                                    context,
                                  ),
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
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        emoji,
        style: TextStyle(
          fontSize: 24,
          // Force color emoji on iOS for dingbats like ✈️ (U+2708).
          fontFamily: defaultTargetPlatform == TargetPlatform.iOS ? 'Apple Color Emoji' : null,
        ),
      ),
    );
  }
}

// Emojis/colors mirror QuestionnaireObjectif / QuestionnaireFrein themes
// returned by the plan-action API (GoalDto / ObstacleDto codes).
String _emojiForTheme(String theme) => switch (theme) {
  // Goals
  'ORIENTER' => '🧭',
  'DECOUVRIR_METIERS' => '🔎',
  'FORMER' => '📚',
  'STAGE_IMMERSION' => '👀',
  'ALTERNANCE' => '🔧',
  'EMPLOI' => '💼',
  'ENGAGER' => '🤝',
  'MOBILITE_INTERNATIONALE' => '✈️',
  'ACCOMPAGNE' => '🧰',
  'CREER_ACTIVITE' => '🚀',
  'VIE_QUOTIDIENNE' => '🍿',
  // Obstacles
  'PAS_DE_PERMIS' => '🚗',
  'PAS_DE_TRANSPORT' => '🚌',
  'PAS_DE_LOGEMENT' => '🏠',
  'MANQUE_CONFIANCE' => '😟',
  'FIN_DE_MOIS' => '💶',
  'PAS_DE_DIPLOME' => '🎓',
  'PEU_EXPERIENCE' => '💼',
  'HANDICAP' => '♿',
  'SANTE' => '🩺',
  'GARDE_ENFANT' => '👶',
  'NUMERIQUE' => '💻',
  'FRANCAIS' => '🗣️',
  'RIEN_NE_ME_BLOQUE' => '✅',
  _ => '🎯',
};

Color _colorForTheme(String theme) => switch (theme) {
  // Goals
  'ORIENTER' => DsfrColors.pinkTuile950,
  'DECOUVRIR_METIERS' => DsfrColors.greenTilleulVerveine950,
  'FORMER' => DsfrColors.purpleGlycine950,
  'STAGE_IMMERSION' => DsfrColors.greenArchipel950,
  'ALTERNANCE' => DsfrColors.blueEcume950,
  'EMPLOI' => DsfrColors.greenEmeraude975,
  'ENGAGER' => DsfrColors.yellowTournesol950,
  'MOBILITE_INTERNATIONALE' => DsfrColors.purpleGlycine950,
  'ACCOMPAGNE' => DsfrColors.yellowMoutarde950,
  'CREER_ACTIVITE' => DsfrColors.greenBourgeon975,
  'VIE_QUOTIDIENNE' => DsfrColors.pinkTuile950,
  // Obstacles
  'PAS_DE_PERMIS' => DsfrColors.greenTilleulVerveine950,
  'PAS_DE_TRANSPORT' => DsfrColors.blueFrance950,
  'PAS_DE_LOGEMENT' => DsfrColors.greenEmeraude950,
  'MANQUE_CONFIANCE' => DsfrColors.warning950,
  'FIN_DE_MOIS' => DsfrColors.brownCafeCreme925,
  'PAS_DE_DIPLOME' => DsfrColors.beigeGrisGaletMain702Active,
  'PEU_EXPERIENCE' => DsfrColors.success950,
  'HANDICAP' => DsfrColors.greenMenthe950,
  'SANTE' => DsfrColors.purpleGlycine925,
  'GARDE_ENFANT' => DsfrColors.blueEcume925,
  'NUMERIQUE' => DsfrColors.yellowMoutarde950,
  'FRANCAIS' => DsfrColors.greenEmeraude925,
  'RIEN_NE_ME_BLOQUE' => DsfrColors.purpleGlycine950,
  _ => DsfrColors.blueCumulus950,
};
