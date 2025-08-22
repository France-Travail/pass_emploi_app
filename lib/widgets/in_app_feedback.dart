import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/in_app_feedback/in_app_feedback_actions.dart';
import 'package:pass_emploi_app/features/module_feedback/module_feedback_actions.dart';
import 'package:pass_emploi_app/models/feedback_activation.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/media_sizes.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/base_text_form_field.dart';

enum _Feedback {
  feedback1(
    icon: AppIcons.mood_bad,
    semantics: Strings.moodBad,
    analyticsEvent: AnalyticsEventNames.feedback1Action,
  ),
  feedback2(
    icon: AppIcons.sentiment_dissatisfied,
    semantics: Strings.sentimentDissatisfied,
    analyticsEvent: AnalyticsEventNames.feedback2Action,
  ),
  feedback3(
    icon: AppIcons.sentiment_neutral,
    semantics: Strings.sentimentNeutral,
    analyticsEvent: AnalyticsEventNames.feedback3Action,
  ),
  feedback4(
    icon: AppIcons.sentiment_satisfied,
    semantics: Strings.sentimentSatisfied,
    analyticsEvent: AnalyticsEventNames.feedback4Action,
  ),
  feedback5(
    icon: AppIcons.mood,
    semantics: Strings.mood,
    analyticsEvent: AnalyticsEventNames.feedback5Action,
  );

  final IconData icon;
  final String semantics;
  final String analyticsEvent;

  const _Feedback({required this.icon, required this.semantics, required this.analyticsEvent});
}

enum _WidgetState {
  feedback,
  commentaire,
  thanks,
  closed,
}

class InAppFeedback extends StatefulWidget {
  final String feature;
  final String label;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  const InAppFeedback({
    required this.feature,
    required this.label,
    this.padding = EdgeInsets.zero,
    this.backgroundColor = AppColors.primaryLighten,
  });

  @override
  State<InAppFeedback> createState() => _InAppFeedbackState();
}

class _InAppFeedbackState extends State<InAppFeedback> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  bool _shouldDismiss = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationDurations.extraLong,
      vsync: this,
    )..forward(from: 0.3);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, FeedbackActivation?>(
      onInit: (store) => store.dispatch(InAppFeedbackRequestAction(widget.feature)),
      converter: (store) => store.state.inAppFeedbackState.feedbackActivationForFeatures[widget.feature],
      builder: _builder,
      onDispose: (store) {
        if (_shouldDismiss) store.dispatch(InAppFeedbackDismissAction(widget.feature));
      },
    );
  }

  Widget _builder(BuildContext context, FeedbackActivation? activation) {
    final display = activation?.isActivated ?? false;
    return switch (display) {
      true => AnimatedBuilder(
          animation: _animation,
          child: _InAppFeedbackWidget(
            feature: widget.feature,
            label: widget.label,
            padding: widget.padding,
            backgroundColor: widget.backgroundColor,
            commentaireEnabled: activation?.commentaireEnabled ?? false,
            onDismiss: () => _shouldDismiss = true,
          ),
          builder: (context, child) => Transform.scale(scale: _animation.value, child: child)),
      false => SizedBox.shrink(),
    };
  }
}

class _InAppFeedbackWidget extends StatefulWidget {
  final String feature;
  final String label;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final bool commentaireEnabled;
  final VoidCallback onDismiss;

  const _InAppFeedbackWidget({
    required this.feature,
    required this.label,
    required this.padding,
    required this.backgroundColor,
    required this.commentaireEnabled,
    required this.onDismiss,
  });

  @override
  State<_InAppFeedbackWidget> createState() => _InAppFeedbackWidgetState();
}

class _InAppFeedbackWidgetState extends State<_InAppFeedbackWidget> {
  _WidgetState state = _WidgetState.feedback;
  _Feedback? selectedFeedback;
  final TextEditingController _commentaireController = TextEditingController();

  @override
  void dispose() {
    _commentaireController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (selectedFeedback == null) return;

    final note = selectedFeedback!.index + 1;
    final commentaire = _commentaireController.text.trim();

    StoreProvider.of<AppState>(context).dispatch(ModuleFeedbackRequestAction(
      tag: widget.feature,
      note: note,
      commentaire: commentaire,
    ));

    setState(() => state = _WidgetState.thanks);
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AnimationDurations.medium3,
      switchInCurve: Curves.easeInBack,
      switchOutCurve: Curves.easeOutBack,
      transitionBuilder: (child, animation) => SizeTransition(sizeFactor: animation, child: child),
      child: switch (state) {
        _WidgetState.feedback => Padding(
            key: ValueKey<String>('${widget.feature}-0'),
            padding: widget.padding,
            child: Stack(
              children: [
                _BorderedContainer(
                  backgroundColor: widget.backgroundColor,
                  child: Column(
                    children: [
                      _Description(icon: AppIcons.help, label: widget.label),
                      SizedBox(height: Margins.spacing_m),
                      _FeedbackOptionsGroup(
                        backgroundColor: widget.backgroundColor,
                        tracking: widget.feature,
                        onOptionTap: (feedback) {
                          selectedFeedback = feedback;
                          if (widget.commentaireEnabled) {
                            setState(() => state = _WidgetState.commentaire);
                          } else {
                            _submitFeedback();
                          }
                          PassEmploiMatomoTracker.instance.trackEvent(
                            eventCategory: AnalyticsEventNames.feedbackCategory(widget.feature),
                            action: feedback.analyticsEvent,
                          );
                        },
                      ),
                      SizedBox(height: 12),
                      _FeedbackCaption(),
                      SizedBox(height: Margins.spacing_base),
                    ],
                  ),
                ),
                _CloseButton(onPressed: () {
                  setState(() => state = _WidgetState.closed);
                  PassEmploiMatomoTracker.instance
                      .trackScreen(AnalyticsScreenNames.inAppFeedbackFeatureFermeture(widget.feature));
                  widget.onDismiss();
                })
              ],
            ),
          ),
        _WidgetState.commentaire => Padding(
            key: ValueKey<String>('${widget.feature}-1'),
            padding: widget.padding,
            child: Stack(
              children: [
                _BorderedContainer(
                  backgroundColor: widget.backgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Description(label: Strings.feedbackCommentaire),
                      SizedBox(height: Margins.spacing_m),
                      BaseTextField(
                        controller: _commentaireController,
                        maxLength: 255,
                        maxLines: 3,
                      ),
                      SizedBox(height: Margins.spacing_base),
                      PrimaryActionButton(
                        onPressed: _submitFeedback,
                        label: Strings.submitFeedback,
                      ),
                    ],
                  ),
                ),
                _CloseButton(onPressed: () {
                  _submitFeedback();
                })
              ],
            ),
          ),
        _WidgetState.thanks => Padding(
            key: ValueKey<String>('${widget.feature}-2'),
            padding: widget.padding,
            child: _Thanks(
              backgroundColor: widget.backgroundColor,
              onPressed: () => setState(() => state = _WidgetState.closed),
            ),
          ),
        _WidgetState.closed => SizedBox.shrink(),
      },
    );
  }
}

class _Description extends StatelessWidget {
  final IconData? icon;
  final String label;

  const _Description({this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[Icon(icon, color: AppColors.primary), SizedBox(width: Margins.spacing_s)],
        Flexible(child: Text(label, style: TextStyles.textSBold)),
        // Extra margin is added to avoid the close button to be too close to the text
        SizedBox(width: 30),
      ],
    );
  }
}

class _FeedbackOptionsGroup extends StatelessWidget {
  final Color backgroundColor;
  final Function(_Feedback) onOptionTap;
  final String tracking;

  const _FeedbackOptionsGroup({required this.backgroundColor, required this.onOptionTap, required this.tracking});

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.inAppFeedbackFeature(tracking),
      child: Semantics(
        container: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _FeedbackOption(
              feedback: _Feedback.feedback1,
              backgroundColor: backgroundColor,
              onTap: () => onOptionTap(_Feedback.feedback1),
            ),
            _FeedbackOption(
              feedback: _Feedback.feedback2,
              backgroundColor: backgroundColor,
              onTap: () => onOptionTap(_Feedback.feedback2),
            ),
            _FeedbackOption(
              feedback: _Feedback.feedback3,
              backgroundColor: backgroundColor,
              onTap: () => onOptionTap(_Feedback.feedback3),
            ),
            _FeedbackOption(
              feedback: _Feedback.feedback4,
              backgroundColor: backgroundColor,
              onTap: () => onOptionTap(_Feedback.feedback4),
            ),
            _FeedbackOption(
              feedback: _Feedback.feedback5,
              backgroundColor: backgroundColor,
              onTap: () => onOptionTap(_Feedback.feedback5),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackOption extends StatelessWidget {
  final _Feedback feedback;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _FeedbackOption({
    required this.feedback,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: Semantics(
        label: feedback.semantics,
        button: true,
        child: Material(
          color: backgroundColor,
          clipBehavior: Clip.hardEdge,
          borderRadius: BorderRadius.circular(Dimens.radius_base),
          child: InkWell(
            splashColor: AppColors.primary,
            onTap: onTap,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimens.radius_base),
                border: Border.all(color: AppColors.primary),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_s, vertical: Margins.spacing_base),
                child: Icon(
                  feedback.icon,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackCaption extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final maxWidthForLargeTextScale = MediaQuery.of(context).size.width < MediaSizes.width_s ? 60.0 : 100.0;
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: maxWidthForLargeTextScale,
            child: Text(Strings.feedbackBad, style: TextStyles.textSMedium(color: AppColors.grey800)),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: maxWidthForLargeTextScale,
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(Strings.feedbackNeutral, style: TextStyles.textSMedium(color: AppColors.grey800)),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: SizedBox(
            width: maxWidthForLargeTextScale,
            child: Align(
              alignment: Alignment.topRight,
              child: Text(Strings.feedbackGood, style: TextStyles.textSMedium(color: AppColors.grey800)),
            ),
          ),
        ),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(Margins.spacing_xs),
        child: IconButton(
          icon: Icon(AppIcons.close_rounded),
          tooltip: Strings.close,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _Thanks extends StatelessWidget {
  final Color backgroundColor;
  final VoidCallback onPressed;

  const _Thanks({required this.backgroundColor, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _BorderedContainer(
          backgroundColor: backgroundColor,
          child: _Description(icon: AppIcons.check_circle_outline_rounded, label: Strings.feedbackThanks),
        ),
        _CloseButton(onPressed: onPressed),
      ],
    );
  }
}

class _BorderedContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const _BorderedContainer({required this.child, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(Dimens.radius_base),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Margins.spacing_base),
        child: child,
      ),
    );
  }
}
