import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/profil/conseiller_profil_page_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_profil_tile.dart';

class MonConseillerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ConseillerProfilePageViewModel>(
      converter: (store) => ConseillerProfilePageViewModel.create(store),
      builder: (BuildContext context, ConseillerProfilePageViewModel vm) => _build(context, vm),
      distinct: true,
    );
  }

  Widget _build(BuildContext context, ConseillerProfilePageViewModel vm) {
    final displayState = vm.displayState;
    if (displayState == DisplayState.CONTENT) {
      return DsfrProfilTile(
        icon: DsfrIcons.userUserLine,
        iconBackgroundColor: DsfrColors.blueCumulus950,
        title: vm.name,
        description: A11yUtils.withScreenReader(context) ? vm.subtitleA11y : vm.subtitle,
      );
    } else if (displayState == DisplayState.LOADING) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: Margins.spacing_m),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return const SizedBox.shrink();
  }
}
