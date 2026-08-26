import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart' hide DsfrNotice;
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_form/create_demarche_form_change_notifier.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_notice.dart';
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
          final recognized = result.recognizedWords;
          final maxLength = CreateDemarcheIaFtStep1ViewModel.maxLength;
          final clamped = recognized.length > maxLength ? recognized.substring(0, maxLength) : recognized;
          setState(() {
            _textEditingController.value = _textEditingController.value.copyWith(
              text: clamped,
              selection: TextSelection.collapsed(offset: clamped.length),
              composing: TextRange.empty,
            );
            if (recognized.length >= maxLength) _stopListening();
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
    _textEditingController = TextEditingController(
      text: widget.viewModel.iaFtStep2ViewModel.description,
    );
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
            Semantics(
              header: true,
              child: Text(
                Strings.iaFtStep2Title,
                style: DsfrTextStyle.bodyMdBold(
                  color: DsfrColorDecisions.textTitleGrey(context),
                ),
              ),
            ),
            const SizedBox(height: DsfrSpacings.s1v),
            Text(
              Strings.iaFtStep2Mandatory,
              style: DsfrTextStyle.bodySm(
                color: DsfrColorDecisions.textMentionGrey(context),
              ),
            ),
            const SizedBox(height: DsfrSpacings.s2w),
            DsfrNotice(titre: Strings.iaFtStep2Warning),
            const SizedBox(height: DsfrSpacings.s2w),
            if (_isListening)
              Semantics(
                liveRegion: true,
                label: Strings.iaFtStep2Listening,
                child: const SizedBox.shrink(),
              ),
            Semantics(
              container: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: DsfrInput(
                      label: Strings.iaFtStep2Title,
                      hintText: Strings.iaFtStep2FieldHint,
                      placeholder: Strings.iaFtStep2FieldPlaceholder,
                      controller: _textEditingController,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 3,
                      maxLines: 5,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                          CreateDemarcheIaFtStep1ViewModel.maxLength,
                        ),
                      ],
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
            ),
            const SizedBox(height: DsfrSpacings.s4w),
            SizedBox(
              width: double.infinity,
              child: DsfrButton(
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
            style: DsfrTextStyle.bodyMd(
              color: DsfrColorDecisions.textActionHighBlueFrance(context),
            ),
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
    return SizedBox(
      width: double.infinity,
      child: DsfrButton(
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
      ),
    );
  }
}
