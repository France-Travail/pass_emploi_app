import 'package:dio/dio.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_config.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';

class RomeApiClient {
  RomeApiClient._();

  static final instance = RomeApiClient._();

  // Le jeton ne doit ouvrir que ROME, même si l'application France Travail a d'autres accès.
  static const _scope = 'api_rome-metiersv1 nomenclatureRome';
  static const _metiers = '/rome-metiers/v1/metiers';

  final _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 30)));
  String? _token;
  DateTime _tokenExpiry = DateTime.fromMillisecondsSinceEpoch(0);
  List<RomeCentreInteret>? _centresInteret;
  List<RomeMetierResume>? _metiersAvecRiasec;
  final _metiersParCentreInteret = <String, List<RomeMetierResume>>{};
  final _fiches = <String, RomeFicheMetier>{};

  Future<List<RomeCentreInteret>> centresInteret() async {
    if (_centresInteret case final centres?) return centres;
    final json = await _get('$_metiers/centre-interet?champs=code,libelle') as List<dynamic>;
    return _centresInteret = json.map(RomeCentreInteret.fromJson).toList();
  }

  Future<List<RomeMetierResume>> metiersDuCentreInteret(String code) async {
    if (_metiersParCentreInteret[code] case final metiers?) return metiers;
    final json = await _get('$_metiers/centre-interet/$code?champs=code,libelle,metiers(code,libelle)');
    final metiers = (json['metiers'] as List<dynamic>? ?? const []).map(RomeMetierResume.fromJson).toList();
    return _metiersParCentreInteret[code] = metiers;
  }

  Future<List<RomeMetierResume>> metiersAvecRiasec() async {
    if (_metiersAvecRiasec case final metiers?) return metiers;
    final json = await _get(
      '$_metiers/metier?champs=code,libelle,riasecMajeur,riasecMineur,domaineProfessionnel(libelle,grandDomaine(code,libelle))',
    ) as List<dynamic>;
    return _metiersAvecRiasec = json.map(RomeMetierResume.fromJson).toList();
  }

  Future<RomeFicheMetier> ficheMetier(String code) async {
    if (_fiches[code] case final fiche?) return fiche;
    return _fiches[code] = RomeFicheMetier.fromJson(await _get('$_metiers/metier/$code'));
  }

  Future<dynamic> _get(String path, {int essai = 1}) async {
    final token = await _accessToken();
    try {
      final response = await _dio.get<dynamic>(
        '${PocOrientationConfig.apiBaseUrl}$path',
        options: Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'}),
      );
      return response.data;
    } on DioException catch (e) {
      // ROME n'accepte qu'un appel par seconde pour toute l'application France Travail.
      if (e.response?.statusCode == 429 && essai < 3) {
        await Future<void>.delayed(const Duration(milliseconds: 1100));
        return _get(path, essai: essai + 1);
      }
      rethrow;
    }
  }

  Future<String> _accessToken() async {
    if (_token case final token? when DateTime.now().isBefore(_tokenExpiry)) return token;
    final response = await _dio.post<Map<String, dynamic>>(
      '${PocOrientationConfig.loginUrl}?realm=%2Fpartenaire',
      data: {
        'grant_type': 'client_credentials',
        'client_id': PocOrientationConfig.clientId,
        'client_secret': PocOrientationConfig.clientSecret,
        'scope': _scope,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final expiresIn = response.data!['expires_in'] as int;
    _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60));
    return _token = response.data!['access_token'] as String;
  }
}
