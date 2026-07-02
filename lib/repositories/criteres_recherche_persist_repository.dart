import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pass_emploi_app/models/criteres_recherche_utilisateur.dart';
import 'package:pass_emploi_app/models/location.dart';

class CriteresRecherchePersistRepository {
  final FlutterSecureStorage _preferences;

  CriteresRecherchePersistRepository(this._preferences);

  static const _key = 'criteresRecherchePersist';
  static const _legacyLocalisationKey = 'localisationPersist';

  Future<void> save(CriteresRechercheUtilisateur criteres) async {
    await _preferences.write(key: _key, value: json.encode(criteres.toJson()));
  }

  Future<CriteresRechercheUtilisateur?> get() async {
    final result = await _preferences.read(key: _key);
    if (result != null) return CriteresRechercheUtilisateur.fromJson(json.decode(result));
    return _migrateFromLegacyLocalisation();
  }

  Future<CriteresRechercheUtilisateur?> _migrateFromLegacyLocalisation() async {
    final legacy = await _preferences.read(key: _legacyLocalisationKey);
    if (legacy == null) return null;
    final criteres = CriteresRechercheUtilisateur(location: Location.fromJson(json.decode(legacy)));
    await save(criteres);
    await _preferences.delete(key: _legacyLocalisationKey);
    return criteres;
  }
}
