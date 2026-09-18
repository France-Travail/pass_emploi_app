import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/presentation/checkbox_value_view_model.dart';

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
          header: true,
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
    final tag = DsfrTag(
      label: viewModel.label,
      size: DsfrComponentSize.md,
      isSelected: isSelected,
      onSelectionChanged: (value) {
        setState(() {
          _optionsSelectionStatus[viewModel] = value;
          widget.onSelectedOptionsUpdated(_listOfSelectedOptions());
        });
      },
    );

    if (viewModel.helpText == null) return tag;

    return Semantics(
      hint: viewModel.helpText,
      child: tag,
    );
  }

  List<T> _listOfSelectedOptions() =>
      _optionsSelectionStatus.entries.where((element) => element.value).map((e) => e.key).toList();
}
