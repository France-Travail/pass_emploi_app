import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pass_emploi_app/models/offre_suivie.dart';

const _maxLength = 20;
const _maxBlacklistedLength = 100;

class OffresSuiviesRepository {
  static const _keyOffreSuivies = "offres_suivies";
  static const _keyBlacklisted = "offres_suivies_blacklisted";

  final FlutterSecureStorage secureStorage;

  OffresSuiviesRepository(this.secureStorage);

  Future<List<String>> getBlacklistedOffreIds() async {
    final result = await secureStorage.read(key: _keyBlacklisted);
    if (result == null) return [];
    final decoded = json.decode(result) as List<dynamic>;
    return List<String>.from(decoded);
  }

  Future<void> blacklistOffreIds(String offreId) async {
    final blacklistedIds = await getBlacklistedOffreIds();

    if (!blacklistedIds.contains(offreId)) {
      blacklistedIds.add(offreId);

      final limitedIds = blacklistedIds.length > _maxBlacklistedLength
          ? blacklistedIds.sublist(blacklistedIds.length - _maxBlacklistedLength)
          : blacklistedIds;

      await secureStorage.write(key: _keyBlacklisted, value: json.encode(limitedIds));
    }
  }

  Future<List<OffreSuivie>> getOffresSuivies() async {
    final result = await secureStorage.read(key: _keyOffreSuivies);
    if (result == null) return [];
    return result.deserialize();
  }

  Future<List<OffreSuivie>> setOffreSuivie(OffreSuivie offre) async {
    final offres = await getOffresSuivies();

    final existeDeja = offres.any((o) => o.offreDto == offre.offreDto);

    if (!existeDeja) {
      offres.add(offre);
      final newOffres = offres.removeOldestEntryIfRequired();
      await secureStorage.write(key: _keyOffreSuivies, value: newOffres.serialize());

      return newOffres;
    }

    return offres;
  }

  Future<List<OffreSuivie>> delete(OffreSuivie offre) async {
    final offres = await getOffresSuivies();
    offres.remove(offre);
    await secureStorage.write(key: _keyOffreSuivies, value: offres.serialize());
    return offres;
  }
}

extension on List<OffreSuivie> {
  String serialize() {
    final List<Map<String, dynamic>> offres = map((offre) {
      return offre.toJson();
    }).toList();
    return jsonEncode(offres);
  }

  List<OffreSuivie> removeOldestEntryIfRequired() {
    return length > _maxLength ? sublist(length - _maxLength) : this;
  }
}

extension on String {
  List<OffreSuivie> deserialize() {
    try {
      final offres = List<Map<String, dynamic>>.from(json.decode(this) as List<dynamic>);
      return offres.map((offre) {
        return OffreSuivie.fromJson(offre);
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
