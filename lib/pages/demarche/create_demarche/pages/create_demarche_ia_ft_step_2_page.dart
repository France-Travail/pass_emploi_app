import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_form/create_demarche_form_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/information_bandeau.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/base_text_form_field.dart';
import 'package:speech_to_text/speech_to_text.dart';

class CreateDemarcheIaFtStep2Page extends StatefulWidget {
  const CreateDemarcheIaFtStep2Page(this.viewModel);
  final CreateDemarcheFormViewModel viewModel;

  @override
  State<CreateDemarcheIaFtStep2Page> createState() => _CreateDemarcheIaFtStep2PageState();
}

class _CreateDemarcheIaFtStep2PageState extends State<CreateDemarcheIaFtStep2Page> {
  final SpeechToText _speechToText = SpeechToText();
  late final TextEditingController _textEditingController;
  bool _isListening = false;
  String? _errorText;

  Future<void> _startListening() async {
    PassEmploiMatomoTracker.instance.trackEvent(
      eventCategory: AnalyticsEventNames.createDemarcheEventCategory(
        StoreProvider.of<AppState>(context).state.featureFlipState.featureFlip.abTestingIaFt.name,
      ),
      action: AnalyticsEventNames.createDemarcheIaDicterPressed,
    );
    final bool available = await _speechToText.initialize(
      onError: (error) {
        setState(() => _errorText = Strings.genericError);
      },
    );
    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(onResult: (result) {
        setState(() {
          if (result.recognizedWords.length >= CreateDemarcheIaFtStep2ViewModel.maxLength) {
            _stopListening();
          } else {
            _textEditingController.text = result.recognizedWords;
          }
        });
      });
    }
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() => _isListening = false);
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.viewModel.iaFtStep2ViewModel.description);
    _textEditingController.addListener(() {
      widget.viewModel.iaFtDescriptionChanged(_textEditingController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.createDemarcheIaFtStep2,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: Margins.spacing_base),
            Text(Strings.iaFtStep2Title, style: TextStyles.textMBold),
            Text(Strings.iaFtStep2Mandatory, style: TextStyles.textSRegular(color: AppColors.contentColor)),
            const SizedBox(height: Margins.spacing_base),
            Stack(
              children: [
                BaseTextField(
                  controller: _textEditingController,
                  hintWidget: Padding(
                    padding: const EdgeInsets.only(right: Margins.spacing_base),
                    child: TypewriterHint(
                      text: Strings.iaFtStep2FieldHint,
                      style: TextStyles.textSRegular(color: AppColors.grey800),
                      speed: const Duration(milliseconds: 50),
                      pauseDuration: const Duration(milliseconds: 2000),
                    ),
                  ),
                  minLines: 3,
                  maxLines: null,
                  maxLength: CreateDemarcheIaFtStep2ViewModel.maxLength,
                  errorText: _errorText,
                  onChanged: (value) => setState(() => _errorText = null),
                  suffixIcon: Opacity(
                    opacity: 0,
                    child: ExcludeSemantics(
                      child: IconButton(
                        onPressed: null,
                        icon: Icon(Icons.close),
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    tooltip: _isListening ? Strings.iaFtStep2ButtonStop : Strings.iaFtStep2ButtonDicter,
                    onPressed: () {
                      if (_isListening) {
                        _stopListening();
                      } else {
                        _startListening();
                      }
                    },
                    icon: Icon(_isListening ? Icons.stop_circle_rounded : Icons.mic, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Margins.spacing_base),
            InformationBandeau(
              text: Strings.iaFtStep2Warning,
              icon: AppIcons.info,
              backgroundColor: AppColors.primaryLighten,
              textColor: AppColors.primary,
              borderRadius: Dimens.radius_base,
              padding: EdgeInsets.symmetric(
                vertical: Margins.spacing_s,
                horizontal: Margins.spacing_base,
              ),
            ),
            // const SizedBox(height: Margins.spacing_base),
            // PrimaryActionButton(
            //   label: _isListening ? Strings.iaFtStep2ButtonStop : Strings.iaFtStep2ButtonDicter,
            //   onPressed: () {
            //     if (_isListening) {
            //       _stopListening();
            //     } else {
            //       _startListening();
            //     }
            //   },
            //   suffix: _isListening
            //       ? SizedBox(
            //           height: 24,
            //           child: SoundWaveformWidget(),
            //         )
            //       : null,
            //   backgroundColor: AppColors.primaryLighten,
            //   textColor: AppColors.primary,
            //   iconColor: AppColors.primary,
            //   icon: _isListening ? Icons.stop_circle_rounded : Icons.mic,
            //   rippleColor: AppColors.primary.withOpacity(0.3),
            // ),
            const SizedBox(height: Margins.spacing_base),
            PrimaryActionButton(
              label: Strings.iaFtStep2Button,
              onPressed: _textEditingController.text.isNotEmpty
                  ? () => widget.viewModel.navigateToCreateDemarcheIaFtStep3()
                  : null,
            ),
            const SizedBox(height: Margins.spacing_base),
            SizedBox(height: Margins.spacing_huge),
            SizedBox(height: Margins.spacing_huge),
            SizedBox(height: Margins.spacing_huge),
          ],
        ),
      ),
    );
  }
}

class SoundWaveformWidget extends StatefulWidget {
  final int count;
  final double minHeight;
  final double maxHeight;
  final int durationInMilliseconds;

  const SoundWaveformWidget({
    super.key,
    this.count = 6,
    this.minHeight = 10,
    this.maxHeight = 20,
    this.durationInMilliseconds = 1000,
  });
  @override
  State<SoundWaveformWidget> createState() => _SoundWaveformWidgetState();
}

class _SoundWaveformWidgetState extends State<SoundWaveformWidget> with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: widget.durationInMilliseconds,
        ))
      ..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.count;
    final minHeight = widget.minHeight;
    final maxHeight = widget.maxHeight;
    return AnimatedBuilder(
      animation: controller,
      builder: (c, child) {
        final double t = controller.value;
        final int current = (count * t).floor();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            count,
            (i) => AnimatedContainer(
              duration: Duration(milliseconds: widget.durationInMilliseconds ~/ count),
              margin: i == (count - 1) ? EdgeInsets.zero : const EdgeInsets.only(right: 5),
              height: i == current ? maxHeight : minHeight,
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TypewriterHint extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration speed;
  final Duration pauseDuration;

  const TypewriterHint({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 50),
    this.pauseDuration = const Duration(milliseconds: 1000),
  });

  @override
  State<TypewriterHint> createState() => _TypewriterHintState();
}

class _TypewriterHintState extends State<TypewriterHint> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pauseController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.speed,
    );
    _pauseController = AnimationController(
      vsync: this,
      duration: widget.pauseDuration,
    );

    _startTyping();
  }

  void _startTyping() {
    _controller.forward().then((_) {
      if (_currentIndex < widget.text.length - 1) {
        setState(() {
          _currentIndex++;
        });
        _controller.reset();
        _startTyping();
      } else {
        // Fin du texte, pause puis recommence
        _pauseController.forward().then((_) {
          setState(() {
            _currentIndex = 0;
          });
          _pauseController.reset();
          _startTyping();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pauseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, _pauseController]),
        builder: (context, child) {
          String displayText = widget.text.substring(0, _currentIndex + 1);

          // Ajouter un curseur clignotant
          if (_currentIndex < widget.text.length - 1 || _pauseController.isAnimating) {
            displayText += '|';
          }

          return RichText(
            text: TextSpan(
              text: displayText,
              style: widget.style,
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          );
        },
      ),
    );
  }
}
