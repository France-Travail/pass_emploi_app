import 'package:equatable/equatable.dart';

class OnboardingStepsVisibility {
  final bool withMessageStep;
  final bool withPlanActionStep;
  final bool withActionStep;

  const OnboardingStepsVisibility({
    required this.withMessageStep,
    required this.withPlanActionStep,
    required this.withActionStep,
  });
}

class Onboarding extends Equatable {
  final bool _showAccueilOnboardingLegacy;

  final bool showNotificationsOnboarding;
  final bool showOnboarding;

  final bool messageCompleted;
  final bool planActionCompleted;
  final bool actionCompleted;
  final bool offreCompleted;
  final bool evenementCompleted;
  final bool outilsCompleted;

  Onboarding({
    bool showAccueilOnboardingLegacy = true,
    bool? showNotificationsOnboarding,
    bool? showOnboarding,
    this.messageCompleted = false,
    this.planActionCompleted = false,
    this.actionCompleted = false,
    this.offreCompleted = false,
    this.evenementCompleted = false,
    this.outilsCompleted = false,
  })  : _showAccueilOnboardingLegacy = showAccueilOnboardingLegacy,
        showNotificationsOnboarding = showAccueilOnboardingLegacy ? (showNotificationsOnboarding ?? true) : false,
        showOnboarding = showAccueilOnboardingLegacy ? (showOnboarding ?? true) : false;

  factory Onboarding.initial() {
    return Onboarding();
  }

  @override
  List<Object?> get props => [
        _showAccueilOnboardingLegacy,
        showNotificationsOnboarding,
        showOnboarding,
        messageCompleted,
        planActionCompleted,
        actionCompleted,
        offreCompleted,
        evenementCompleted,
        outilsCompleted,
      ];

  factory Onboarding.fromJson(Map<String, dynamic> json) {
    final showAccueilOnboarding = json['showAccueilOnboarding'] as bool? ?? true;

    return Onboarding(
      showAccueilOnboardingLegacy: showAccueilOnboarding,
      showNotificationsOnboarding: json['showNotificationsOnboarding'] as bool?,
      showOnboarding: json['showOnboarding'] as bool?,
      messageCompleted: json['messageCompleted'] as bool? ?? false,
      planActionCompleted: json['planActionCompleted'] as bool? ?? false,
      actionCompleted: json['actionCompleted'] as bool? ?? false,
      offreCompleted: json['offreCompleted'] as bool? ?? false,
      evenementCompleted: json['evenementCompleted'] as bool? ?? false,
      outilsCompleted: json['outilsCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showAccueilOnboarding': _showAccueilOnboardingLegacy,
      'showNotificationsOnboarding': showNotificationsOnboarding,
      'showOnboarding': showOnboarding,
      'messageCompleted': messageCompleted,
      'planActionCompleted': planActionCompleted,
      'actionCompleted': actionCompleted,
      'offreCompleted': offreCompleted,
      'evenementCompleted': evenementCompleted,
      'outilsCompleted': outilsCompleted,
    };
  }

  Onboarding copyWith({
    bool? showNotificationsOnboarding,
    bool? showOnboarding,
    bool? messageCompleted,
    bool? planActionCompleted,
    bool? actionCompleted,
    bool? offreCompleted,
    bool? evenementCompleted,
    bool? outilsCompleted,
  }) {
    return Onboarding(
      showAccueilOnboardingLegacy: _showAccueilOnboardingLegacy,
      showNotificationsOnboarding: showNotificationsOnboarding ?? this.showNotificationsOnboarding,
      showOnboarding: showOnboarding ?? this.showOnboarding,
      messageCompleted: messageCompleted ?? this.messageCompleted,
      planActionCompleted: planActionCompleted ?? this.planActionCompleted,
      actionCompleted: actionCompleted ?? this.actionCompleted,
      offreCompleted: offreCompleted ?? this.offreCompleted,
      evenementCompleted: evenementCompleted ?? this.evenementCompleted,
      outilsCompleted: outilsCompleted ?? this.outilsCompleted,
    );
  }

  bool isCompleted(OnboardingStepsVisibility visibility) {
    return (!visibility.withMessageStep || messageCompleted) &&
        (!visibility.withPlanActionStep || planActionCompleted) &&
        (!visibility.withActionStep || actionCompleted) &&
        offreCompleted &&
        evenementCompleted;
  }
}

extension OnboardingExtension on Onboarding {
  int completedSteps(OnboardingStepsVisibility visibility) =>
      [
        if (visibility.withMessageStep) messageCompleted,
        if (visibility.withPlanActionStep) planActionCompleted,
        if (visibility.withActionStep) actionCompleted,
        offreCompleted,
        evenementCompleted,
      ].where((step) => step).length +
      1;

  int totalSteps(OnboardingStepsVisibility visibility) =>
      3 +
      (visibility.withMessageStep ? 1 : 0) +
      (visibility.withPlanActionStep ? 1 : 0) +
      (visibility.withActionStep ? 1 : 0);
}
