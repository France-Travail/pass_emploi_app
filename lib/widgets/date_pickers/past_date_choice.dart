import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:intl/intl.dart';
import 'package:pass_emploi_app/presentation/model/date_input_source.dart';
import 'package:pass_emploi_app/presentation/model/date_suggestions_view_model.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/date_extensions.dart';

class PastDateChoice extends StatefulWidget {
  const PastDateChoice({super.key, required this.title, required this.onDateChanged, this.aide});

  final String title;
  final String? aide;
  final void Function(DateInputSource) onDateChanged;

  @override
  State<PastDateChoice> createState() => _PastDateChoiceState();
}

class _PastDateChoiceState extends State<PastDateChoice> {
  DateInputSource _date = DateNotInitialized();
  late final TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aide = widget.aide;
    final suggestions = DateSuggestionListViewModel.createPast(DateTime.now(), null).suggestions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            widget.title,
            style: DsfrTextStyle.bodyMdBold(
              color: DsfrColorDecisions.textTitleGrey(context),
            ),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        Wrap(
          spacing: DsfrSpacings.s1w,
          runSpacing: DsfrSpacings.s1w,
          children: [
            for (final suggestion in suggestions)
              DsfrButton(
                label: suggestion.date.isToday() ? Strings.dateSuggestionAujourdhui : Strings.dateSuggestionHier,
                variant: _isSuggestionSelected(suggestion) ? DsfrButtonVariant.primary : DsfrButtonVariant.secondary,
                size: DsfrComponentSize.sm,
                onPressed: () => _selectSuggestion(suggestion),
              ),
          ],
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        Text(
          Strings.otherDate,
          style: DsfrTextStyle.bodyMd(
            color: DsfrColorDecisions.textLabelGrey(context),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s1v),
        if (aide != null) ...[
          Text(
            aide,
            style: DsfrTextStyle.bodyXs(
              color: DsfrColorDecisions.textMentionGrey(context),
            ),
          ),
          const SizedBox(height: DsfrSpacings.s1w),
        ],
        DsfrInputHeadless(
          controller: _dateController,
          isDatePicker: true,
          lastDate: DateTime.now(),
          locale: const Locale('fr', 'FR'),
          onDateChanged: (date) => _setDate(DateFromPicker(date)),
        ),
      ],
    );
  }

  bool _isSuggestionSelected(DateSuggestionViewModel suggestion) {
    return switch (_date) {
      DateFromSuggestion(:final date) => DateUtils.dateOnly(date) == DateUtils.dateOnly(suggestion.date),
      _ => false,
    };
  }

  void _selectSuggestion(DateSuggestionViewModel suggestion) {
    _dateController.text = DateFormat('dd/MM/yyyy').format(suggestion.date);
    _setDate(DateFromSuggestion(suggestion.date, suggestion.label));
  }

  void _setDate(DateInputSource date) {
    setState(() => _date = date);
    widget.onDateChanged(date);
  }
}
