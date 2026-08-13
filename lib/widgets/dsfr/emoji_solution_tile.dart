import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/widgets/dsfr/emoji_tile.dart';

class EmojiSolutionGrid extends StatelessWidget {
  final List<Widget> tiles;
  final double gap;

  const EmojiSolutionGrid({super.key, required this.tiles, this.gap = DsfrSpacings.s3v});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < tiles.length; i += 2) {
      final left = tiles[i];
      final right = i + 1 < tiles.length ? tiles[i + 1] : null;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            SizedBox(width: gap),
            Expanded(child: right ?? const SizedBox.shrink()),
          ],
        ),
      );
      if (i + 2 < tiles.length) {
        rows.add(SizedBox(height: gap));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

class EmojiSolutionTile extends StatelessWidget {
  static const _titleMaxLines = 2;
  static const _subtitleMaxLines = 2;

  final String title;
  final String subtitle;
  final String emoji;
  final Color emojiBackground;
  final VoidCallback onTap;

  const EmojiSolutionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.emojiBackground,
    required this.onTap,
  });

  double _linesHeight(BuildContext context, TextStyle style, int lines) {
    final fontSize = style.fontSize ?? 14;
    final heightFactor = style.height ?? 1.0;
    return MediaQuery.textScalerOf(context).scale(fontSize) * heightFactor * lines;
  }

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.vertical(top: Radius.circular(8));
    final titleStyle = DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleBlueFrance(context));
    final subtitleStyle = DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context));

    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Material(
        color: DsfrColorDecisions.backgroundDefaultGrey(context),
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: DsfrColorDecisions.artworkDecorativeBlueFrance(context)),
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s3w, vertical: DsfrSpacings.s2w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        EmojiTile(
                          emoji: emoji,
                          backgroundColor: emojiBackground,
                          size: DsfrSpacings.s6w,
                          borderRadius: 15,
                        ),
                        const SizedBox(height: DsfrSpacings.s1w),
                        SizedBox(
                          height: _linesHeight(context, titleStyle, _titleMaxLines),
                          width: double.infinity,
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            maxLines: _titleMaxLines,
                            overflow: TextOverflow.ellipsis,
                            style: titleStyle,
                          ),
                        ),
                        const SizedBox(height: DsfrSpacings.s1v),
                        SizedBox(
                          height: _linesHeight(context, subtitleStyle, _subtitleMaxLines),
                          width: double.infinity,
                          child: Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            maxLines: _subtitleMaxLines,
                            overflow: TextOverflow.ellipsis,
                            style: subtitleStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ColoredBox(
                    color: DsfrColorDecisions.borderActionHighBlueFrance(context),
                    child: const SizedBox(height: 4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
