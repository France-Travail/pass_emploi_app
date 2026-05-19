import 'package:flutter/widgets.dart';
import 'package:pass_emploi_app/models/commentaire.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';

class Comment extends StatelessWidget {
  final Commentaire comment;

  Comment({required this.comment});

  @override
  Widget build(BuildContext context) {
    final creatorName = comment.createdByAdvisor ? Strings.createdByAdvisor(comment.creatorName ?? "") : Strings.you;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(creatorName, style: TextStyles.textBaseMediumBold(color: context.content))),
            Text("  ·  ", style: TextStyles.textBaseMediumBold(color: context.content)),
            Text(comment.getDayDate() ?? "", style: TextStyles.textBaseRegular.copyWith(color: context.content)),
          ],
        ),
        SizedBox(height: Margins.spacing_base),
        Text(comment.content, style: TextStyles.textBaseRegular.copyWith(color: context.content)),
      ],
    );
  }
}
