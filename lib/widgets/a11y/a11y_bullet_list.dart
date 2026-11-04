import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';

/// Liste à puces restituée comme une liste par les lecteurs d'écran (A11y 7.2).
///
/// Le moteur Flutter n'expose de structure de liste à TalkBack et VoiceOver que pour les listes défilantes. Pour une
/// liste à puces, la structure est donc donnée dans le texte restitué (WCAG 1.3.1, « disponible sous forme de texte ») :
/// « Liste de 3 éléments » avant le premier élément, et sa position (« 1 sur 3 ») après chaque élément.
/// La puce visuelle n'est pas lue.
class A11yBulletList extends StatelessWidget {
  const A11yBulletList({
    super.key,
    required this.items,
    this.textStyle,
    this.padding = const EdgeInsets.only(left: DsfrSpacings.s3w, bottom: DsfrSpacings.s1v),
  });

  final List<String> items;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final style = textStyle ?? DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++)
          A11yListItem(
            index: i,
            count: items.length,
            text: items[i],
            child: Padding(
              padding: padding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•', style: style),
                  const SizedBox(width: DsfrSpacings.s1w),
                  Expanded(child: Text(items[i], style: style)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Élément d'une liste, restitué en un seul arrêt : « [Liste de N éléments.] texte, position sur N ».
///
/// [child] est l'affichage de l'élément (puce comprise) ; son contenu n'est pas lu, seul [text] l'est.
/// Un élément interactif voisin (ex. info-bulle) doit donc être placé à côté, pas dans [child].
class A11yListItem extends StatelessWidget {
  const A11yListItem({
    super.key,
    required this.index,
    required this.count,
    required this.text,
    required this.child,
  });

  final int index;
  final int count;
  final String text;
  final Widget child;

  static String label({required int index, required int count, required String text}) {
    // Un élément seul n'est pas annoncé comme une liste.
    if (count == 1) return text;
    final item = '$text, ${Strings.a11yListPosition(index + 1, count)}';
    return index == 0 ? '${Strings.a11yListIntro(count)}. $item' : item;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: label(index: index, count: count, text: text),
      excludeSemantics: true,
      child: child,
    );
  }
}

/// Bloc d'un texte libre découpé en lignes : un paragraphe, ou une liste de lignes consécutives à puces ou à tirets
/// (« - Contrat : CDI », « • … », « o … »), pour restituer ces lignes comme une liste (A11y 7.2).
class DescriptionBlock {
  const DescriptionBlock._(this.lines, {required this.isList});

  /// Lignes affichées telles quelles (puce comprise).
  final List<String> lines;
  final bool isList;

  /// Texte des éléments de liste, sans leur puce.
  List<String> get items => lines.map((line) => line.replaceFirst(_bulletRegExp, '').trim()).toList();

  static final _bulletRegExp = RegExp(r'^\s*([-–—•*·▪●◦]|o(?=\s))\s*');

  static bool _isBullet(String line) =>
      _bulletRegExp.hasMatch(line) && line.replaceFirst(_bulletRegExp, '').trim().isNotEmpty;

  static List<DescriptionBlock> fromParagraphs(List<String> paragraphs) {
    final blocks = <DescriptionBlock>[];
    var currentList = <String>[];
    void closeList() {
      if (currentList.isEmpty) return;
      blocks.add(DescriptionBlock._(currentList, isList: true));
      currentList = <String>[];
    }

    for (final paragraph in paragraphs) {
      if (_isBullet(paragraph)) {
        currentList.add(paragraph);
      } else {
        closeList();
        blocks.add(DescriptionBlock._([paragraph], isList: false));
      }
    }
    closeList();
    return blocks;
  }
}
