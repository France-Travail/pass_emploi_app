import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:intl/intl.dart';
import 'package:pass_emploi_app/presentation/model/date_input_source.dart';
import 'package:pass_emploi_app/presentation/model/date_suggestions_view_model.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/date_extensions.dart';
import 'package:pass_emploi_app/widgets/a11y/string_a11y_extensions.dart';

/// Choix d'une date passée : suggestions « Aujourd'hui » / « Hier », puis « Autre date » (calendrier).
///
/// A11y (audit RAAM du 15/10/2026) :
/// - 9.6 : [title] est la légende du groupe de choix, pas un titre de section ; elle est reprise dans le nom
///   accessible de chaque choix, et les suggestions sont restituées avant « Autre date ».
/// - 5.1 / 5.2 / 9.2 : « Autre date » est un bouton nommé par son étiquette visible, atteignable et activable au
///   clavier (Entrée, Espace), au lecteur d'écran et au toucher, y compris en touchant l'étiquette.
class PastDateChoice extends StatefulWidget {
  const PastDateChoice({super.key, required this.title, required this.onDateChanged, this.aide, this.firstDate});

  final String title;
  final String? aide;

  /// Date la plus ancienne proposée (suggestions et calendrier). Par défaut, un an avant aujourd'hui.
  final DateTime? firstDate;
  final void Function(DateInputSource) onDateChanged;

  @override
  State<PastDateChoice> createState() => _PastDateChoiceState();
}

class _PastDateChoiceState extends State<PastDateChoice> {
  DateInputSource _date = DateNotInitialized();
  DateTime? _displayedDate;

  @override
  Widget build(BuildContext context) {
    final suggestions = DateSuggestionListViewModel.createPast(DateTime.now(), widget.firstDate).suggestions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title,
          style: DsfrTextStyle.bodyMdBold(
            color: DsfrColorDecisions.textTitleGrey(context),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        Wrap(
          spacing: DsfrSpacings.s1w,
          runSpacing: DsfrSpacings.s1w,
          children: [
            for (final suggestion in suggestions)
              Semantics(
                button: true,
                // A11y 5.5 : état sélectionné restitué, et nom lu une seule fois.
                selected: _isSuggestionSelected(suggestion),
                label: '${suggestion.a11yLabel}, ${widget.title}',
                onTap: () => _selectSuggestion(suggestion),
                excludeSemantics: true,
                child: DsfrButton(
                  label: suggestion.date.isToday() ? Strings.dateSuggestionAujourdhui : Strings.dateSuggestionHier,
                  variant: _isSuggestionSelected(suggestion) ? DsfrButtonVariant.primary : DsfrButtonVariant.secondary,
                  size: DsfrComponentSize.sm,
                  onPressed: () => _selectSuggestion(suggestion),
                ),
              ),
          ],
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        OtherDateButton(
          groupLabel: widget.title,
          date: _displayedDate,
          aide: widget.aide,
          onTap: _pickOtherDate,
        ),
      ],
    );
  }

  Future<void> _pickOtherDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('fr', 'FR'),
      initialDate: _displayedDate ?? now,
      firstDate: _firstDate(now),
      lastDate: now,
    );
    if (picked == null || !mounted) return;
    _setDate(DateFromPicker(picked), picked);
  }

  DateTime _firstDate(DateTime now) => widget.firstDate ?? now.subtract(const Duration(days: 365));

  bool _isSuggestionSelected(DateSuggestionViewModel suggestion) {
    return switch (_date) {
      DateFromSuggestion(:final date) => DateUtils.dateOnly(date) == DateUtils.dateOnly(suggestion.date),
      _ => false,
    };
  }

  void _selectSuggestion(DateSuggestionViewModel suggestion) {
    _setDate(DateFromSuggestion(suggestion.date, suggestion.label), suggestion.date);
  }

  void _setDate(DateInputSource date, DateTime displayedDate) {
    setState(() {
      _date = date;
      _displayedDate = displayedDate;
    });
    widget.onDateChanged(date);
  }
}

/// Champ « Autre date » : a l'apparence d'un champ de saisie DSFR, mais c'est un bouton qui ouvre le calendrier.
class OtherDateButton extends StatefulWidget {
  const OtherDateButton({
    super.key,
    required this.groupLabel,
    required this.date,
    required this.onTap,
    this.aide,
  });

  /// Légende du groupe de choix de date, reprise dans le nom accessible.
  final String groupLabel;
  final DateTime? date;
  final String? aide;
  final VoidCallback onTap;

  @override
  State<OtherDateButton> createState() => _OtherDateButtonState();
}

class _OtherDateButtonState extends State<OtherDateButton> with MaterialStateMixin<OtherDateButton> {
  static const _radius = BorderRadius.vertical(top: Radius.circular(DsfrSpacings.s1v));

  @override
  Widget build(BuildContext context) {
    final aide = widget.aide;
    final displayedDate = widget.date != null ? DateFormat('dd/MM/yyyy').format(widget.date!) : null;
    return Semantics(
      container: true,
      button: true,
      label: '${Strings.otherDate}, ${widget.groupLabel}',
      value: displayedDate?.toDateForScreenReaders(),
      hint: aide,
      onTap: widget.onTap,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Comme une étiquette de champ, toucher le texte « Autre date » ouvre aussi le calendrier.
          GestureDetector(
            onTap: widget.onTap,
            behavior: HitTestBehavior.opaque,
            child: Text(
              Strings.otherDate,
              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textLabelGrey(context)),
            ),
          ),
          const SizedBox(height: DsfrSpacings.s1v),
          if (aide != null) ...[
            Text(
              aide,
              style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textMentionGrey(context)),
            ),
            const SizedBox(height: DsfrSpacings.s1w),
          ],
          DsfrFocusWidget(
            isFocused: isFocused,
            borderRadius: _radius,
            child: Material(
              color: DsfrColorDecisions.backgroundContrastGrey(context),
              borderRadius: _radius,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: _radius,
                focusColor: DsfrColorDecisions.backgroundTransparent(context),
                onFocusChange: updateMaterialState(WidgetState.focused),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: DsfrColorDecisions.borderPlainGrey(context), width: DsfrSpacings.s0v5),
                    ),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: DsfrSpacings.s6w),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s3v, vertical: DsfrSpacings.s3v),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayedDate ?? '',
                              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                            ),
                          ),
                          Icon(
                            DsfrIcons.businessCalendarLine,
                            size: 16,
                            color: DsfrColorDecisions.textDefaultGrey(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
