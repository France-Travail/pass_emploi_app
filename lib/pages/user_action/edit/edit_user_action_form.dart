import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/user_action_type.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_form_step1.dart';
import 'package:pass_emploi_app/pages/user_action/edit/edit_user_action_form_change_notifier.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_date_input_suggestions.dart';

class EditUserActionFormDto {
  final DateTime date;
  final String title;
  final String description;
  final UserActionReferentielType? type;

  EditUserActionFormDto({
    required this.date,
    required this.title,
    required this.description,
    required this.type,
  });

  EditUserActionFormChangeNotifier toChangeNotifier(bool requireUpdate) {
    return EditUserActionFormChangeNotifier(
      date: date,
      title: title,
      description: description,
      type: type,
      requireUpdate: requireUpdate,
    );
  }

  static EditUserActionFormDto fromChangeNotifier(EditUserActionFormChangeNotifier changeNotifier) {
    return EditUserActionFormDto(
      date: changeNotifier.dateInputSource.selectedDate,
      title: changeNotifier.title,
      description: changeNotifier.description,
      type: changeNotifier.type,
    );
  }
}

class EditUserActionForm extends StatefulWidget {
  const EditUserActionForm({
    required this.actionDto,
    required this.requireUpdate,
    required this.onSaved,
    required this.confirmationLabel,
  });

  final EditUserActionFormDto actionDto;
  final bool requireUpdate;
  final String confirmationLabel;
  final void Function(EditUserActionFormDto) onSaved;

  @override
  State<EditUserActionForm> createState() => _EditUserActionFormState();
}

class _EditUserActionFormState extends State<EditUserActionForm> {
  late final EditUserActionFormChangeNotifier _changeNotifier;
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _changeNotifier = widget.actionDto.toChangeNotifier(widget.requireUpdate);
    _listener = () {
      if (mounted) setState(() {});
    };
    _changeNotifier.addListener(_listener);
  }

  @override
  void dispose() {
    _changeNotifier.removeListener(_listener);
    _changeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(DsfrSpacings.s2w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  Strings.mandatoryFields,
                  style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textMentionGrey(context)),
                ),
                const SizedBox(height: DsfrSpacings.s2w),
                DsfrDateInputSuggestions(
                  label: Strings.datePickerTitleMandatory,
                  dateSource: _changeNotifier.dateInputSource,
                  onDateChanged: _changeNotifier.updateDate,
                ),
                const SizedBox(height: DsfrSpacings.s3w),
                DsfrInput(
                  label: Strings.updateUserActionTitle,
                  initialValue: _changeNotifier.title,
                  // Avoid maxLength: broken DSFR UI, see https://github.com/Octo-Open-Source/flutter-dsfr/issues/150
                  inputFormatters: [LengthLimitingTextInputFormatter(60)],
                  onChanged: _changeNotifier.updateTitle,
                ),
                const SizedBox(height: DsfrSpacings.s3w),
                DsfrInput(
                  label: Strings.updateUserActionDescriptionTitle,
                  hintText: Strings.updateUserActionDescriptionSubtitle,
                  initialValue: _changeNotifier.description,
                  minLines: 3,
                  maxLines: 5,
                  // Avoid maxLength: broken DSFR UI, see https://github.com/Octo-Open-Source/flutter-dsfr/issues/150
                  inputFormatters: [LengthLimitingTextInputFormatter(1024)],
                  onChanged: _changeNotifier.updateDescription,
                ),
                const SizedBox(height: DsfrSpacings.s3w),
                _CategorySelector(_changeNotifier),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DsfrSpacings.s2w,
            DsfrSpacings.s1w,
            DsfrSpacings.s2w,
            DsfrSpacings.s2w,
          ),
          child: SizedBox(
            width: double.infinity,
            child: DsfrButton(
              label: widget.confirmationLabel,
              variant: DsfrButtonVariant.primary,
              size: DsfrComponentSize.md,
              onPressed: _changeNotifier.canSave()
                  ? () => widget.onSaved(EditUserActionFormDto.fromChangeNotifier(_changeNotifier))
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector(this.changeNotifier);

  final EditUserActionFormChangeNotifier changeNotifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.updateUserActionCategory,
          style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textLabelGrey(context)),
        ),
        const SizedBox(height: DsfrSpacings.s1v),
        SizedBox(
          width: double.infinity,
          child: DsfrButton(
            label: changeNotifier.type?.label ?? Strings.userActionNoCategory,
            icon: DsfrIcons.systemArrowRightSLine,
            iconLocation: DsfrButtonIconLocation.right,
            variant: DsfrButtonVariant.secondary,
            size: DsfrComponentSize.md,
            onPressed: () => Navigator.of(context).push(_CategorySelectionPage.route()).then(changeNotifier.updateType),
          ),
        ),
      ],
    );
  }
}

class _CategorySelectionPage extends StatelessWidget {
  static MaterialPageRoute<UserActionReferentielType> route() {
    return MaterialPageRoute<UserActionReferentielType>(builder: (_) => _CategorySelectionPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      appBar: SecondaryAppBar(title: Strings.updateUserActionCategory),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DsfrSpacings.s2w),
          child: ActionCategorySelector(
            onActionSelected: (type) => Navigator.of(context).pop(type),
          ),
        ),
      ),
    );
  }
}
