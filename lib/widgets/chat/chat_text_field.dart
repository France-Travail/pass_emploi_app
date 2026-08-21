import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/network/post_evenement_engagement.dart';
import 'package:pass_emploi_app/pages/credentials_page.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';
import 'package:pass_emploi_app/utils/context_extensions.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/chat_piece_jointe_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/onboarding/onboarding_showcase.dart';

class ChatTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool jeunePjEnabled;
  final Function(String) onSendMessage;
  final Function(String) onSendImage;
  final Function(String) onSendFile;

  const ChatTextField({
    required this.controller,
    required this.focusNode,
    required this.jeunePjEnabled,
    required this.onSendMessage,
    required this.onSendImage,
    required this.onSendFile,
  });

  @override
  State<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  late bool showSendButton;

  @override
  void initState() {
    showSendButton = !widget.jeunePjEnabled && widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextFieldChanged);
    super.initState();
  }

  void _onTextFieldChanged() {
    setState(() {
      showSendButton = widget.controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextFieldChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingShowcase(
      source: ShowcaseSource.message,
      child: ColoredBox(
        color: DsfrColorDecisions.backgroundDefaultGrey(context),
        child: Padding(
          padding: const EdgeInsets.all(DsfrSpacings.s2w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedCrossFade(
                firstChild: const SizedBox(height: DsfrSpacings.s6w, width: 0),
                secondChild: Padding(
                  padding: const EdgeInsets.only(right: DsfrSpacings.s1w),
                  child: Tooltip(
                    message: Strings.sendAttachmentTooltip,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.radius_s),
                      child: DsfrButton(
                        icon: DsfrIcons.businessAttachmentLine,
                        iconSemanticLabel: Strings.sendAttachmentTooltip,
                        variant: DsfrButtonVariant.primary,
                        size: DsfrComponentSize.lg,
                        onPressed: onSelectPieceJointe,
                      ),
                    ),
                  ),
                ),
                crossFadeState: widget.jeunePjEnabled && !showSendButton
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: AnimationDurations.fast,
              ),
              Expanded(
                child: Semantics(
                  label: widget.controller.text.isNotEmpty ? Strings.yourMessage : null,
                  child: DsfrInputHeadless(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    placeholder: Strings.yourMessage,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5,
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(height: DsfrSpacings.s6w, width: 0),
                secondChild: Padding(
                  padding: const EdgeInsets.only(left: DsfrSpacings.s1w),
                  child: Semantics(
                    enabled: false,
                    container: true,
                    child: Tooltip(
                      message: Strings.sendMessageTooltip,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Dimens.radius_s),
                        child: DsfrButton(
                          icon: DsfrIcons.businessSendPlaneFill,
                          iconSemanticLabel: Strings.sendMessageTooltip,
                          variant: DsfrButtonVariant.primary,
                          size: DsfrComponentSize.lg,
                          onPressed: showSendButton ? _onSendPressed : () {},
                        ),
                      ),
                    ),
                  ),
                ),
                crossFadeState: showSendButton || A11yUtils.withScreenReader(context)
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: AnimationDurations.fast,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSendPressed() {
    if (widget.controller.value.text == "Je suis malade. Complètement malade.") {
      widget.controller.clear();
      Navigator.push(context, CredentialsPage.materialPageRoute());
    }
    if (widget.controller.value.text.isNotEmpty == true) {
      widget.onSendMessage(widget.controller.value.text);
      widget.controller.clear();
      context.trackEvenementEngagement(EvenementEngagement.MESSAGE_ENVOYE);
    }
  }

  void onSelectPieceJointe() async {
    final fileSource = await ChatPieceJointeBottomSheet.show(context);
    if (fileSource != null) {
      if (fileSource is ChatPieceJointeBottomSheetImageResult) {
        widget.onSendImage(fileSource.path);
      } else if (fileSource is ChatPieceJointeBottomSheetFileResult) {
        widget.onSendFile(fileSource.path);
      }
    }
  }
}
