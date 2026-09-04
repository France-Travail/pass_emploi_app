import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class ReadOnlyTextFormField extends StatefulWidget {
  final String title;
  final String heroTag;
  final Key textFormFieldKey;
  final bool withDeleteButton;
  final Function() onTextTap;
  final Function() onDeleteTap;
  final String a11ySuppressionLabel;
  final String? hint;
  final String? initialValue;
  final Widget? prefixIcon;

  const ReadOnlyTextFormField({
    super.key,
    required this.title,
    required this.heroTag,
    required this.textFormFieldKey,
    required this.withDeleteButton,
    required this.onTextTap,
    required this.onDeleteTap,
    required this.a11ySuppressionLabel,
    required this.hint,
    this.initialValue,
    this.prefixIcon,
  });

  @override
  State<ReadOnlyTextFormField> createState() => _ReadOnlyTextFormFieldState();
}

class _ReadOnlyTextFormFieldState extends State<ReadOnlyTextFormField> {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
          widget.onTextTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
    );
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void didUpdateWidget(covariant ReadOnlyTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.initialValue ?? '';
    if (oldWidget.initialValue != widget.initialValue && _controller.text != next) {
      _controller.text = next;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final underlineInputBorder = UnderlineInputBorder(
      borderSide: BorderSide(
        color: DsfrColorDecisions.borderPlainGrey(context),
        width: DsfrSpacings.s0v5,
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(DsfrSpacings.s1v)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            widget.title,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textLabelGrey(context)),
          ),
        ),
        if (widget.hint != null) ...[
          const SizedBox(height: DsfrSpacings.s1v),
          ExcludeSemantics(
            child: Text(
              widget.hint!,
              style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textMentionGrey(context)),
            ),
          ),
        ],
        const SizedBox(height: DsfrSpacings.s1w),
        Hero(
          tag: widget.heroTag,
          child: Semantics(
            button: true,
            label: widget.hint ?? (widget.initialValue != null ? Strings.chosenValue : ''),
            child: Material(
              type: MaterialType.transparency,
              child: DsfrFocusWidget(
                isFocused: _isFocused,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(DsfrSpacings.s1v)),
                child: TextFormField(
                  key: widget.textFormFieldKey,
                  controller: _controller,
                  focusNode: _focusNode,
                  readOnly: true,
                  showCursor: false,
                  onTap: widget.onTextTap,
                  style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                  decoration: InputDecoration(
                    prefixIcon: widget.prefixIcon,
                    suffixIcon: widget.withDeleteButton
                        ? IconButton(
                            onPressed: widget.onDeleteTap,
                            tooltip: widget.a11ySuppressionLabel,
                            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                            icon: Icon(
                              DsfrIcons.systemCloseLine,
                              size: 16,
                              color: DsfrColorDecisions.textDefaultGrey(context),
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: DsfrColorDecisions.backgroundContrastGrey(context),
                    focusedBorder: underlineInputBorder,
                    enabledBorder: underlineInputBorder,
                    border: underlineInputBorder,
                    constraints: const BoxConstraints(maxHeight: DsfrSpacings.s6w),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
