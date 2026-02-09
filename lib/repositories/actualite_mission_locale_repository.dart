import 'package:dio/dio.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:pass_emploi_app/models/actualite_mission_locale.dart';

class ActualiteMissionLocaleRepository {
  final Dio _httpClient;
  final Crashlytics? _crashlytics;

  ActualiteMissionLocaleRepository(this._httpClient, [this._crashlytics]);

  Future<List<ActualiteMissionLocale>?> get() async {
    final url = "/jeunes/todo";
    try {
      // final response = await _httpClient.get(url);
      return [
        ActualiteMissionLocale(
          id: '1',
          titre: 'Titre',
          corps: 'Corps',
          titreDuLien: 'Titre du lien',
          lien: 'Lien',
          nomConseiller: 'Nom conseiller',
          dateCreation: DateTime.now().subtract(Duration(days: 1)),
        ),
        ActualiteMissionLocale(
          id: '2',
          titre: 'Titre 2',
          corps: 'Corps 2',
          titreDuLien: 'Titre du lien 2',
          lien: 'Lien 2',
          nomConseiller: 'Nom conseiller 2',
          dateCreation: DateTime.now().subtract(Duration(days: 2)),
        ),
        ActualiteMissionLocale(
          id: '3',
          titre: 'Titre 3',
          corps: 'Corps 3',
          titreDuLien: 'Titre du lien 3',
          lien: 'Lien 3',
          nomConseiller: 'Nom conseiller 3',
          dateCreation: DateTime.now().subtract(Duration(days: 3)),
        ),
      ];
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
    }
    return null;
  }
}
