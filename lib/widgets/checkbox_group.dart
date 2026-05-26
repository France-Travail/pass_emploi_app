import 'package:flutter/material.dart';
import 'package:pass_emploi_app/presentation/checkbox_value_view_model.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/shadows.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(widget.title, style: TextStyles.textBaseBold.copyWith(color: context.content)),
        ),
        SizedBox(height: Margins.spacing_base),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.bg,
            borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_base)),
            boxShadow: [Shadows.radius_base],
          ),
          child: Padding(
            padding: widget.contentPadding ?? const EdgeInsets.only(left: Margins.spacing_base),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _optionsSelectionStatus.entries
                  .map<Widget>((entry) => _createCheckBox(context, entry.key, entry.value))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _createCheckBox(BuildContext context, T viewModel, bool isSelected) {
    final label = viewModel.label;
    final helpText = viewModel.helpText;
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      title: helpText != null ? _textWithToolTip(context, label, helpText) : _title(context, label),
      value: isSelected,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.primary,
      checkColor: AppColors.contentOnPrimary,
      side: BorderSide(color: context.content, width: 2),
      onChanged: (value) {
        setState(() {
          if (value != null) {
            _optionsSelectionStatus[viewModel] = value;
            final listOfSelectedOptions = _listOfSelectedOptions();
            widget.onSelectedOptionsUpdated(listOfSelectedOptions);
          }
        });
      },
    );
  }

  Widget _textWithToolTip(BuildContext context, String label, String helpText) {
    return Row(
      children: [
        _title(context, label),
        SizedBox(width: Margins.spacing_s),
        HelpTooltip(
          message: helpText,
          icon: AppIcons.info_rounded,
        ),
      ],
    );
  }

  Widget _title(BuildContext context, String label) =>
      Text(label, style: TextStyles.textBaseRegular.copyWith(color: context.content));

  List<T> _listOfSelectedOptions() =>
      _optionsSelectionStatus.entries.where((element) => element.value).map((e) => e.key).toList();
}
