import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_form/create_demarche_form_change_notifier.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
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
    setState(() => _errorText = null);
    final bool available = await _speechToText.initialize(
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _errorText = Strings.genericError;
        });
      },
    );
    if (!mounted) return;
    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (result) {
          if (!mounted) return;
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
    if (!mounted) return;
    setState(() => _isListening = false);
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.viewModel.iaFtStep2ViewModel.description);
    _textEditingController.addListener(() {
      widget.viewModel.iaFtDescriptionChanged(_textEditingController.text);
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _speechToText.stop();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.createDemarcheIaFtStepPrompt,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: DsfrSpacings.s2w),
            DsfrAlert(
              type: DsfrAlertType.info,
              title: Strings.iaFtStep2Warning,
            ),
            const SizedBox(height: DsfrSpacings.s2w),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: DsfrInput(
                    label: Strings.iaFtStep2Title,
                    hintText: Strings.iaFtStep2Mandatory,
                    placeholder: Strings.iaFtStep2FieldHint,
                    controller: _textEditingController,
                    minLines: 3,
                    maxLines: 5,
                    inputFormatters: [LengthLimitingTextInputFormatter(CreateDemarcheIaFtStep1ViewModel.maxLength)],
                    componentState: _errorText != null
                        ? DsfrComponentState.error(errorMessage: _errorText!)
                        : const DsfrComponentState.none(),
                    onChanged: (_) => setState(() => _errorText = null),
                  ),
                ),
                const SizedBox(width: DsfrSpacings.s1w),
                Column(
                  children: [
                    if (_textEditingController.text.isNotEmpty)
                      DsfrButton(
                        icon: DsfrIcons.systemCloseLine,
                        iconSemanticLabel: Strings.clear,
                        variant: DsfrButtonVariant.tertiaryWithoutBorder,
                        size: DsfrComponentSize.md,
                        onPressed: () => _textEditingController.clear(),
                      ),
                    DsfrButton(
                      icon: _isListening ? DsfrIcons.mediaStopCircleFill : DsfrIcons.mediaMicFill,
                      iconSemanticLabel: _isListening ? Strings.iaFtStep2ButtonStop : Strings.iaFtStep2ButtonDicter,
                      variant: DsfrButtonVariant.primary,
                      size: DsfrComponentSize.md,
                      onPressed: () {
                        if (_isListening) {
                          _stopListening();
                        } else {
                          _startListening();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: DsfrSpacings.s4w),
            DsfrButton(
              label: Strings.iaFtStep2Button,
              variant: DsfrButtonVariant.primary,
              size: DsfrComponentSize.md,
              onPressed: () {
                if (_textEditingController.text.isNotEmpty) {
                  widget.viewModel.navigateToCreateDemarcheIaFtStep2();
                } else {
                  setState(() => _errorText = Strings.iaFtEmptyError);
                }
              },
            ),
            const SizedBox(height: DsfrSpacings.s3w),
            const _OrDivider(),
            const SizedBox(height: DsfrSpacings.s3w),
            ThematiqueButton(viewModel: widget.viewModel),
            const SizedBox(height: 200),
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
    final color = DsfrColorDecisions.borderDefaultGrey(context);
    return Row(
      children: [
        Expanded(child: Divider(color: color, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
          child: Text(
            Strings.or,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textActionHighBlueFrance(context)),
          ),
        ),
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
    return DsfrButton(
      label: Strings.thematiquesDemarcheButton,
      variant: DsfrButtonVariant.secondary,
      size: DsfrComponentSize.md,
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
