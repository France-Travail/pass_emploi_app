import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';

enum OffreDetailsSectionTitleSize { headline4, headline5, headline6 }

class OffreDetailsSectionTitle extends StatelessWidget {
  const OffreDetailsSectionTitle(
    this.label, {
    super.key,
    this.size = OffreDetailsSectionTitleSize.headline4,
  });

  final String label;
  final OffreDetailsSectionTitleSize size;

  @override
  Widget build(BuildContext context) {
    final color = DsfrColorDecisions.textTitleGrey(context);
    final style = switch (size) {
      OffreDetailsSectionTitleSize.headline4 => DsfrTextStyle.headline4(color: color),
      OffreDetailsSectionTitleSize.headline5 => DsfrTextStyle.headline5(color: color),
      OffreDetailsSectionTitleSize.headline6 => DsfrTextStyle.headline6(color: color),
    };
    return Semantics(
      header: true,
      child: Text(label, style: style),
    );
  }
}
