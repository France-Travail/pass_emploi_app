import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/strings.dart';

/// Ce que fait réellement un lien lorsqu'on l'active, pour l'indication annoncée sur Android.
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

  String? get hint => switch (this) {
        LinkDestination.website => Strings.a11yOpensExternalSite,
        LinkDestination.appStore => Strings.a11yOpensAppStore,
        LinkDestination.appSettings => Strings.a11yOpensAppSettings,
        LinkDestination.mailApp => Strings.a11yOpensMailApp,
        LinkDestination.phoneApp => Strings.a11yOpensPhoneApp,
        LinkDestination.inApp => null,
      };
}

/// Sémantique d'un lien (site externe par défaut, voir [LinkDestination]).
///
/// A11y 5.1 : sur Android, `link: true` n'est annoncé ni comme rôle ni comme action possible par TalkBack.
/// On expose donc un bouton avec une indication adaptée (ex. « Ouvre le site dans ton navigateur »).
/// Sur iOS, le rôle `link` de VoiceOver est conservé tel quel.
class ExternalLinkSemantics extends StatelessWidget {
  const ExternalLinkSemantics({
    super.key,
    this.label,
    required this.onTap,
    required this.child,
    this.destination = LinkDestination.website,
    this.excludeSemantics = true,
  });

  /// Peut être omis lorsque le libellé est déjà porté par le contenu (avec `excludeSemantics: false`).
  final String? label;
  final VoidCallback? onTap;
  final Widget child;
  final LinkDestination destination;

  /// À passer à false lorsque le contenu porte d'autres éléments accessibles (ex. bouton de fermeture d'une tuile).
  final bool excludeSemantics;

  @override
  Widget build(BuildContext context) {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    return Semantics(
      container: true,
      link: !isAndroid,
      button: isAndroid,
      label: label,
      hint: isAndroid ? destination.hint : null,
      onTap: onTap,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }
}
