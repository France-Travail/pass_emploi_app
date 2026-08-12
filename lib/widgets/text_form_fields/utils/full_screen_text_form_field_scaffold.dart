import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';

class FullScreenTextFormFieldScaffold extends StatelessWidget {
  const FullScreenTextFormFieldScaffold({super.key, required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      resizeToAvoidBottomInset: true,
      // Required to delegate top padding to system
      appBar: AppBar(
        toolbarHeight: 0,
        scrolledUnderElevation: 0,
        backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      ),
      body: body,
    );
  }
}
