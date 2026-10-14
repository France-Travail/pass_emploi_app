import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class CustomRadioGroup<T> extends StatefulWidget {
  const CustomRadioGroup({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });
  final String title;
  final T value;
  final T? groupValue;
  final void Function(T?) onChanged;

  @override
  State<CustomRadioGroup<T>> createState() => _CustomRadioGroupState<T>();
}

class _CustomRadioGroupState<T> extends State<CustomRadioGroup<T>> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    final value = widget.value;
    final groupValue = widget.groupValue;
    final onChanged = widget.onChanged;
    final isSelected = value == groupValue;

    return Padding(
      padding: const EdgeInsets.only(bottom: DsfrSpacings.s1w),
      child: Semantics(
        button: true,
        selected: isSelected,
        label: '${isSelected ? Strings.selectedRadioButton : Strings.unselectedRadioButton} : $title',
        // A11y 2.3 : contour de focus DSFR à la place du voile gris de Material.
        child: DsfrFocusWidget(
          isFocused: _focused,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          child: InkWell(
            onTap: () => onChanged(value),
            focusColor: DsfrColorDecisions.backgroundTransparent(context),
            onFocusChange: (focused) => setState(() => _focused = focused),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Align(
                alignment: Alignment.centerLeft,
                // A11y 10.1 : le bouton radio dessiné à l'intérieur n'est plus un second arrêt clavier.
                child: ExcludeSemantics(
                  child: IgnorePointer(
                    child: ExcludeFocus(
                      child: DsfrRadioButton<T>(
                        label: title,
                        value: value,
                        groupValue: groupValue,
                        size: DsfrComponentSize.md,
                        onChanged: onChanged,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
