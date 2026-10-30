import 'package:dio/dio.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';

// Passe par notre API (routes /referentiels/rome) avec le client HTTP de l'app : connexion et mode démo compris.
class RomeApiClient {
  RomeApiClient._();

  static final instance = RomeApiClient._();

  late Dio _dio;
  List<RomeCentreInteret>? _centresInteret;
  List<RomeMetierResume>? _metiersAvecRiasec;
  final _metiersParCentreInteret = <String, List<RomeMetierResume>>{};
  final _fiches = <String, RomeFicheMetier>{};

  void utiliser(Dio dio) => _dio = dio;

  Future<List<RomeCentreInteret>> centresInteret() async {
    if (_centresInteret case final centres?) return centres;
    final json = await _get('/referentiels/rome/centres-interet') as List<dynamic>;
    return _centresInteret = json.map(RomeCentreInteret.fromJson).toList();
  }

  Future<List<RomeMetierResume>> metiersDuCentreInteret(String code) async {
    if (_metiersParCentreInteret[code] case final metiers?) return metiers;
    final json = await _get('/referentiels/rome/centres-interet/$code/metiers');
    final metiers = (json['metiers'] as List<dynamic>? ?? const []).map(RomeMetierResume.fromJson).toList();
    return _metiersParCentreInteret[code] = metiers;
  }

  Future<List<RomeMetierResume>> metiersAvecRiasec() async {
    if (_metiersAvecRiasec case final metiers?) return metiers;
    final json = await _get('/referentiels/rome/metiers') as List<dynamic>;
    return _metiersAvecRiasec = json.map(RomeMetierResume.fromJson).toList();
  }

  Future<RomeFicheMetier> ficheMetier(String code) async {
    if (_fiches[code] case final fiche?) return fiche;
    return _fiches[code] = RomeFicheMetier.fromJson(await _get('/referentiels/rome/metiers/$code'));
  }

  Future<dynamic> _get(String chemin) async => (await _dio.get<dynamic>(chemin)).data;
}
