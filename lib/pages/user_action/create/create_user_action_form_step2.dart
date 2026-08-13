import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/models/user_action_type.dart';
import 'package:pass_emploi_app/presentation/user_action/creation_form/create_user_action_form_view_model.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:speech_to_text/speech_to_text.dart';

class CreateUserActionFormStep2 extends StatefulWidget {
  final UserActionReferentielType actionType;
  final CreateUserActionStep2ViewModel viewModel;
  final void Function(CreateActionTitleSource) onTitleChanged;
  final void Function(String) onDescriptionChanged;

  CreateUserActionFormStep2({
    required this.actionType,
    required this.viewModel,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
  });

  @override
  State<CreateUserActionFormStep2> createState() => _CreateUserActionFormStep2State();
}

class _CreateUserActionFormStep2State extends State<CreateUserActionFormStep2> {
  late final TextEditingController titleController;

  @override
  void initState() {
    titleController = TextEditingController(text: widget.viewModel.titleSource.title);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Tracker(
        tracking: AnalyticsScreenNames.createUserActionStep2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: DsfrSpacings.s2w),
              Semantics(
                label: Strings.mandatoryField,
                child: Text(
                  Strings.userActionSubtitleStep2,
                  style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
                ),
              ),
              const SizedBox(height: DsfrSpacings.s1v),
              Text(
                Strings.mandatoryField,
                style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textMentionGrey(context)),
              ),
              const SizedBox(height: DsfrSpacings.s2w),
              _SuggestionTagWrap(
                titleSource: widget.viewModel.titleSource,
                onSelected: (value) => widget.onTitleChanged(value),
                actionType: widget.actionType,
              ),
              if (widget.viewModel.titleSource.isFromUserInput) ...[
                const SizedBox(height: DsfrSpacings.s3w),
                Semantics(
                  label: Strings.mandatoryField,
                  child: DsfrInput(
                    key: widget.viewModel.titleInputKey,
                    label: Strings.userActionTitleTextfieldStep2,
                    controller: titleController,
                    // Avoid maxLength: broken DSFR UI, see https://github.com/Octo-Open-Source/flutter-dsfr/issues/150
                    inputFormatters: [LengthLimitingTextInputFormatter(60)],
                    onChanged: (value) => widget.onTitleChanged(CreateActionTitleFromUserInput(value)),
                  ),
                ),
              ],
              const SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionTagWrap extends StatelessWidget {
  final void Function(CreateActionTitleSource) onSelected;
  final CreateActionTitleSource titleSource;
  final UserActionReferentielType actionType;

  const _SuggestionTagWrap({
    required this.titleSource,
    required this.onSelected,
    required this.actionType,
  });

  @override
  Widget build(BuildContext context) {
    final List<UserActionCategory> suggestionList = actionType.suggestionList;
    return Wrap(
      // DsfrTag réserve ~8px à droite pour le checkmark : spacing 0 pour un gap visuel égal au runSpacing.
      spacing: 0,
      runSpacing: DsfrSpacings.s1w,
      children: switch (titleSource) {
        CreateActionTitleNotInitialized() => [
          ...suggestionList.map(
            (suggestion) => DsfrTag(
              label: suggestion.value,
              size: DsfrComponentSize.md,
              isSelected: false,
              onSelectionChanged: (_) => onSelected(CreateActionTitleFromSuggestions(suggestion)),
            ),
          ),
          DsfrTag(
            label: Strings.userActionOther,
            size: DsfrComponentSize.md,
            isSelected: false,
            onSelectionChanged: (_) => onSelected(CreateActionTitleFromUserInput('')),
          ),
        ],
        CreateActionTitleFromSuggestions() => [
          DsfrTag(
            label: titleSource.title,
            size: DsfrComponentSize.md,
            isSelected: true,
            onSelectionChanged: (selected) {
              if (!selected) onSelected(CreateActionTitleNotInitialized());
            },
          ),
        ],
        CreateActionTitleFromUserInput() => [
          DsfrTag(
            label: Strings.userActionOther,
            size: DsfrComponentSize.md,
            isSelected: true,
            onSelectionChanged: (selected) {
              if (!selected) onSelected(CreateActionTitleNotInitialized());
            },
          ),
        ],
      },
    );
  }
}

class UserActionDescriptionField extends StatefulWidget {
  const UserActionDescriptionField({
    super.key,
    this.descriptionKey,
    required this.descriptionController,
    required this.onDescriptionChanged,
    required this.onClear,
    required this.hintText,
    this.descriptionFocusNode,
    required this.isInvalid,
  });

  final Key? descriptionKey;
  final FocusNode? descriptionFocusNode;
  final TextEditingController descriptionController;
  final void Function(String) onDescriptionChanged;
  final void Function() onClear;
  final String? hintText;
  final bool isInvalid;

  @override
  State<UserActionDescriptionField> createState() => _UserActionDescriptionFieldState();
}

class _UserActionDescriptionFieldState extends State<UserActionDescriptionField> {
  static const int _maxLength = 1024;

  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    widget.descriptionController.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant UserActionDescriptionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.descriptionController != widget.descriptionController) {
      oldWidget.descriptionController.removeListener(_onControllerChanged);
      widget.descriptionController.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.descriptionController.removeListener(_onControllerChanged);
    _speechToText.stop();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _startListening() async {
    PassEmploiMatomoTracker.instance.trackEvent(
      eventCategory: AnalyticsEventNames.createActionEventCategory,
      action: AnalyticsEventNames.createUserActionDescriptionDicterPressed,
    );
    setState(() => _errorText = null);

    final bool available = await _speechToText.initialize(
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _errorText = Strings.genericError;
        });
      },
    );
    if (!mounted) return;

    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (result) {
          if (!mounted) return;

          final recognized = result.recognizedWords;
          final clamped = recognized.length > _maxLength ? recognized.substring(0, _maxLength) : recognized;

          widget.descriptionController.value = widget.descriptionController.value.copyWith(
            text: clamped,
            selection: TextSelection.collapsed(offset: clamped.length),
            composing: TextRange.empty,
          );
          widget.onDescriptionChanged(clamped);

          if (recognized.length >= _maxLength) _stopListening();
        },
      );
    }
  }

  void _stopListening() {
    _speechToText.stop();
    if (!mounted) return;
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = _errorText ?? (widget.isInvalid ? Strings.descriptionMandatory : null);
    return Semantics(
      container: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: DsfrInput(
              key: widget.descriptionKey,
              label: Strings.userActionDescriptionTextfieldStep2,
              hintText: Strings.userActionDescriptionDescriptionfieldStep2,
              placeholder: widget.hintText,
              controller: widget.descriptionController,
              focusNode: widget.descriptionFocusNode,
              minLines: 3,
              maxLines: 5,
              // Avoid maxLength: broken DSFR UI, see https://github.com/Octo-Open-Source/flutter-dsfr/issues/150
              inputFormatters: [LengthLimitingTextInputFormatter(_maxLength)],
              componentState: errorMessage != null
                  ? DsfrComponentState.error(errorMessage: errorMessage)
                  : const DsfrComponentState.none(),
              onChanged: (value) {
                setState(() => _errorText = null);
                widget.onDescriptionChanged(value);
              },
            ),
          ),
          const SizedBox(width: DsfrSpacings.s1w),
          Column(
            children: [
              if (widget.descriptionController.text.isNotEmpty)
                DsfrButton(
                  icon: DsfrIcons.systemCloseLine,
                  iconSemanticLabel: Strings.clear,
                  variant: DsfrButtonVariant.tertiaryWithoutBorder,
                  size: DsfrComponentSize.md,
                  onPressed: widget.onClear,
                ),
              DsfrButton(
                icon: _isListening ? DsfrIcons.mediaStopCircleFill : DsfrIcons.mediaMicFill,
                iconSemanticLabel: _isListening ? Strings.dictationStop : Strings.dictationStart,
                variant: DsfrButtonVariant.primary,
                size: DsfrComponentSize.md,
                onPressed: () {
                  if (_isListening) {
                    _stopListening();
                  } else {
                    _startListening();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
