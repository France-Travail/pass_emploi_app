import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/accueil/message_informatif.dart';

class Communications extends Equatable {
  final MessageInformatif? messageInformatif;

  const Communications({this.messageInformatif});

  factory Communications.fromJson(dynamic json) {
    return Communications(
      messageInformatif: MessageInformatif.fromJson(json["messageInformatif"]),
    );
  }

  @override
  List<Object?> get props => [messageInformatif];
}
