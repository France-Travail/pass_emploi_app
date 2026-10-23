import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/soft_update/soft_update_actions.dart';
import 'package:pass_emploi_app/features/soft_update/soft_update_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/soft_update_bottom_sheet.dart';

/// Déclenche la vérification de la soft update au lancement de l'app et affiche la bottom sheet
/// quel que soit l'écran courant (login, accueil, etc.).
/// À placer sous le Navigator (dans le `home` du MaterialApp) pour pouvoir afficher la bottom sheet.
class SoftUpdateWrapper extends StatelessWidget {
  final Widget child;

  const SoftUpdateWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      onInit: (store) => store.dispatch(SoftUpdateCheckAction()),
      converter: (store) => store.state.softUpdateState is ShowSoftUpdateState,
      builder: (context, _) => child,
      onDidChange: (previous, shouldShow) {
        if (shouldShow && previous != true) SoftUpdateBottomSheet.show(context);
      },
      distinct: true,
    );
  }
}
