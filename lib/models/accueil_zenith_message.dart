import 'package:pass_emploi_app/models/login_page_remote_message.dart';

class AccueilZenithMessage extends RemoteMessage {
  AccueilZenithMessage({
    required super.title,
    required super.description,
  });

  static AccueilZenithMessage? fromJson(Map<String, dynamic> json) {
    final dateDebut = DateTime.fromMillisecondsSinceEpoch(json['dateDebut'] as int);
    final dateFin = DateTime.fromMillisecondsSinceEpoch(json['dateFin'] as int);

    if (dateDebut.isAfter(DateTime.now()) || dateFin.isBefore(DateTime.now())) {
      return null;
    }

    return AccueilZenithMessage(
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}
