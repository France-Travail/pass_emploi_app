import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_tracking.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';
import 'package:pass_emploi_app/widgets/onboarding/onboarding_showcase.dart';

class InviteActionPlanSection extends StatelessWidget {
  const InviteActionPlanSection({
    super.key,
    required this.plan,
    required this.onToggleDone,
    required this.onDelete,
    this.onObjectiveExpanded,
  });

  final ActionPlan? plan;
  final void Function(String actionId) onToggleDone;
  final void Function(String actionId) onDelete;
  final VoidCallback? onObjectiveExpanded;

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
            onExpanded: onObjectiveExpanded,
            withShowcase: i == 0,
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
    this.onExpanded,
    this.withShowcase = false,
  });

  final ActionPlanObjective objective;
  final void Function(String actionId) onToggleDone;
  final void Function(String actionId) onDelete;
  final VoidCallback? onExpanded;
  final bool withShowcase;

  @override
  State<_ObjectiveAccordion> createState() => _ObjectiveAccordionState();
}

class _ObjectiveAccordionState extends State<_ObjectiveAccordion> {
  bool _expanded = false;
  bool _showAll = false;
  final GlobalKey _firstRevealedActionKey = GlobalKey();
  static const _initialVisible = 5;
  static const _animationCurve = Curves.ease;

  @override
  Widget build(BuildContext context) {
    final objective = widget.objective;
    final visibleActions = _showAll ? objective.actions : objective.actions.take(_initialVisible).toList();
    final hasMore = objective.actions.length > _initialVisible;

    void toggle() {
      final willExpand = !_expanded;
      setState(() => _expanded = willExpand);
      if (willExpand) widget.onExpanded?.call();
      ActionPlanTrackingEvent(
        willExpand
            ? AnalyticsEventNames.actionPlanObjectiveExpandedAction
            : AnalyticsEventNames.actionPlanObjectiveCollapsedAction,
        name: objective.theme,
        value: willExpand ? objective.totalCount : null,
      ).send();
    }

    // A11y : un seul nœud bouton, avec l'état déplié/replié et la progression explicitée.
    final header = Semantics(
      container: true,
      button: true,
      expanded: _expanded,
      label: '${objective.title}, ${Strings.inviteAccueilProgressA11y(objective.doneCount, objective.totalCount)}',
      onTap: toggle,
      excludeSemantics: true,
      child: InkWell(
        onTap: toggle,
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
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        widget.withShowcase
            ? OnboardingShowcase(
                source: ShowcaseSource.planAction,
                bottom: true,
                child: header,
              )
            : header,
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
                  for (var i = 0; i < visibleActions.length; i++) ...[
                    const SizedBox(height: Margins.spacing_s),
                    InviteActionPlanActionTile(
                      focusKey: _showAll && i == _initialVisible ? _firstRevealedActionKey : null,
                      action: visibleActions[i],
                      onToggleDone: () => widget.onToggleDone(visibleActions[i].id),
                      onDelete: () => widget.onDelete(visibleActions[i].id),
                    ),
                  ],
                  if (hasMore && !_showAll) ...[
                    const SizedBox(height: Margins.spacing_s),
                    DsfrButton(
                      label: Strings.inviteAccueilAfficherPlus,
                      variant: DsfrButtonVariant.secondary,
                      size: DsfrComponentSize.lg,
                      onPressed: () {
                        setState(() => _showAll = true);
                        // A11y 10.2 : placer le focus sur la première action nouvellement affichée.
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _firstRevealedActionKey.requestFocusDelayed(),
                        );
                        ActionPlanTrackingEvent(
                          AnalyticsEventNames.actionPlanShowMoreAction,
                          name: objective.theme,
                          value: objective.totalCount - _initialVisible,
                        ).send();
                      },
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
    this.focusKey,
  });

  final ActionPlanAction action;
  final VoidCallback onToggleDone;
  final VoidCallback onDelete;
  final GlobalKey? focusKey;

  void _delete() {
    onDelete();
    A11yUtils.announce(Strings.inviteAccueilActionDeletedA11y(action.label));
  }

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
          // A11y : l'action de lien est portée par le nœud « lien » dédié ci-dessous.
          excludeFromSemantics: true,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(Margins.spacing_base),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Semantics(
                  key: focusKey,
                  container: true,
                  // Sans `enabled: true` explicite, iOS annonce la case « estompé » (désactivée).
                  enabled: true,
                  checked: action.done,
                  label: action.label,
                  hint: _hasLink ? null : action.serviceName,
                  onTap: onToggleDone,
                  excludeSemantics: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onToggleDone,
                    // Zone tactile d'au moins 44 x 44.
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: 1,
                        child: DsfrCheckboxIcon(
                          value: action.done,
                          size: DsfrComponentSize.md,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Margins.spacing_xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // A11y : libellé déjà porté par la case à cocher.
                      ExcludeSemantics(
                        child: Text(
                          action.label,
                          style: DsfrTextStyle.bodyMd(
                            color: DsfrColorDecisions.textLabelGrey(context),
                          ),
                        ),
                      ),
                      if (_hasLink)
                        Semantics(
                          container: true,
                          link: true,
                          label: action.serviceName ?? action.label,
                          onTap: _openLink,
                          excludeSemantics: true,
                          child: _serviceName(context),
                        )
                      else if (action.serviceName != null)
                        ExcludeSemantics(child: _serviceName(context)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _delete,
                  tooltip: Strings.inviteAccueilDeleteActionA11y(action.label),
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

  Widget _serviceName(BuildContext context) {
    if (action.serviceName == null) return const SizedBox.shrink();
    return Row(
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
    );
  }

  void _openLink() {
    ActionPlanTrackingEvent(
      AnalyticsEventNames.actionPlanActionOpenedAction,
      name: [action.label, if (action.serviceName != null) action.serviceName].join(' | '),
    ).send();
    launchExternalUrl(action.url!);
  }
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
      // A11y : emoji décoratif.
      child: ExcludeSemantics(
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: 24,
            // Force color emoji on iOS for dingbats like ✈️ (U+2708).
            fontFamily: defaultTargetPlatform == TargetPlatform.iOS ? 'Apple Color Emoji' : null,
          ),
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
