import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/presentation/model/date_input_source.dart';
import 'package:pass_emploi_app/presentation/model/date_suggestions_view_model.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/date_extensions.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_date_picker_field.dart';

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
        // A11y 5.1 / 9.1 / 9.2 / 9.9 : un seul bouton, nommé par son étiquette visible et son message d'erreur.
        DsfrDatePickerField(
          label: widget.label,
          hintText: widget.hintText,
          controller: _controller,
          firstDate: DateTime(2020),
          lastDate: DateTime(2101),
          initialDate: widget.dateSource.isValid ? widget.dateSource.selectedDate : DateTime.now(),
          composantState: widget.isInvalid
              ? DsfrComponentState.error(errorMessage: widget.errorMessage ?? Strings.dateMandatory)
              : const DsfrComponentState.none(),
          onChanged: (date) => widget.onDateChanged(DateFromPicker(date)),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        DsfrDateSuggestions(
          fieldLabel: widget.label,
          dateSource: widget.dateSource,
          onSelected: widget.onDateChanged,
        ),
      ],
    );
  }
}

class DsfrDateSuggestions extends StatelessWidget {
  const DsfrDateSuggestions({
    super.key,
    required this.fieldLabel,
    required this.onSelected,
    required this.dateSource,
  });

  /// Étiquette visible du champ date associé, reprise dans le nom de chaque suggestion (A11y 9.6).
  final String fieldLabel;
  final void Function(DateInputSource) onSelected;
  final DateInputSource dateSource;

  @override
  Widget build(BuildContext context) {
    final dateSuggestionsViewModel = DateSuggestionListViewModel.createFuture(DateTime.now());
    return Wrap(
      spacing: DsfrSpacings.s1w,
      runSpacing: DsfrSpacings.s1w,
      children: [
        for (final suggestion in dateSuggestionsViewModel.suggestions)
          Semantics(
            button: true,
            // A11y 10.3.3 : état sélectionné restitué, et nom lu une seule fois.
            selected: _isSuggestionSelected(suggestion),
            // A11y 9.6 : le nom reprend l'étiquette du champ date, après le libellé visible.
            label: '${suggestion.a11yLabel}, $fieldLabel',
            onTap: () => onSelected(DateFromSuggestion(suggestion.date, suggestion.label)),
            excludeSemantics: true,
            child: DsfrButton(
              label: suggestion.label,
              variant: _isSuggestionSelected(suggestion) ? DsfrButtonVariant.primary : DsfrButtonVariant.secondary,
              size: DsfrComponentSize.sm,
              onPressed: () => onSelected(DateFromSuggestion(suggestion.date, suggestion.label)),
            ),
          ),
        if (dateSource is DateFromPicker)
          // Libellé visible déjà présent : l'icône n'a pas à le répéter (« Supprimer la date » était lu deux fois).
          DsfrButton(
            icon: DsfrIcons.systemCloseLine,
            label: Strings.removeDateTooltip,
            variant: DsfrButtonVariant.tertiaryWithoutBorder,
            size: DsfrComponentSize.sm,
            onPressed: () => onSelected(DateNotInitialized()),
          ),
      ],
    );
  }

  bool _isSuggestionSelected(DateSuggestionViewModel suggestion) {
    return switch (dateSource) {
      DateFromSuggestion(:final date) => DateUtils.dateOnly(date) == DateUtils.dateOnly(suggestion.date),
      _ => false,
    };
  }
}
