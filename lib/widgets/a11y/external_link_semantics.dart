import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/strings.dart';

/// Ce que fait réellement un lien lorsqu'on l'active.
enum LinkDestination {
  website,
  appStore,
  appSettings,
  mailApp,
  phoneApp,

  /// Navigation interne à l'application : rôle bouton sur Android, sans indication.
  inApp;

  /// Déduit la destination d'un lien à partir de son schéma (mailto, tel, sinon site web).
  static LinkDestination fromUri(Uri uri) {
    return switch (uri.scheme) {
      'mailto' => LinkDestination.mailApp,
      'tel' => LinkDestination.phoneApp,
      _ => LinkDestination.website,
    };
  }

  /// Destinations restituées comme un lien : elles mènent à une page (site, fiche du store, e-mail, appel).
  bool get isLink => switch (this) {
    LinkDestination.website || LinkDestination.appStore || LinkDestination.mailApp || LinkDestination.phoneApp => true,
    LinkDestination.appSettings || LinkDestination.inApp => false,
  };

  /// Indication des destinations restituées comme un bouton sur Android.
  String? get hint => switch (this) {
    LinkDestination.appSettings => Strings.a11yOpensAppSettings,
    _ => null,
  };
}

/// Sémantique d'un lien (site externe par défaut, voir [LinkDestination]).
///
/// A11y 5.1 (audit RAAM du 15/10/2026) : un composant qui mène à une page est restitué comme un lien,
/// sans indication d'ouverture dans le navigateur ni rôle écrit dans le nom.
/// - iOS : rôle `link`, annoncé « Lien » par VoiceOver.
/// - Android : le moteur Flutter n'expose pas `link: true` à TalkBack. En revanche, `linkUrl` transforme le nom
///   accessible en `URLSpan` : c'est la technique de lien native d'Android (texte avec URLSpan), qui permet à
///   TalkBack d'annoncer « Lien » et de proposer l'élément dans son menu « Liens ». Il faut donc fournir [url].
///   Sans [url], ou pour les destinations qui ne sont pas des pages (réglages, navigation interne), le composant
///   reste un bouton.
class ExternalLinkSemantics extends StatelessWidget {
  const ExternalLinkSemantics({
    super.key,
    this.label,
    required this.onTap,
    required this.child,
    this.url,
    this.hint,
    this.destination = LinkDestination.website,
    this.excludeSemantics = true,
  });

  /// Peut être omis lorsque le libellé est déjà porté par le contenu (avec `excludeSemantics: false`).
  final String? label;
  final VoidCallback? onTap;
  final Widget child;

  /// Adresse ouverte par le lien : sur Android, c'est elle qui donne le rôle lien (voir la documentation de la classe).
  final String? url;

  /// Précise la destination quand le libellé visible ne la dit pas (ex. « Pas vraiment » ouvre un formulaire).
  /// Ne doit pas indiquer le rôle ni l'ouverture dans le navigateur.
  final String? hint;
  final LinkDestination destination;

  /// À passer à false lorsque le contenu porte d'autres éléments accessibles (ex. bouton de fermeture d'une tuile).
  final bool excludeSemantics;

  @override
  Widget build(BuildContext context) {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final linkUrl = destination.isLink ? _parse(url) : null;
    final androidButton = isAndroid && linkUrl == null;
    return Semantics(
      container: true,
      link: !androidButton,
      linkUrl: linkUrl,
      button: androidButton,
      label: label,
      hint: hint ?? (androidButton ? destination.hint : null),
      onTap: onTap,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  static Uri? _parse(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    return Uri.tryParse(url.trim());
  }
}
