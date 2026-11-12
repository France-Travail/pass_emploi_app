import 'package:dio/dio.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:pass_emploi_app/network/json_encoder.dart';
import 'package:pass_emploi_app/network/patch_details_jeune.dart';
import 'package:pass_emploi_app/utils/string_extensions.dart';

/// Date de signature des CGU d'un jeune ; [date] est nulle s'il ne les a jamais acceptées.
class CguSignature {
  final DateTime? date;

  const CguSignature(this.date);
}

class CguRepository {
  final Dio _httpClient;
  final Crashlytics? _crashlytics;

  CguRepository(this._httpClient, [this._crashlytics]);

  /// Renvoie null en cas d'échec de la lecture (à distinguer d'un jeune n'ayant jamais accepté les CGU).
  Future<CguSignature?> get(String userId, {required bool isInvite}) async {
    final url = isInvite ? "/jeunes/$userId/invite/cgu" : "/jeunes/$userId/cgu";
    try {
      final response = await _httpClient.get(url);
      return CguSignature((response.data["dateSignatureCGU"] as String?)?.toDateTimeUtcOnLocalTimeZone());
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
    }
    return null;
  }

  Future<bool> save(String userId, DateTime dateSignatureCgu, {required bool isInvite}) async {
    final url = isInvite ? "/jeunes/$userId/invite/cgu" : "/jeunes/$userId";
    try {
      final data = customJsonEncode(PatchDetailsJeune(dateSignatureCgu));
      if (isInvite) {
        await _httpClient.put(url, data: data);
      } else {
        await _httpClient.patch(url, data: data);
      }
      return true;
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
    }
    return false;
  }

  /// Supprime le compte invité (refus des CGU). Doit être appelé avec le jeton invité, avant la déconnexion.
  Future<bool> deleteInvite(String userId) async {
    final url = "/jeunes/$userId/invite";
    try {
      await _httpClient.delete(url);
      return true;
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
    }
    return false;
  }
}
