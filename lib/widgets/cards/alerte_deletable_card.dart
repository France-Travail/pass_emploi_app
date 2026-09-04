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
  final AlerteCardTrackingSource trackingSource;

  AlerteDeletableCard({
    required this.title,
    required this.place,
    required this.offreType,
    required this.onTap,
    required this.onDelete,
    required this.trackingSource,
  });

  @override
  Widget build(BuildContext context) {
    return AlerteCardContent(
      title: _typeLabel(offreType),
      subtitle: _subtitle(title, place),
      onDelete: onDelete,
      onTap: onTap,
      trackingSource: trackingSource,
    );
  }
}

String _typeLabel(OffreType offreType) {
  return switch (offreType) {
    OffreType.emploi => Strings.offreTypeEmploiLabel,
    OffreType.alternance => Strings.alternanceTag,
    OffreType.immersion => Strings.immersionTag,
    OffreType.serviceCivique => Strings.serviceCiviqueTag,
  };
}

String _subtitle(String title, String? place) {
  if (place == null || place.isEmpty) return title;
  return '$title - $place';
}
