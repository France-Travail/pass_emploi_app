import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class DateToggle extends StatelessWidget {
  final Function(bool) onIsActiveChange;
  final bool isActiveDate;

  DateToggle({required this.onIsActiveChange, required this.isActiveDate});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: Strings.startDateEnabled(isActiveDate),
      child: DsfrToggleSwitch(
        label: Strings.startDate,
        value: isActiveDate,
        status: isActiveDate ? Strings.yes : Strings.no,
        onChanged: onIsActiveChange,
      ),
    );
  }
}
