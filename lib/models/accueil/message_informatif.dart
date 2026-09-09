import 'package:equatable/equatable.dart';

class MessageInformatif extends Equatable {
  final String id;
  final String titre;
  final String contenu;
  final MessageInformatifCta? cta;

  const MessageInformatif({
    required this.id,
    required this.titre,
    required this.contenu,
    this.cta,
  });

  static MessageInformatif? fromJson(dynamic json) {
    if (json == null) return null;
    return MessageInformatif(
      id: json["id"] as String,
      titre: json["titre"] as String,
      contenu: json["contenu"] as String,
      cta: MessageInformatifCta.fromJson(json["cta"]),
    );
  }

  @override
  List<Object?> get props => [id, titre, contenu, cta];
}

class MessageInformatifCta extends Equatable {
  final String label;
  final String urlAndroid;
  final String urlIos;

  const MessageInformatifCta({
    required this.label,
    required this.urlAndroid,
    required this.urlIos,
  });

  static MessageInformatifCta? fromJson(dynamic json) {
    if (json == null) return null;
    return MessageInformatifCta(
      label: json["label"] as String,
      urlAndroid: json["urlAndroid"] as String,
      urlIos: json["urlIos"] as String,
    );
  }

  String url({required bool isAndroid}) => isAndroid ? urlAndroid : urlIos;

  @override
  List<Object?> get props => [label, urlAndroid, urlIos];
}
