import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/poc_widgets.dart';

class MetiersListePage extends StatefulWidget {
  const MetiersListePage({super.key, required this.titre, this.intro, required this.charger});

  final String titre;
  final String? intro;
  final Future<List<PocMetierAffiche>> Function() charger;

  static Route<void> route({
    required String titre,
    String? intro,
    required Future<List<PocMetierAffiche>> Function() charger,
  }) {
    return MaterialPageRoute(builder: (_) => MetiersListePage(titre: titre, intro: intro, charger: charger));
  }

  @override
  State<MetiersListePage> createState() => _MetiersListePageState();
}

class _MetiersListePageState extends State<MetiersListePage> {
  late Future<List<PocMetierAffiche>> _metiers = widget.charger();

  @override
  Widget build(BuildContext context) {
    return PocScaffold(
      titre: widget.titre,
      body: ListView(
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        children: [
          if (widget.intro case final intro?) ...[
            Text(intro, style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context))),
            const SizedBox(height: DsfrSpacings.s2w),
          ],
          PocFuture<List<PocMetierAffiche>>(
            future: _metiers,
            onRetry: () => setState(() => _metiers = widget.charger()),
            builder: (context, metiers) => PocListeMetiers(metiers: metiers),
          ),
          const SizedBox(height: DsfrSpacings.s3w),
          PocMention(PocOrientationStrings.sourceRome),
        ],
      ),
    );
  }
}
