import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/presentation/model/date_input_source.dart';
import 'package:pass_emploi_app/presentation/model/date_suggestions_view_model.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/date_extensions.dart';

class DsfrDateInputSuggestions extends StatefulWidget {
  const DsfrDateInputSuggestions({
    super.key,
    required this.label,
    required this.dateSource,
    required this.onDateChanged,
    this.hintText,
    this.isInvalid = false,
    this.errorMessage,
  });

  final String label;
  final String? hintText;
  final DateInputSource dateSource;
  final void Function(DateInputSource) onDateChanged;
  final bool isInvalid;
  final String? errorMessage;

  @override
  State<DsfrDateInputSuggestions> createState() => _DsfrDateInputSuggestionsState();
}

class _DsfrDateInputSuggestionsState extends State<DsfrDateInputSuggestions> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _dateText(widget.dateSource));
  }

  @override
  void didUpdateWidget(covariant DsfrDateInputSuggestions oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextDateText = _dateText(widget.dateSource);
    if (_controller.text != nextDateText) {
      _controller.text = nextDateText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _dateText(DateInputSource dateSource) {
    return dateSource.isValid ? dateSource.selectedDate.toDay() : '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DsfrDateInput(
          label: widget.label,
          hintText: widget.hintText,
          controller: _controller,
          firstDate: DateTime(2020),
          lastDate: DateTime(2101),
          initialDate: widget.dateSource.isValid ? widget.dateSource.selectedDate : DateTime.now(),
          locale: const Locale('fr', 'FR'),
          composantState: widget.isInvalid
              ? DsfrComponentState.error(errorMessage: widget.errorMessage ?? Strings.dateMandatory)
              : const DsfrComponentState.none(),
          onChanged: (date) => widget.onDateChanged(DateFromPicker(date)),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        _DateSuggestions(
          dateSource: widget.dateSource,
          onSelected: widget.onDateChanged,
        ),
      ],
    );
  }
}

class _DateSuggestions extends StatelessWidget {
  const _DateSuggestions({
    required this.onSelected,
    required this.dateSource,
  });

  final void Function(DateInputSource) onSelected;
  final DateInputSource dateSource;

  @override
  Widget build(BuildContext context) {
    final dateSuggestionsViewModel = DateSuggestionListViewModel.createFuture(DateTime.now());
    return Wrap(
      spacing: DsfrSpacings.s1w,
      runSpacing: DsfrSpacings.s1w,
      children: switch (dateSource) {
        DateNotInitialized() => dateSuggestionsViewModel.suggestions
            .map(
              (suggestion) => Semantics(
                button: true,
                label: suggestion.a11yLabel,
                child: DsfrButton(
                  label: suggestion.label,
                  variant: DsfrButtonVariant.secondary,
                  size: DsfrComponentSize.sm,
                  onPressed: () => onSelected(DateFromSuggestion(suggestion.date, suggestion.label)),
                ),
              ),
            )
            .toList(),
        DateFromSuggestion() => [
          DsfrTag(
            label: (dateSource as DateFromSuggestion).label,
            size: DsfrComponentSize.md,
            isSelected: true,
            onSelectionChanged: (selected) {
              if (!selected) onSelected(DateNotInitialized());
            },
          ),
        ],
        DateFromPicker() => [
          DsfrButton(
            icon: DsfrIcons.systemCloseLine,
            iconSemanticLabel: Strings.removeDateTooltip,
            label: Strings.removeDateTooltip,
            variant: DsfrButtonVariant.tertiaryWithoutBorder,
            size: DsfrComponentSize.sm,
            onPressed: () => onSelected(DateNotInitialized()),
          ),
        ],
      },
    );
  }
}
