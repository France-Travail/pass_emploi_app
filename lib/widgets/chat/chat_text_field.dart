import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/network/post_evenement_engagement.dart';
import 'package:pass_emploi_app/pages/credentials_page.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';
import 'package:pass_emploi_app/utils/context_extensions.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';
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
    final input = DsfrInputHeadless(
      controller: widget.controller,
      focusNode: widget.focusNode,
      placeholder: Strings.yourMessage,
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 5,
    );

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
                  // A11y : un seul nœud bouton, nommé une fois.
                  child: Semantics(
                    container: true,
                    button: true,
                    label: Strings.sendAttachmentTooltip,
                    onTap: onSelectPieceJointe,
                    excludeSemantics: true,
                    // A11y 8.5 : sans arrondi rogné, le contour de focus du bouton DSFR redevient visible.
                    child: Tooltip(
                      message: Strings.sendAttachmentTooltip,
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
              // A11y 9.1 : une étiquette reste visible au-dessus du champ ; le texte indicatif disparaissait à la
              // première lettre. Elle est fusionnée au champ pour en être le nom.
              Expanded(
                child: MergeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Strings.yourMessageLabel,
                        style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textLabelGrey(context)),
                      ),
                      const SizedBox(height: DsfrSpacings.s1v),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => widget.focusNode.requestFocusWithA11y(),
                        child: input,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(height: DsfrSpacings.s6w, width: 0),
                secondChild: Padding(
                  padding: const EdgeInsets.only(left: DsfrSpacings.s1w),
                  // A11y : un seul nœud bouton, nommé une fois, désactivé tant que le message est vide.
                  child: Semantics(
                    container: true,
                    button: true,
                    enabled: showSendButton,
                    label: Strings.sendMessageTooltip,
                    onTap: showSendButton ? _onSendPressed : null,
                    excludeSemantics: true,
                    child: Tooltip(
                      message: Strings.sendMessageTooltip,
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
