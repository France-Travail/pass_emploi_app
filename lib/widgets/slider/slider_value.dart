import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';

class SliderValue extends StatelessWidget {
  final int value;

  const SliderValue({required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(Strings.searchRadius, style: TextStyles.textSRegular()),
        Text(Strings.kmFormat(value), style: TextStyles.textBaseBold),
      ],
    );
  }
}