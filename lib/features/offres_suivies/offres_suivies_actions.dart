import 'package:pass_emploi_app/models/offre_dto.dart';
import 'package:pass_emploi_app/models/offre_suivie.dart';

class OffresSuiviesWriteAction {
  final OffreDto offreDto;

  OffresSuiviesWriteAction(this.offreDto);
}

class OffresSuiviesBlacklistAction {
  final String offreId;

  OffresSuiviesBlacklistAction(this.offreId);
}

class OffresSuiviesDeleteAction {
  final OffreSuivie offreSuivie;

  OffresSuiviesDeleteAction(this.offreSuivie);
}

class OffresSuiviesConfirmationResetAction {}

class OffresSuiviesToStateAction {
  final List<OffreSuivie> offresSuivies;
  final String? confirmationOffreId;
  final List<String> blackListedOffreIds;

  OffresSuiviesToStateAction(this.offresSuivies, {this.confirmationOffreId, this.blackListedOffreIds = const []});
}
