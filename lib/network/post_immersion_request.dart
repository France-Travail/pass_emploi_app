import 'package:pass_emploi_app/models/immersion_contact.dart';
import 'package:pass_emploi_app/models/requests/contact_immersion_request.dart';
import 'package:pass_emploi_app/network/json_serializable.dart';

class PostContactImmersionRequest implements JsonSerializable {
  final ContactImmersionRequest request;

  PostContactImmersionRequest(this.request);

  @override
  Map<String, dynamic> toJson() {
    final map = {
      "appellationCode": request.immersionDetails.appellationCode,
      "labelRome": request.immersionDetails.metier,
      "siret": request.immersionDetails.siret,
      "locationId": request.immersionDetails.locationId,
      "numeroTelephone": request.userInput.telephone,
      "prenom": request.userInput.firstName,
      "nom": request.userInput.lastName,
      "email": request.userInput.email,
      "contactMode": request.immersionDetails.contactMode.toJson(),
      "datePreferences": request.userInput.datePreferences,
      "experienceAdditionalInformation": request.userInput.experience,
      "resumeLink": request.userInput.linkedinOrCvUrl,
    };
    return map;
  }
}
