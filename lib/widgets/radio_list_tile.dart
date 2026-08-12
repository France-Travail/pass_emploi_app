import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';

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
    return Padding(
      padding: const EdgeInsets.only(bottom: DsfrSpacings.s1w),
      child: DsfrRadioButton<T>(
        label: title,
        value: value,
        groupValue: groupValue,
        size: DsfrComponentSize.md,
        onChanged: onChanged,
      ),
    );
  }
}
