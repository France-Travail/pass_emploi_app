import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_state.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_actions.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class OnboardingQuestionnaireLoaderStep extends StatefulWidget {
  const OnboardingQuestionnaireLoaderStep({super.key, required this.answers});

  final OnboardingQuestionnaireAnswers answers;

  @override
  State<OnboardingQuestionnaireLoaderStep> createState() => _OnboardingQuestionnaireLoaderStepState();
}

class _OnboardingQuestionnaireLoaderStepState extends State<OnboardingQuestionnaireLoaderStep>
    with SingleTickerProviderStateMixin {
  static const _maxFakeProgress = 0.95;
  static const _timeConstantSeconds = 2.5;
  static const _tickInterval = Duration(milliseconds: 50);

  bool _dispatched = false;
  bool _completionStarted = false;
  bool _seenNonTerminalState = false;
  double _progress = 0;
  DateTime? _startedAt;
  Timer? _tickTimer;
  AnimationController? _completeController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dispatched) return;
    _dispatched = true;
    _startedAt = DateTime.now();
    _tickTimer = Timer.periodic(_tickInterval, (_) => _onTick());
    StoreProvider.of<AppState>(context).dispatch(OnboardingQuestionnaireCompleteAction(widget.answers));
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _completeController?.dispose();
    super.dispose();
  }

  void _onTick() {
    if (!mounted || _completionStarted) return;
    final actionPlanState = StoreProvider.of<AppState>(context, listen: false).state.actionPlanState;
    if (!_isGenerationDone(actionPlanState)) {
      _seenNonTerminalState = true;
    } else if (_seenNonTerminalState) {
      _completeToFull();
      return;
    }
    final startedAt = _startedAt;
    if (startedAt == null) return;
    final t = DateTime.now().difference(startedAt).inMilliseconds / 1000.0;
    final next = _maxFakeProgress * (1 - math.exp(-t / _timeConstantSeconds));
    if ((next - _progress).abs() < 0.001) return;
    setState(() => _progress = next);
  }

  bool _isGenerationDone(ActionPlanState state) {
    return state is ActionPlanSuccessState || state is ActionPlanEmptyState || state is ActionPlanFailureState;
  }

  Future<void> _completeToFull() async {
    if (_completionStarted) return;
    _completionStarted = true;
    _tickTimer?.cancel();

    final controller = AnimationController(vsync: this, duration: AnimationDurations.medium);
    _completeController = controller;
    final animation = Tween<double>(begin: _progress, end: 1).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );
    animation.addListener(() {
      if (!mounted) return;
      setState(() => _progress = animation.value);
    });
    await controller.forward();
    if (!mounted) return;

    await Future<void>.delayed(AnimationDurations.medium);
    if (!mounted) return;
    StoreProvider.of<AppState>(context).dispatch(OnboardingQuestionnaireFinishAction(widget.answers));
  }

  @override
  Widget build(BuildContext context) {
    final answers = widget.answers;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Margins.spacing_base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Margins.spacing_m),
          Text(
            Strings.onboardingQuestionnaireLoaderTitle,
            textAlign: TextAlign.center,
            style: DsfrTextStyle.bodyXlBold(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
          const SizedBox(height: Margins.spacing_s),
          Text(
            Strings.onboardingQuestionnaireLoaderSubtitle,
            textAlign: TextAlign.center,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
          ),
          const SizedBox(height: Margins.spacing_base),
          _LoaderProgressBar(progress: _progress),
          const SizedBox(height: Margins.spacing_base),
          DecoratedBox(
            decoration: BoxDecoration(
              color: DsfrColorDecisions.backgroundContrastGrey(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 4, color: DsfrColorDecisions.borderDefaultBlueFrance(context)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(Margins.spacing_base),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Strings.onboardingQuestionnaireLoaderProfil,
                            style: DsfrTextStyle.bodyXlBold(color: DsfrColorDecisions.textTitleGrey(context)),
                          ),
                          const SizedBox(height: Margins.spacing_s),
                          if (answers.prenom != null)
                            _ProfilRow(label: Strings.onboardingQuestionnaireLoaderPrenom, value: answers.prenom!),
                          if (answers.situation != null)
                            _ProfilRow(
                              label: Strings.onboardingQuestionnaireLoaderSituation,
                              value: answers.situation!.label,
                            ),
                          if (answers.domaine != null && answers.domaine!.isNotEmpty)
                            _ProfilRow(label: Strings.onboardingQuestionnaireLoaderDomaine, value: answers.domaine!),
                          if (answers.villeRecherche != null)
                            _ProfilRow(
                              label: Strings.onboardingQuestionnaireLoaderZone,
                              value: Strings.onboardingQuestionnaireLoaderZoneValue(
                                answers.villeRecherche!.nom,
                                answers.rayonKm,
                              ),
                            ),
                          if (answers.objectifs.isNotEmpty || answers.freins.isNotEmpty) ...[
                            const SizedBox(height: Margins.spacing_s),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (answers.objectifs.isNotEmpty)
                                  DsfrTag(
                                    backgroundColor: DsfrColorDecisions.backgroundContrastGrey(context),
                                    textColor: DsfrColorDecisions.textTitleGrey(context),
                                    label: Strings.onboardingQuestionnaireLoaderObjectifsCount(
                                      answers.objectifs.length,
                                    ),
                                    size: DsfrComponentSize.sm,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Margins.spacing_l),
          _LoaderProgressLine(label: Strings.onboardingQuestionnaireLoaderStepRead, done: true),
          _LoaderProgressLine(label: Strings.onboardingQuestionnaireLoaderStepSolutions, done: true),
          _LoaderProgressLine(label: Strings.onboardingQuestionnaireLoaderStepBuild, done: false),
          _LoaderProgressLine(label: Strings.onboardingQuestionnaireLoaderStepOrder, done: false),
        ],
      ),
    );
  }
}

class _LoaderProgressBar extends StatelessWidget {
  const _LoaderProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final percent = (progress.clamp(0.0, 1.0) * 100).round();
    final trackColor = DsfrColorDecisions.backgroundDefaultGrey(context);
    final activeColor = DsfrColorDecisions.backgroundActiveBlueFrance(context);
    final borderColor = DsfrColorDecisions.borderActionHighBlueFrance(context);
    final mentionColor = DsfrColorDecisions.textMentionGrey(context);

    return Semantics(
      label: Strings.onboardingQuestionnaireLoaderProgression,
      value: Strings.onboardingQuestionnaireLoaderProgressPercent(percent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Strings.onboardingQuestionnaireLoaderProgression,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textLabelGrey(context)),
          ),
          const SizedBox(height: Margins.spacing_xs),
          SizedBox(
            height: 24,
            child: Center(
              child: SizedBox(
                height: 12,
                width: double.infinity,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final fillWidth = width * progress.clamp(0.0, 1.0);
                    return Stack(
                      alignment: Alignment.centerLeft,
                      clipBehavior: Clip.none,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: trackColor,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: borderColor),
                          ),
                          child: const SizedBox.expand(),
                        ),
                        if (fillWidth > 0)
                          SizedBox(
                            width: fillWidth,
                            height: 12,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: activeColor,
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                        ...List.generate(5, (index) {
                          final ratio = index / 4;
                          final isActive = ratio <= progress;
                          final size = isActive ? 4.0 : 2.0;
                          final left = (width * ratio) - size / 2;
                          return Positioned(
                            left: left.clamp(0, width - size),
                            child: Container(
                              width: size,
                              height: size,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive ? trackColor : activeColor,
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: Margins.spacing_s),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0%', style: DsfrTextStyle.bodyXs(color: mentionColor)),
                Text('100%', style: DsfrTextStyle.bodyXs(color: mentionColor)),
              ],
            ),
          ),
          const SizedBox(height: Margins.spacing_s),
          Center(
            child: DsfrBadge(
              label: Strings.onboardingQuestionnaireLoaderProgressPercent(percent),
              type: DsfrBadgeType.information,
              size: DsfrComponentSize.md,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilRow extends StatelessWidget {
  const _ProfilRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoaderProgressLine extends StatelessWidget {
  const _LoaderProgressLine({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final textColor = done ? DsfrColorDecisions.textTitleGrey(context) : DsfrColorDecisions.textDisabledGrey(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            done ? Icons.check : Icons.schedule,
            size: 20,
            color: textColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: DsfrTextStyle.bodyMd(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
