import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class FavoriNotFoundError extends StatelessWidget {
  const FavoriNotFoundError({super.key});

  @override
  Widget build(BuildContext context) {
    return DsfrAlert(
      type: DsfrAlertType.error,
      title: Strings.offreNotFoundError,
      description: DsfrAlertDescriptionText(Strings.offreNotFoundExplaination),
    );
  }
}
