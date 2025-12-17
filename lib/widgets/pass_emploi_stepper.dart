import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';

class CreateDemarcheStepper extends StatelessWidget {
  const CreateDemarcheStepper({super.key, required this.stepCount, required this.currentStepIndex});
  final int stepCount;
  final int currentStepIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_base),
          child: PassEmploiStepperProgressBar(stepCount: stepCount, currentStep: currentStepIndex),
        ),
        SizedBox(height: Margins.spacing_xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_base),
          child: PassEmploiStepperTexts(stepCount: stepCount, currentStepIndex: currentStepIndex),
        ),
      ],
    );
  }
}

class PassEmploiStepperTexts extends StatelessWidget {
  const PassEmploiStepperTexts({super.key, required this.stepCount, required this.currentStepIndex});
  final int stepCount;
  final int currentStepIndex;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        // fix a11y to avoid getting the reader lost
        label: " ",
        child: AutoFocusA11y(
          child: Text(
            Strings.stepCounter(currentStepIndex + 1, stepCount),
            style: TextStyles.textSRegular(color: AppColors.contentColor),
          ),
        ),
      ),
    );
  }
}

class PassEmploiStepperProgressBar extends StatelessWidget {
  const PassEmploiStepperProgressBar({required this.stepCount, required this.currentStep, super.key});

  final int stepCount;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < stepCount; i++) ...[
          _AnimatedStepProgressIndicator(isActive: i <= currentStep, key: ValueKey(i)),
          if (i < stepCount - 1) const SizedBox(width: Margins.spacing_s),
        ],
      ],
    );
  }
}

class _AnimatedStepProgressIndicator extends StatelessWidget {
  const _AnimatedStepProgressIndicator({required this.isActive, super.key});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: isActive ? 1 : 0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        builder: (context, value, _) {
          return Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(2)),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
