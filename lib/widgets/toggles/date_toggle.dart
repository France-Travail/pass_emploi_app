import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_accessible_toggle_switch.dart';

class DateToggle extends StatelessWidget {
  final Function(bool) onIsActiveChange;
  final bool isActiveDate;

  DateToggle({required this.onIsActiveChange, required this.isActiveDate});

  @override
  Widget build(BuildContext context) {
    return DsfrAccessibleToggleSwitch(
      semanticsLabel: Strings.startDateEnabled(isActiveDate),
      label: Strings.startDate,
      value: isActiveDate,
      status: isActiveDate ? Strings.yes : Strings.no,
      onChanged: onIsActiveChange,
    );
  }
}
