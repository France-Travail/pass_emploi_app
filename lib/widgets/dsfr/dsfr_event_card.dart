import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/widgets/dsfr/emoji_tile.dart';

/// Carte événement DSFR — icône agenda à gauche, contenu type Mon suivi.
class DsfrEventCard extends StatelessWidget {
  const DsfrEventCard({
    super.key,
    required this.onTap,
    required this.child,
    this.semanticsLabel,
    this.emoji,
    this.emojiBackgroundColor,
  });

  final VoidCallback onTap;
  final Widget child;
  final String? semanticsLabel;
  final String? emoji;
  final Color? emojiBackgroundColor;

  static const _radius = BorderRadius.all(Radius.circular(4));

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: _radius,
      side: BorderSide(color: DsfrColorDecisions.borderDefaultGrey(context)),
    );

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: DsfrColorDecisions.backgroundDefaultGrey(context),
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: Padding(
            padding: const EdgeInsets.all(DsfrSpacings.s3v),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (emoji != null && emojiBackgroundColor != null) ...[
                  _buildLeading(emoji: emoji!, emojiBackgroundColor: emojiBackgroundColor!),
                  const SizedBox(width: DsfrSpacings.s2w),
                ],
                Expanded(
                  child: semanticsLabel != null ? ExcludeSemantics(child: child) : child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading({required String emoji, required Color emojiBackgroundColor}) {
    return EmojiTile(
      emoji: emoji,
      backgroundColor: emojiBackgroundColor,
      size: DsfrSpacings.s6w,
      borderRadius: 8,
      emojiSize: DsfrSpacings.s3w,
    );
  }
}

class DsfrEventCardComplement extends StatelessWidget {
  const DsfrEventCardComplement({
    super.key,
    required this.icon,
    required this.text,
    this.semanticsLabel,
  });

  final IconData icon;
  final String text;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final color = DsfrColorDecisions.textDefaultGrey(context);
    return Semantics(
      label: semanticsLabel,
      child: Row(
        children: [
          Icon(icon, size: DsfrSpacings.s2w, color: color),
          const SizedBox(width: DsfrSpacings.s1v),
          Expanded(
            child: ExcludeSemantics(
              excluding: semanticsLabel != null,
              child: Text(
                text,
                style: DsfrTextStyle.bodySm(color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
