import 'package:flutter/material.dart';
import 'package:pass_emploi_app/models/immersion_contact.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/cards/base_cards/widgets/card_tag.dart';

class ContactModeTag extends StatelessWidget {
  const ContactModeTag({super.key, required this.contactMode});
  final ImmersionContactMode contactMode;

  @override
  Widget build(BuildContext context) {
    return switch (contactMode) {
      ImmersionContactMode.MAIL => CardTag(
        icon: AppIcons.mail,
        text: Strings.contactByMail,
        backgroundColor: AppColors.additional5Lighten,
        contentColor: context.content,
        backgroundDarkColor: AppColors.additional5Darken,
        contentDarkColor: AppColors.contentDark,
      ),
      ImmersionContactMode.PHONE => CardTag(
        icon: AppIcons.phone,
        backgroundColor: AppColors.additional5Lighten,
        text: Strings.contactByPhone,
        contentColor: context.content,
        backgroundDarkColor: AppColors.additional5Darken,
        contentDarkColor: AppColors.contentDark,
      ),
      ImmersionContactMode.PRESENTIEL => CardTag(
        icon: AppIcons.place_outlined,
        backgroundColor: AppColors.additional5Lighten,
        text: Strings.contactByPresen,
        contentColor: context.content,
        backgroundDarkColor: AppColors.additional5Darken,
        contentDarkColor: AppColors.contentDark,
      ),
      ImmersionContactMode.INCONNU => SizedBox.shrink(),
    };
  }
}
