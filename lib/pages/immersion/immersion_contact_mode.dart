import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/immersion_contact.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_card_semantics.dart';

class ContactModeTag extends StatelessWidget {
  const ContactModeTag({super.key, required this.contactMode});
  final ImmersionContactMode contactMode;

  @override
  Widget build(BuildContext context) {
    return switch (contactMode) {
      ImmersionContactMode.MAIL => DsfrCategoryTag.info(
          label: Strings.contactByMail,
          icon: DsfrIcons.businessMailFill,
        ),
      ImmersionContactMode.PHONE => DsfrCategoryTag.info(
          label: Strings.contactByPhone,
          icon: DsfrIcons.devicePhoneFill,
        ),
      ImmersionContactMode.PRESENTIEL => DsfrCategoryTag.info(
          label: Strings.contactByPresen,
          icon: DsfrIcons.mapMapPin2Fill,
        ),
      ImmersionContactMode.INCONNU => SizedBox.shrink(),
    };
  }
}
