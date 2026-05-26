import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';
import 'package:pass_emploi_app/widgets/slider/slider_caption.dart';
import 'package:pass_emploi_app/widgets/slider/slider_value.dart';

class DistanceSlider extends StatefulWidget {
  final double initialDistanceValue;
  final Function(double) onValueChange;

  DistanceSlider({required this.initialDistanceValue, required this.onValueChange});

  @override
  State<DistanceSlider> createState() => _DistanceSliderState();
}

class _DistanceSliderState extends State<DistanceSlider> {
  double? _currentSliderValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderValue(value: _sliderValueToDisplay(widget.initialDistanceValue).toInt()),
        _Selector(
          onValueChange: (value) => _onValueChange(value),
          currentValue: _sliderValueToDisplay(widget.initialDistanceValue),
        ),
      ],
    );
  }

  void _onValueChange(double value) {
    if (value > 0) {
      setState(() => _currentSliderValue = value);
      widget.onValueChange(value);
      A11yUtils.announce(Strings.distanceUpdated(value.toInt()));
    }
  }

  double _sliderValueToDisplay(double initialDistanceValue) =>
      _currentSliderValue != null ? _currentSliderValue! : initialDistanceValue;
}

class _Selector extends StatelessWidget {
  final Function(double) onValueChange;
  final double currentValue;

  _Selector({required this.onValueChange, required this.currentValue});

  static const double maxValue = 100;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _DistanceButton(
          label: Strings.removeDistance(10),
          icon: AppIcons.remove,
          onPressed: () => onValueChange(currentValue - 10),
        ),
        Expanded(
          child: Semantics(
            excludeSemantics: true,
            child: Column(
              children: [
                Slider(
                  activeColor: AppColorsSpecifics.primaryToLighten(context),
                  value: currentValue,
                  min: 0,
                  max: maxValue,
                  divisions: 10,
                  onChanged: onValueChange,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_base),
                  child: SliderCaption(),
                ),
              ],
            ),
          ),
        ),
        _DistanceButton(
          label: Strings.addDistance(10),
          icon: AppIcons.add,
          onPressed: () {
            if (currentValue + 10 <= maxValue) {
              return onValueChange(currentValue + 10);
            }
          },
        ),
      ],
    );
  }
}

class _DistanceButton extends StatelessWidget {
  const _DistanceButton({required this.label, required this.icon, required this.onPressed});

  final String label;
  final IconData icon;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AppColorsSpecifics.primaryButtonBackgroundColor(context);
    final contentColor = AppColorsSpecifics.primaryButtonForegroundColor(context);
    return IconButton(
      tooltip: label,
      onPressed: onPressed,
      icon: Container(
        padding: EdgeInsets.all(Margins.spacing_s),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: contentColor),
      ),
    );
  }
}
