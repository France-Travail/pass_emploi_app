import 'package:flutter/material.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_form/create_demarche_form_change_notifier.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/buttons/secondary_button.dart';
import 'package:pass_emploi_app/widgets/information_bandeau.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/base_text_form_field.dart';
import 'package:speech_to_text/speech_to_text.dart';

class CreateDemarcheIaFtStep1Page extends StatefulWidget {
  const CreateDemarcheIaFtStep1Page(this.viewModel);
  final CreateDemarcheFormChangeNotifier viewModel;

  @override
  State<CreateDemarcheIaFtStep1Page> createState() => _CreateDemarcheIaFtStep1PageState();
}

class _CreateDemarcheIaFtStep1PageState extends State<CreateDemarcheIaFtStep1Page> {
  final SpeechToText _speechToText = SpeechToText();
  late final TextEditingController _textEditingController;
  bool _isListening = false;
  String? _errorText;

  Future<void> _startListening() async {
    PassEmploiMatomoTracker.instance.trackEvent(
      eventCategory: AnalyticsEventNames.createDemarcheEventCategory,
      action: AnalyticsEventNames.createDemarcheIaDicterPressed,
    );
    final bool available = await _speechToText.initialize(
      onError: (error) {
        setState(() => _errorText = Strings.genericError);
      },
    );
    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            if (result.recognizedWords.length >= CreateDemarcheIaFtStep1ViewModel.maxLength) {
              _stopListening();
            } else {
              _textEditingController.text = result.recognizedWords;
            }
          });
        },
      );
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
      tracking: AnalyticsScreenNames.createDemarcheIaFtStepPrompt,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: Margins.spacing_base),
            Text(Strings.iaFtStep2Title, style: TextStyles.textMBold),
            Text(Strings.iaFtStep2Mandatory, style: TextStyles.textSRegular(color: AppColors.contentColor)),
            const SizedBox(height: Margins.spacing_base),
            InformationBandeau(
              text: Strings.iaFtStep2Warning,
              icon: AppIcons.info,
              backgroundColor: AppColors.primaryLighten,
              textColor: AppColors.primary,
              borderRadius: Dimens.radius_base,
              padding: EdgeInsets.symmetric(vertical: Margins.spacing_base, horizontal: Margins.spacing_base),
            ),
            const SizedBox(height: Margins.spacing_base),
            Stack(
              children: [
                Stack(
                  children: [
                    BaseTextField(
                      controller: _textEditingController,
                      hintText: Strings.iaFtStep2FieldHint,
                      minLines: 3,
                      maxLines: null,
                      maxLength: CreateDemarcheIaFtStep1ViewModel.maxLength,
                      errorText: _errorText,
                      onChanged: (value) => setState(() => _errorText = null),
                      suffixIcon: Opacity(
                        opacity: 0,
                        child: ExcludeSemantics(
                          child: IconButton(onPressed: null, icon: Icon(Icons.close), color: AppColors.primary),
                        ),
                      ),
                    ),
                    Positioned(
                      // manually ajusted
                      right: -8,
                      bottom: Margins.spacing_base,
                      child: IconButton(
                        onPressed: () => _textEditingController.clear(),
                        icon: IconButton(
                          tooltip: _isListening ? Strings.iaFtStep2ButtonStop : Strings.iaFtStep2ButtonDicter,
                          onPressed: () {
                            if (_isListening) {
                              _stopListening();
                            } else {
                              _startListening();
                            }
                          },
                          icon: Container(
                            padding: EdgeInsets.all(2),
                            decoration: _isListening
                                ? null
                                : BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primary, width: 2),
                                  ),
                            child: Icon(_isListening ? Icons.stop_circle_rounded : Icons.mic, color: AppColors.primary),
                          ),
                        ),
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (_textEditingController.text.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: IconButton(
                      onPressed: () => _textEditingController.clear(),
                      icon: Icon(Icons.close),
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Margins.spacing_base),
            PrimaryActionButton(
              label: Strings.iaFtStep2Button,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              onPressed: () {
                if (_textEditingController.text.isNotEmpty) {
                  widget.viewModel.navigateToCreateDemarcheIaFtStep2();
                } else {
                  setState(() => _errorText = Strings.iaFtEmptyError);
                }
              },
            ),
            const SizedBox(height: Margins.spacing_l),
            _OrDivider(),
            const SizedBox(height: Margins.spacing_l),
            ThematiqueButton(viewModel: widget.viewModel),
            SizedBox(height: Margins.spacing_huge),
            SizedBox(height: Margins.spacing_huge),
            SizedBox(height: Margins.spacing_huge),
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final color = AppColors.grey500;
    return Row(
      children: [
        Expanded(child: Divider(color: color, height: 1)),
        const SizedBox(width: Margins.spacing_base),
        Text(Strings.or, style: TextStyles.textBaseRegular.copyWith(color: color)),
        const SizedBox(width: Margins.spacing_base),
        Expanded(child: Divider(color: color, height: 1)),
      ],
    );
  }
}

class ThematiqueButton extends StatelessWidget {
  const ThematiqueButton({super.key, required this.viewModel});
  final CreateDemarcheFormChangeNotifier viewModel;

  @override
  Widget build(BuildContext context) {
    return SecondaryButton(
      label: Strings.thematiquesDemarcheButton,
      suffix: Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
      onPressed: () {
        viewModel.navigateToThematiquesDemarche();
        PassEmploiMatomoTracker.instance.trackEvent(
          eventCategory: AnalyticsEventNames.createDemarcheEventCategory,
          action: AnalyticsEventNames.createDemarcheThematiquesPressed,
        );
      },
    );
  }
}
