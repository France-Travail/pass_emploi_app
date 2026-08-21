import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/presentation/chat/chat_item.dart';

class DeletedMessage extends StatelessWidget {
  const DeletedMessage(this.item);
  final DeletedMessageItem item;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: item.sender.isJeune ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: DsfrSpacings.s1w),
        padding: const EdgeInsets.symmetric(
          vertical: DsfrSpacings.s1w,
          horizontal: DsfrSpacings.s2w,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: DsfrColorDecisions.borderDefaultGrey(context)),
          borderRadius: BorderRadius.circular(DsfrSpacings.s1v),
        ),
        child: Text(
          item.content,
          style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
        ),
      ),
    );
  }
}
