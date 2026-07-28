import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_actions.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class OnboardingQuestionnaireLoaderStep extends StatefulWidget {
  const OnboardingQuestionnaireLoaderStep({super.key, required this.answers});

  final OnboardingQuestionnaireAnswers answers;

  @override
  State<OnboardingQuestionnaireLoaderStep> createState() => _OnboardingQuestionnaireLoaderStepState();
}

class _OnboardingQuestionnaireLoaderStepState extends State<OnboardingQuestionnaireLoaderStep> {
  bool _dispatched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dispatched) return;
    _dispatched = true;
    StoreProvider.of<AppState>(context).dispatch(OnboardingQuestionnaireCompleteAction(widget.answers));
  }

  @override
  Widget build(BuildContext context) {
    final answers = widget.answers;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Margins.spacing_base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Margins.spacing_base),
          ExcludeSemantics(
            child: Center(
              child: SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        color: DsfrColorDecisions.backgroundActiveBlueFrance(context),
                        backgroundColor: DsfrColorDecisions.backgroundContrastGrey(context),
                      ),
                    ),
                    const Text('🎯', style: TextStyle(fontSize: 28)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: Margins.spacing_base),
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
                                    label: Strings.onboardingQuestionnaireLoaderObjectifsCount(answers.objectifs.length),
                                    size: DsfrComponentSize.sm,
                                  ),
                                if (answers.freins.isNotEmpty)
                                  DsfrTag(
                                    label: Strings.onboardingQuestionnaireLoaderContraintesCount(answers.freins.length),
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
          _LoaderProgressLine(label: Strings.onboardingQuestionnaireLoaderStepBuild, done: false, inProgress: true),
          _LoaderProgressLine(label: Strings.onboardingQuestionnaireLoaderStepOrder, done: false),
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
  const _LoaderProgressLine({
    required this.label,
    required this.done,
    this.inProgress = false,
  });

  final String label;
  final bool done;
  final bool inProgress;

  @override
  Widget build(BuildContext context) {
    final textColor = done || inProgress
        ? DsfrColorDecisions.textTitleGrey(context)
        : DsfrColorDecisions.textDisabledGrey(context);
    final iconColor = done || inProgress
        ? DsfrColorDecisions.backgroundActiveBlueFrance(context)
        : DsfrColorDecisions.textDisabledGrey(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            done ? Icons.check : (inProgress ? Icons.schedule : Icons.circle_outlined),
            size: 20,
            color: iconColor,
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
