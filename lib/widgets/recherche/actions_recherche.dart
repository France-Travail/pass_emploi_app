import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/presentation/recherche/actions_recherche_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/bottom_sheets.dart';
import 'package:redux/redux.dart';

class ActionsRecherche extends StatelessWidget {
  final ActionsRechercheViewModel Function(Store<AppState> store) buildViewModel;
  final Widget? Function() buildAlertBottomSheet;
  final bool Function(AppState) hasResults;

  ActionsRecherche({
    required this.buildViewModel,
    required this.buildAlertBottomSheet,
    required this.hasResults,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) {
        final viewModel = buildViewModel(store);
        return _ViewModel(
          show: viewModel.withAlertButton && hasResults(store.state),
        );
      },
      distinct: true,
      builder: _builder,
    );
  }

  Widget _builder(BuildContext context, _ViewModel viewModel) {
    if (!viewModel.show) return const SizedBox.shrink();

    final horizontalPadding = DsfrSpacings.s2w;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width - (horizontalPadding * 2),
        child: DsfrButton(
          label: Strings.createAlert,
          icon: DsfrIcons.mediaNotification3Line,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: () => _onAlertButtonPressed(context),
        ),
      ),
    );
  }

  void _onAlertButtonPressed(BuildContext context) {
    final sheet = buildAlertBottomSheet();
    if (sheet == null) return;
    showPassEmploiBottomSheet(context: context, builder: (_) => sheet);
  }
}

class _ViewModel {
  final bool show;

  const _ViewModel({required this.show});

  @override
  bool operator ==(Object other) => other is _ViewModel && other.show == show;

  @override
  int get hashCode => show.hashCode;
}
