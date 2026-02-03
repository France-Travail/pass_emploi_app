import 'package:flutter/material.dart';
import 'package:pass_emploi_app/models/offre_type.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/alerte_card.dart';

class AlerteDeletableCard extends StatelessWidget {
  final OffreType offreType;
  final String title;
  final String? place;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  AlerteDeletableCard({
    required this.title,
    required this.place,
    required this.offreType,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlerteCardContent(
      title: _buildAlerteTitle(_tagLabel(offreType)),
      subtitle: _buildAlerteSubtitle(title),
      onDelete: onDelete,
      onTap: onTap,
    );
  }
}

String _tagLabel(OffreType offreType) {
  return switch (offreType) {
    OffreType.emploi => Strings.emploiTag,
    OffreType.alternance => Strings.alternanceTag,
    OffreType.immersion => Strings.immersionTag,
    OffreType.serviceCivique => Strings.serviceCiviqueTag,
  };
}

String _buildAlerteTitle(String tagLabel) => "${Strings.alerte} $tagLabel";

String _buildAlerteSubtitle(String title) {
  return title;
}
