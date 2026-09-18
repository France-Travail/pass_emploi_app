import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/widgets/a11y/string_a11y_extensions.dart';

class ChatDaySection extends StatelessWidget {
  final String dayLabel;

  const ChatDaySection({required this.dayLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DsfrSpacings.s1v),
      child: Center(
        child: Semantics(
          header: true,
          child: Text(
            dayLabel,
            style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
            textAlign: TextAlign.center,
            semanticsLabel: dayLabel.toDateForScreenReaders(),
          ),
        ),
      ),
    );
  }
}
