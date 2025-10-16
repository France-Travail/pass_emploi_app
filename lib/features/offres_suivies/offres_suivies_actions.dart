import 'package:pass_emploi_app/features/offres_suivies/offres_suivies_state.dart';
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
  final ConfirmationOffre? confirmationOffre;
  final List<String> blackListedOffreIds;

  OffresSuiviesToStateAction(this.offresSuivies, {this.confirmationOffre, this.blackListedOffreIds = const []});
}
