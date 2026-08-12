import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/presentation/checkbox_value_view_model.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/widgets/help_tooltip.dart';

// ignore_for_file: strict_raw_type
class CheckBoxGroup<T> extends StatefulWidget {
  final String title;
  final List<CheckboxValueViewModel<T>> options;
  final void Function(List<CheckboxValueViewModel> selectedOptions) onSelectedOptionsUpdated;
  final EdgeInsetsGeometry? contentPadding;

  const CheckBoxGroup({
    super.key,
    required this.title,
    required this.options,
    required this.onSelectedOptionsUpdated,
    this.contentPadding,
  });

  @override
  CheckBoxGroupState<CheckboxValueViewModel<T>> createState() => CheckBoxGroupState();
}

class CheckBoxGroupState<T extends CheckboxValueViewModel> extends State<CheckBoxGroup> {
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
            style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        Padding(
          padding: widget.contentPadding ?? EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _optionsSelectionStatus.entries
                .map<Widget>((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: DsfrSpacings.s2w),
                      child: _createCheckBox(context, entry.key, entry.value),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _createCheckBox(BuildContext context, T viewModel, bool isSelected) {
    final label = viewModel.label;
    final helpText = viewModel.helpText;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DsfrCheckbox(
            label: label,
            size: DsfrComponentSize.md,
            value: isSelected,
            onChanged: (value) {
              setState(() {
                _optionsSelectionStatus[viewModel] = value;
                widget.onSelectedOptionsUpdated(_listOfSelectedOptions());
              });
            },
          ),
        ),
        if (helpText != null) ...[
          const SizedBox(width: DsfrSpacings.s1w),
          HelpTooltip(
            message: helpText,
            icon: AppIcons.info_rounded,
          ),
        ],
      ],
    );
  }

  List<T> _listOfSelectedOptions() =>
      _optionsSelectionStatus.entries.where((element) => element.value).map((e) => e.key).toList();
}
