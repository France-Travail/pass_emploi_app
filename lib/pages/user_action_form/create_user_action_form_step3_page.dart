import 'package:flutter/material.dart';
import 'package:pass_emploi_app/pages/user_action_form/form_state/create_user_action_form_state.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/widgets/date_pickers/date_picker.dart';
import 'package:pass_emploi_app/widgets/pass_emploi_chip.dart';

class CreateUserActionFormStep3 extends StatelessWidget {
  const CreateUserActionFormStep3({
    required this.state,
    required this.onStatusChanged,
    required this.withRappelChanged,
    required this.onDateChanged,
  });
  final CreateUserActionStep3State state;
  final void Function(bool) onStatusChanged;
  final void Function(bool) withRappelChanged;
  final void Function(CreateActionDateSource) onDateChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Margins.spacing_m),
        Text(Strings.allMandatoryFields, style: TextStyles.textSRegular()),
        const SizedBox(height: Margins.spacing_m),
        Text(Strings.user_action_status_radio_step_3, style: TextStyles.textBaseBold),
        const SizedBox(height: Margins.spacing_m),
        _ActionStatusRadios(isCompleted: state.estTerminee, onStatusChanged: onStatusChanged),
        const SizedBox(height: Margins.spacing_m),
        Text(Strings.user_action_date_step_3, style: TextStyles.textBaseBold),
        const SizedBox(height: Margins.spacing_m),
        DatePicker(
          onValueChange: (date) => onDateChanged(CreateActionDateFromUserInput(date)),
          initialDateValue: switch (state.date) {
            CreateActionDateNone() => null,
            CreateActionDateFromSuggestions() => (state.date as CreateActionDateFromSuggestions).date,
            CreateActionDateFromUserInput() => (state.date as CreateActionDateFromUserInput).date,
          },
          isActiveDate: true,
        ),
        const SizedBox(height: Margins.spacing_m),
        _DateSuggestions(
          dateSource: state.date,
          onSelected: onDateChanged,
        ),
        const SizedBox(height: Margins.spacing_m),
        _RappelsSwitcher(
          value: state.withRappel,
          isActive: state.shouldDisplayRappelNotification(),
          onChanged: (value) => withRappelChanged(value),
        )
      ],
    );
  }
}

class _ActionStatusRadios extends StatelessWidget {
  const _ActionStatusRadios({required this.isCompleted, required this.onStatusChanged});
  final bool isCompleted;
  final void Function(bool) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile<bool>(
          contentPadding: EdgeInsets.zero,
          title: Text(Strings.user_action_status_radio_completed_step_3),
          value: true,
          groupValue: isCompleted,
          onChanged: _onStatusChanged,
        ),
        RadioListTile<bool>(
          contentPadding: EdgeInsets.zero,
          title: Text(Strings.user_action_status_radio_todo_step_3),
          value: false,
          groupValue: isCompleted,
          onChanged: _onStatusChanged,
        ),
      ],
    );
  }

  void _onStatusChanged(bool? value) {
    if (value != null) onStatusChanged(value);
  }
}

class _DateSuggestions extends StatelessWidget {
  const _DateSuggestions({required this.onSelected, required this.dateSource});

  final void Function(CreateActionDateSource) onSelected;
  final CreateActionDateSource dateSource;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Margins.spacing_s,
      runSpacing: Margins.spacing_s,
      children: switch (dateSource) {
        CreateActionDateNone() => [
            PassEmploiChip<DateTime>(
              label: Strings.user_action_date_suggestion_1,
              value: DateTime.now(),
              isSelected: false,
              onTagSelected: (value) => onSelected(CreateActionDateFromSuggestions(
                value,
                Strings.user_action_date_suggestion_1,
              )),
              onTagDeleted: () => onSelected(CreateActionDateNone()),
            ),
            PassEmploiChip<DateTime>(
              label: Strings.user_action_date_suggestion_2,
              value: DateTime.now().add(Duration(days: 1)),
              isSelected: false,
              onTagSelected: (value) => onSelected(CreateActionDateFromSuggestions(
                value,
                Strings.user_action_date_suggestion_2,
              )),
              onTagDeleted: () => onSelected(CreateActionDateNone()),
            ),
            PassEmploiChip<DateTime>(
              label: Strings.user_action_date_suggestion_3,
              value: DateTime.now().add(Duration(days: 7)),
              isSelected: false,
              onTagSelected: (value) => onSelected(CreateActionDateFromSuggestions(
                value,
                Strings.user_action_date_suggestion_3,
              )),
              onTagDeleted: () => onSelected(CreateActionDateNone()),
            ),
          ],
        CreateActionDateFromSuggestions() => [
            PassEmploiChip<DateTime>(
              label: (dateSource as CreateActionDateFromSuggestions).label,
              value: DateTime.now().add(Duration(days: 7)),
              isSelected: true,
              onTagSelected: (_) {},
              onTagDeleted: () => onSelected(CreateActionDateNone()),
            ),
          ],
        CreateActionDateFromUserInput() => [],
      },
    );
  }
}

class _RappelsSwitcher extends StatelessWidget {
  final bool value;
  final bool isActive;
  final ValueChanged<bool> onChanged;

  const _RappelsSwitcher({required this.value, required this.isActive, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final textStyle = isActive ? TextStyles.textBaseRegular : TextStyles.textBaseRegularWithColor(AppColors.disabled);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Text(Strings.rappelSwitch, style: textStyle)),
        SizedBox(width: Margins.spacing_m),
        Switch(
          value: isActive && value,
          onChanged: isActive ? onChanged : null,
        ),
        SizedBox(width: Margins.spacing_xs),
        Text(isActive && value ? Strings.yes : Strings.no, style: textStyle),
      ],
    );
  }
}
