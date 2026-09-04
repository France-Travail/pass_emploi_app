import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class CustomRadioGroup<T> extends StatelessWidget {
  const CustomRadioGroup({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });
  final String title;
  final T value;
  final T? groupValue;
  final void Function(T?) onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return Padding(
      padding: const EdgeInsets.only(bottom: DsfrSpacings.s1w),
      child: Semantics(
        button: true,
        selected: isSelected,
        label: '${isSelected ? Strings.selectedRadioButton : Strings.unselectedRadioButton} : $title',
        child: InkWell(
          onTap: () => onChanged(value),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ExcludeSemantics(
                child: IgnorePointer(
                  child: DsfrRadioButton<T>(
                    label: title,
                    value: value,
                    groupValue: groupValue,
                    size: DsfrComponentSize.md,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
