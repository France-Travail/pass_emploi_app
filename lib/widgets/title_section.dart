import 'package:flutter/cupertino.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/widgets/sepline.dart';

class TitleSection extends StatelessWidget {
  final String label;

  const TitleSection({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(label, style: TextStyles.textMBold),
            )
          ],
        ),
        SepLine(10, 0),
      ],
    );
  }
}
