import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';

class FullScreenTextFormFieldScaffold extends StatelessWidget {
  const FullScreenTextFormFieldScaffold({super.key, required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      resizeToAvoidBottomInset: true,
      // Required to delegate top padding to system
      appBar: AppBar(toolbarHeight: 0, scrolledUnderElevation: 0),
      body: body,
    );
  }
}
