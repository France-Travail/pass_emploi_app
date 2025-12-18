import 'package:flutter/material.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_form/create_demarche_form_change_notifier.dart';

class AppBarBackButton extends StatelessWidget {
  const AppBarBackButton(this.viewModel);
  final CreateDemarcheFormChangeNotifier viewModel;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: viewModel.shouldPop ? () => Navigator.pop(context) : () => viewModel.onNavigateBackward(),
      icon: viewModel.shouldPop ? Icon(Icons.close_rounded) : Icon(Icons.arrow_back_rounded),
    );
  }
}
