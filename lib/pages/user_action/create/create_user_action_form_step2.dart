import 'package:flutter/material.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/models/user_action_type.dart';
import 'package:pass_emploi_app/pages/user_action/create/widgets/user_action_stepper.dart';
import 'package:pass_emploi_app/presentation/user_action/creation_form/create_user_action_form_view_model.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/widgets/pass_emploi_chip.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/base_text_form_field.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Margins.spacing_base),
              Semantics(
                container: true,
                header: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserActionStepperTexts(index: 2),
                    const SizedBox(height: Margins.spacing_s),
                    Text(
                      widget.actionType.label,
                      style: TextStyles.textMBold.copyWith(color: AppColors.contentColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Margins.spacing_m),
              Semantics(
                label: Strings.mandatoryField,
                child: Text(
                  Strings.userActionSubtitleStep2,
                  style: TextStyles.textBaseBold,
                ),
              ),
              const SizedBox(height: Margins.spacing_base),
              _SuggestionTagWrap(
                titleSource: widget.viewModel.titleSource,
                onSelected: (value) => widget.onTitleChanged(value),
                actionType: widget.actionType,
              ),
              if (widget.viewModel.titleSource.isFromUserInput) ...[
                const SizedBox(height: Margins.spacing_m),
                Semantics(
                  label: Strings.mandatoryField,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Strings.userActionTitleTextfieldStep2,
                        style: TextStyles.textBaseBold,
                      ),
                      const SizedBox(height: Margins.spacing_s),
                      BaseTextField(
                        controller: titleController,
                        maxLength: 60,
                        maxLines: 1,
                        onChanged: (value) => widget.onTitleChanged(CreateActionTitleFromUserInput(value)),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 600),
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
      spacing: Margins.spacing_s,
      runSpacing: Margins.spacing_s,
      children: switch (titleSource) {
        CreateActionTitleNotInitialized() => [
          ...suggestionList.map(
            (suggestion) => PassEmploiChip<UserActionCategory>(
              label: suggestion.value,
              value: suggestion,
              isSelected: false,
              onTagSelected: (value) => onSelected(CreateActionTitleFromSuggestions(value)),
              onTagDeleted: () => onSelected(CreateActionTitleNotInitialized()),
            ),
          ),
          PassEmploiChip<String>(
            label: Strings.userActionOther,
            value: '',
            isSelected: false,
            onTagSelected: (value) => onSelected(CreateActionTitleFromUserInput(value)),
            onTagDeleted: () => onSelected(CreateActionTitleNotInitialized()),
          ),
        ],
        CreateActionTitleFromSuggestions() => [
          PassEmploiChip<String>(
            label: titleSource.title,
            value: titleSource.title,
            isSelected: true,
            onTagSelected: (value) => onSelected(CreateActionTitleFromUserInput(value)),
            onTagDeleted: () => onSelected(CreateActionTitleNotInitialized()),
          ),
        ],
        CreateActionTitleFromUserInput() => [
          PassEmploiChip<String>(
            label: Strings.userActionOther,
            value: '',
            isSelected: true,
            onTagSelected: (value) => onSelected(CreateActionTitleFromUserInput(value)),
            onTagDeleted: () => onSelected(CreateActionTitleNotInitialized()),
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
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Strings.userActionDescriptionTextfieldStep2,
            key: widget.descriptionKey,
            style: TextStyles.textBaseBold,
          ),
          const SizedBox(height: Margins.spacing_s),
          Text(
            Strings.userActionDescriptionDescriptionfieldStep2,
            style: TextStyles.textSRegular(),
          ),
          const SizedBox(height: Margins.spacing_base),
          Stack(
            children: [
              Stack(
                children: [
                  BaseTextField(
                    focusNode: widget.descriptionFocusNode,
                    controller: widget.descriptionController,
                    hintText: widget.hintText,
                    maxLines: 5,
                    minLines: 1,
                    maxLength: _maxLength,
                    errorText: _errorText,
                    onChanged: (value) {
                      setState(() => _errorText = null);
                      widget.onDescriptionChanged(value);
                    },
                    isInvalid: widget.isInvalid,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Opacity(
                          opacity: widget.descriptionController.text.isNotEmpty ? 1.0 : 0.0,
                          child: Row(
                            children: [
                              IconButton(
                                tooltip: Strings.clear,
                                icon: Icon(Icons.clear),
                                onPressed: widget.onClear,
                              ),
                              SizedBox(
                                height: 28.0,
                                child: VerticalDivider(
                                  color: AppColors.grey500,
                                  thickness: 1,
                                  width: 1,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          tooltip: _isListening ? Strings.dictationStop : Strings.dictationStart,
                          onPressed: () {
                            if (_isListening) {
                              _stopListening();
                            } else {
                              _startListening();
                            }
                          },
                          icon: Container(
                            padding: EdgeInsets.all(2),
                            child: Icon(
                              _isListening ? Icons.stop_circle_rounded : Icons.mic,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
