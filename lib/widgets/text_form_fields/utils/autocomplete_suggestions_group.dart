import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';

class AutocompleteSuggestionsGroup extends StatelessWidget {
  final String? title;
  final IconData? titleIcon;
  final List<Widget> children;

  const AutocompleteSuggestionsGroup({
    super.key,
    this.title,
    this.titleIcon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: DsfrSpacings.s2w),
            child: Row(
              children: [
                if (titleIcon != null) ...[
                  Icon(
                    titleIcon,
                    size: 16,
                    color: DsfrColorDecisions.textTitleGrey(context),
                  ),
                  const SizedBox(width: DsfrSpacings.s1w),
                ],
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title!,
                      style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DsfrSpacings.s1w),
            border: Border.all(color: DsfrColorDecisions.artworkDecorativeBlueFrance(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: DsfrColorDecisions.artworkDecorativeBlueFrance(context),
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class AutocompleteSuggestionTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final String? secondaryText;

  const AutocompleteSuggestionTile({
    super.key,
    required this.text,
    required this.onTap,
    this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textActionHighBlueFrance(context));
    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(DsfrSpacings.s2w),
            child: secondaryText == null
                ? Text(text, style: textStyle)
                : Text.rich(
                    TextSpan(
                      text: text,
                      style: textStyle,
                      children: [
                        const TextSpan(text: ' '),
                        TextSpan(text: secondaryText, style: textStyle),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
