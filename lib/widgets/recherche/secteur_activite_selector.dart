import 'package:flutter/material.dart';
import 'package:pass_emploi_app/analytics/ignore_tracking_context_provider.dart';
import 'package:pass_emploi_app/models/evenement_emploi/secteur_activite.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';
import 'package:pass_emploi_app/widgets/recherche/secteur_activite_selection_page.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/utils/read_only_text_form_field.dart';

const _heroTag = 'secteur-activite';

class SecteurActiviteSelector extends StatefulWidget {
  final Function(SecteurActivite? secteur) onSecteurActiviteSelected;
  final SecteurActivite? initialValue;

  const SecteurActiviteSelector({
    required this.onSecteurActiviteSelected,
    this.initialValue,
  });

  @override
  State<SecteurActiviteSelector> createState() => _SecteurActiviteSelectorState();
}

class _SecteurActiviteSelectorState extends State<SecteurActiviteSelector> {
  SecteurActivite? _selectedSecteurActivite;
  final GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    _selectedSecteurActivite = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedSecteurActivite != null;
    return ReadOnlyTextFormField(
      key: globalKey,
      title: Strings.secteurActiviteLabel,
      hint: Strings.secteurActiviteHint,
      heroTag: _heroTag,
      textFormFieldKey: Key(_selectedSecteurActivite?.name ?? 'all'),
      withDeleteButton: hasSelection,
      a11ySuppressionLabel: Strings.secteurActiviteAll,
      initialValue: hasSelection ? _selectedSecteurActivite!.label : Strings.secteurActiviteAll,
      onTextTap: () => Navigator.push(
        IgnoreTrackingContext.of(context).nonTrackingContext,
        SecteurActiviteSelectionPage.materialPageRoute(initialValue: _selectedSecteurActivite),
      ).then((secteur) => _updateSecteurActivite(secteur)),
      onDeleteTap: () => _updateSecteurActivite(null),
    );
  }

  void _updateSecteurActivite(SecteurActivite? secteur) {
    setState(() => _selectedSecteurActivite = secteur);
    widget.onSecteurActiviteSelected(secteur);
    globalKey.requestFocusDelayed(duration: const Duration(milliseconds: 300));
  }
}
