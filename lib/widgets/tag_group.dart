import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/presentation/checkbox_value_view_model.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';

// ignore_for_file: strict_raw_type
class TagGroup<T> extends StatefulWidget {
  final String title;
  final List<CheckboxValueViewModel<T>> options;
  final void Function(List<CheckboxValueViewModel> selectedOptions) onSelectedOptionsUpdated;

  const TagGroup({
    super.key,
    required this.title,
    required this.options,
    required this.onSelectedOptionsUpdated,
  });

  @override
  TagGroupState<CheckboxValueViewModel<T>> createState() => TagGroupState();
}

class TagGroupState<T extends CheckboxValueViewModel> extends State<TagGroup> {
  late Map<T, bool> _optionsSelectionStatus;

  @override
  void initState() {
    super.initState();
    _optionsSelectionStatus = Map.fromEntries(widget.options.map((e) => MapEntry(e as T, e.isInitiallyChecked)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          headingLevel: 2,
          child: Text(
            widget.title,
            style: DsfrTextStyle.bodyXlBold(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        Wrap(
          spacing: DsfrSpacings.s1w,
          runSpacing: DsfrSpacings.s1w,
          children: _optionsSelectionStatus.entries
              .map((entry) => _buildTag(context, entry.key, entry.value))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTag(BuildContext context, T viewModel, bool isSelected) {
    void onSelectionChanged(bool value) {
      setState(() {
        _optionsSelectionStatus[viewModel] = value;
        widget.onSelectedOptionsUpdated(_listOfSelectedOptions());
      });
    }

    // A11y 5.1 : DsfrTag n'expose qu'un état « sélectionné », sans rôle. Les filtres se cochent et se décochent :
    // chacun est restitué comme une case à cocher, avec son état et son aide. L'étiquette garde son apparence
    // et son focus clavier.
    return Builder(
      builder: (tagContext) => Semantics(
        container: true,
        // A11y 5.1 (iOS) : sans `enabled: true` explicite, VoiceOver annonce l'étiquette « estompé ».
        enabled: true,
        checked: isSelected,
        // A11y 9.6 : le nom reprend le titre du groupe, après le libellé visible.
        label: '${viewModel.label}, ${widget.title}',
        hint: viewModel.helpText,
        onTap: () {
          onSelectionChanged(!isSelected);
          // A11y 5.5 : sans cet évènement, TalkBack (avant Android 16) n'annonçait pas le nouvel état.
          A11yUtils.notifyTap(tagContext);
        },
        excludeSemantics: true,
        child: DsfrTag(
          label: viewModel.label,
          size: DsfrComponentSize.md,
          isSelected: isSelected,
          onSelectionChanged: onSelectionChanged,
        ),
      ),
    );
  }

  List<T> _listOfSelectedOptions() =>
      _optionsSelectionStatus.entries.where((element) => element.value).map((e) => e.key).toList();
}
