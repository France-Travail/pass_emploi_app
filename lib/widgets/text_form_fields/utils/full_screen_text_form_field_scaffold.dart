import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';

class FullScreenTextFormFieldScaffold extends Scaffold {
  FullScreenTextFormFieldScaffold({required Widget body})
    : super(
        backgroundColor: AppColors.bg,
        resizeToAvoidBottomInset: true,
        // Required to delegate top padding to system
        appBar: AppBar(toolbarHeight: 0, scrolledUnderElevation: 0),
        body: body,
      );
}
