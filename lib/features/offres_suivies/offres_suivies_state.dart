import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/favori.dart';
import 'package:pass_emploi_app/models/offre_suivie.dart';

class OffresSuiviesState extends Equatable {
  final List<OffreSuivie> offresSuivies;
  final List<String> blackListedOffreIds;
  final ConfirmationOffre? confirmationOffre;

  OffresSuiviesState({this.offresSuivies = const [], this.confirmationOffre, this.blackListedOffreIds = const []});

  @override
  List<Object?> get props => [offresSuivies, confirmationOffre, blackListedOffreIds];
}

extension OffresSuiviesStateExt on OffresSuiviesState {
  bool isPresent(String offreId) => offresSuivies.any((offreSuivie) => offreSuivie.offreDto.id == offreId);
  OffreSuivie? getOffre(String offreId) =>
      offresSuivies.firstWhereOrNull((offreSuivie) => offreSuivie.offreDto.id == offreId);
}

class ConfirmationOffre extends Equatable {
  final String offreId;
  final FavoriStatus newStatus;

  ConfirmationOffre({
    required this.offreId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [offreId, newStatus];
}
