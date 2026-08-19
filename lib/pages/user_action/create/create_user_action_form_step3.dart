import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/models/user_action_type.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_form_step2.dart';
import 'package:pass_emploi_app/presentation/model/date_input_source.dart';
import 'package:pass_emploi_app/presentation/user_action/creation_form/create_user_action_form_view_model.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/date_extensions.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_date_input_suggestions.dart';

class CreateUserActionFormStep3 extends StatelessWidget {
  const CreateUserActionFormStep3({
    required this.actionType,
    required this.titleSource,
    required this.viewModel,
    required this.onDateChanged,
    required this.onDescriptionChanged,
    required this.onDelete,
    required this.onAddDuplicatedUserAction,
  });

  final UserActionReferentielType actionType;
  final CreateActionTitleSource titleSource;
  final CreateUserActionStep3ViewModel viewModel;
  final void Function(String id, DateInputSource dateSource) onDateChanged;
  final void Function(String id, String description) onDescriptionChanged;
  final void Function(String id) onDelete;
  final void Function() onAddDuplicatedUserAction;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Tracker(
        tracking: AnalyticsScreenNames.createUserActionStep3,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: DsfrSpacings.s2w),
              Text(
                actionType.label,
                style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
              Text(
                titleSource.title,
                style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
              const SizedBox(height: DsfrSpacings.s2w),
              Text(
                Strings.allMandatoryFields,
                style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textMentionGrey(context)),
              ),
              const SizedBox(height: DsfrSpacings.s2w),
              Text(
                titleSource.allowBatchCreate ? Strings.selectMultipleActions : Strings.selectOneAction,
                style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
              if (viewModel.errorsVisible && !viewModel.isValid) ...[
                const SizedBox(height: DsfrSpacings.s2w),
                DsfrAlert(
                  type: DsfrAlertType.error,
                  description: DsfrAlertDescriptionText(Strings.fillAllFields),
                ),
              ],
              const SizedBox(height: DsfrSpacings.s3w),
              _DuplicateUserActionList(
                viewModel: viewModel,
                onDateChanged: onDateChanged,
                onDescriptionChanged: onDescriptionChanged,
                onDelete: onDelete,
                titleSource: titleSource,
              ),
              if (titleSource.allowBatchCreate)
                SizedBox(
                  width: double.infinity,
                  child: DsfrButton(
                    icon: DsfrIcons.systemAddLine,
                    label: Strings.duplicateAction,
                    variant: DsfrButtonVariant.secondary,
                    size: DsfrComponentSize.md,
                    onPressed: viewModel.canCreateMoreDuplicatedUserActions
                        ? () {
                            onAddDuplicatedUserAction.call();
                            PassEmploiMatomoTracker.instance.trackEvent(
                              eventCategory: AnalyticsEventNames.createActionv2EventCategory,
                              action: AnalyticsEventNames.createActionResultMultipleAction,
                            );
                          }
                        : null,
                  ),
                ),
              const SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }
}

class _DuplicateUserActionList extends StatelessWidget {
  const _DuplicateUserActionList({
    required this.viewModel,
    required this.onDateChanged,
    required this.onDescriptionChanged,
    required this.onDelete,
    required this.titleSource,
  });

  final CreateUserActionStep3ViewModel viewModel;
  final void Function(String id, DateInputSource dateSource) onDateChanged;
  final void Function(String id, String description) onDescriptionChanged;
  final void Function(String id) onDelete;
  final CreateActionTitleSource titleSource;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < viewModel.duplicatedUserActions.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: DsfrSpacings.s3w),
            child: _DuplicateUserActionItem(
              key: ValueKey(viewModel.duplicatedUserActions[index].id),
              duplicatedUserAction: viewModel.duplicatedUserActions[index],
              onDateChanged: (dateSource) => onDateChanged(viewModel.duplicatedUserActions[index].id, dateSource),
              onDescriptionChanged: (description) =>
                  onDescriptionChanged(viewModel.duplicatedUserActions[index].id, description),
              onDelete: () => onDelete(viewModel.duplicatedUserActions[index].id),
              index: index,
              titleSource: titleSource,
              errorsVisible: viewModel.errorsVisible,
            ),
          ),
      ],
    );
  }
}

class _DuplicateUserActionItem extends StatefulWidget {
  const _DuplicateUserActionItem({
    super.key,
    required this.duplicatedUserAction,
    required this.onDateChanged,
    required this.onDescriptionChanged,
    required this.onDelete,
    required this.index,
    required this.titleSource,
    required this.errorsVisible,
  });

  final DuplicatedUserAction duplicatedUserAction;
  final void Function(DateInputSource dateSource) onDateChanged;
  final void Function(String description) onDescriptionChanged;
  final void Function() onDelete;
  final int index;
  final CreateActionTitleSource titleSource;
  final bool errorsVisible;

  @override
  State<_DuplicateUserActionItem> createState() => _DuplicateUserActionItemState();
}

class _DuplicateUserActionItemState extends State<_DuplicateUserActionItem> {
  late final TextEditingController descriptionController;
  late final TextEditingController dateController;
  late final FocusNode descriptionFocusNode;
  final GlobalKey _descriptionFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController(text: widget.duplicatedUserAction.description);
    dateController = TextEditingController(text: _dateText(widget.duplicatedUserAction.dateSource));
    descriptionFocusNode = FocusNode();
    descriptionFocusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _DuplicateUserActionItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextDateText = _dateText(widget.duplicatedUserAction.dateSource);
    if (dateController.text != nextDateText) {
      dateController.text = nextDateText;
    }
  }

  @override
  void dispose() {
    descriptionFocusNode.removeListener(_onFocusChange);
    descriptionController.dispose();
    dateController.dispose();
    descriptionFocusNode.dispose();
    super.dispose();
  }

  String _dateText(DateInputSource dateSource) {
    return dateSource.isValid ? dateSource.selectedDate.toDay() : '';
  }

  void _onFocusChange() {
    if (descriptionFocusNode.hasFocus) {
      _scrollToDescriptionField();
    }
  }

  void _scrollToDescriptionField() {
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final fieldContext = _descriptionFieldKey.currentContext;
      if (fieldContext == null || !fieldContext.mounted) return;
      Scrollable.ensureVisible(
        fieldContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final showDescriptionError = widget.errorsVisible && !widget.duplicatedUserAction.isDescriptionValid;
    final showDateError = widget.errorsVisible && !widget.duplicatedUserAction.isDateValid;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: DsfrColorDecisions.backgroundDefaultGrey(context),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            border: Border.all(color: DsfrColorDecisions.artworkDecorativeBlueFrance(context)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(DsfrSpacings.s1w, DsfrSpacings.s2w, DsfrSpacings.s1w, DsfrSpacings.s2w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DsfrDateInput(
                  label: Strings.datePickerTitle,
                  controller: dateController,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2101),
                  initialDate: widget.duplicatedUserAction.dateSource.isValid
                      ? widget.duplicatedUserAction.dateSource.selectedDate
                      : DateTime.now(),
                  locale: const Locale('fr', 'FR'),
                  composantState: showDateError
                      ? DsfrComponentState.error(errorMessage: Strings.dateMandatory)
                      : const DsfrComponentState.none(),
                  onChanged: (date) => widget.onDateChanged(DateFromPicker(date)),
                ),
                const SizedBox(height: DsfrSpacings.s1w),
                DsfrDateSuggestions(
                  dateSource: widget.duplicatedUserAction.dateSource,
                  onSelected: widget.onDateChanged,
                ),
                AnimatedSize(
                  duration: AnimationDurations.fast,
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  child: widget.duplicatedUserAction.dateSource.isNone
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            const SizedBox(height: DsfrSpacings.s2w),
                            UserActionDescriptionField(
                              key: _descriptionFieldKey,
                              descriptionController: descriptionController,
                              onDescriptionChanged: (value) => widget.onDescriptionChanged(value),
                              onClear: () {
                                descriptionController.clear();
                                widget.onDescriptionChanged("");
                              },
                              hintText: Strings.exampleHint + widget.titleSource.descriptionHint,
                              descriptionFocusNode: descriptionFocusNode,
                              isInvalid: showDescriptionError,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
        if (widget.index > 0)
          Align(
            alignment: Alignment.topRight,
            child: DsfrButton(
              icon: DsfrIcons.systemCloseLine,
              iconSemanticLabel: Strings.deleteDuplicatedAction,
              variant: DsfrButtonVariant.tertiaryWithoutBorder,
              size: DsfrComponentSize.sm,
              onPressed: widget.onDelete,
            ),
          ),
      ],
    );
  }
}
