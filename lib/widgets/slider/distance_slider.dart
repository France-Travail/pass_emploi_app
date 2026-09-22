import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class DistanceSlider extends StatefulWidget {
  final double initialDistanceValue;
  final Function(double) onValueChange;
  final String label;
  final String Function(int km) descriptionBuilder;
  final String Function(int km) valueLabelBuilder;

  DistanceSlider({
    super.key,
    required this.initialDistanceValue,
    required this.onValueChange,
    String? label,
    String Function(int km)? descriptionBuilder,
    String Function(int km)? valueLabelBuilder,
  }) : label = label ?? Strings.searchRadius,
       descriptionBuilder = descriptionBuilder ?? Strings.searchRadiusDescription,
       valueLabelBuilder = valueLabelBuilder ?? Strings.searchRadiusValue;

  @override
  State<DistanceSlider> createState() => _DistanceSliderState();
}

class _DistanceSliderState extends State<DistanceSlider> {
  double? _currentSliderValue;

  static const double _maxValue = 100;
  static const int _divisions = 10;
  static const double _step = _maxValue / _divisions;

  @override
  Widget build(BuildContext context) {
    final value = _sliderValueToDisplay(widget.initialDistanceValue);
    // A11y 25.3.2 : le Slider du DSFR restitue sa valeur en pourcentage et son libellé est séparé.
    // On expose un seul composant ajustable : libellé, valeur en kilomètres, bornes min/max.
    return Semantics(
      container: true,
      slider: true,
      label: widget.label,
      value: Strings.searchRadiusA11yValue(value.round()),
      increasedValue: Strings.searchRadiusA11yValue((value + _step).clamp(0, _maxValue).round()),
      decreasedValue: Strings.searchRadiusA11yValue((value - _step).clamp(0, _maxValue).round()),
      hint: Strings.searchRadiusA11yHint(0, _maxValue.round()),
      onIncrease: value < _maxValue ? () => _onValueChange((value + _step).clamp(0, _maxValue)) : null,
      onDecrease: value > 0 ? () => _onValueChange((value - _step).clamp(0, _maxValue)) : null,
      excludeSemantics: true,
      child: DsfrSlider(
        label: widget.label,
        description: widget.descriptionBuilder(value.round()),
        value: value,
        min: 0,
        max: _maxValue,
        divisions: _divisions,
        size: DsfrComponentSize.md,
        valueLabelBuilder: (v) => widget.valueLabelBuilder(v.round()),
        showMinMaxLabels: true,
        onChanged: _onValueChange,
      ),
    );
  }

  void _onValueChange(double value) {
    setState(() => _currentSliderValue = value);
    widget.onValueChange(value);
  }

  double _sliderValueToDisplay(double initialDistanceValue) =>
      _currentSliderValue != null ? _currentSliderValue! : initialDistanceValue;
}
