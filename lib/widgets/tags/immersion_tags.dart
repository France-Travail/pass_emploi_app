import 'package:flutter/material.dart';
import 'package:pass_emploi_app/models/immersion_details.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/tags/data_tag.dart';

class ImmersionTags extends StatelessWidget {
  final String secteurActivite;
  final String ville;
  final ImmersionModeDistanciel? modeDistanciel;

  ImmersionTags({required this.secteurActivite, required this.ville, this.modeDistanciel}) : super();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Margins.spacing_s,
      runSpacing: Margins.spacing_s,
      children: [
        DataTag.location(ville),
        DataTag(label: secteurActivite),
        if (modeDistanciel != null) DataTag(label: _modeDistancielLabel(modeDistanciel!)),
      ],
    );
  }

  String _modeDistancielLabel(ImmersionModeDistanciel mode) {
    return switch (mode) {
      ImmersionModeDistanciel.FULL_REMOTE => Strings.modeDistancielFullRemote,
      ImmersionModeDistanciel.HYBRID => Strings.modeDistancielHybrid,
      ImmersionModeDistanciel.ON_SITE => Strings.modeDistancielOnSite,
    };
  }
}
