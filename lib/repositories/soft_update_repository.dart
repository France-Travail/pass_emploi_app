import 'package:clock/clock.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pass_emploi_app/configuration/app_version_checker.dart';
import 'package:pass_emploi_app/wrappers/package_info_wrapper.dart';

class SoftUpdateRepository {
  final FlutterSecureStorage _preferences;
  final Future<String> Function() _getCurrentVersion;

  SoftUpdateRepository(
    this._preferences, {
    Future<String> Function()? getCurrentVersion,
  }) : _getCurrentVersion = getCurrentVersion ?? PackageInfoWrapper.getVersion;

  static const String _key = 'soft-update-dismissed-at';
  static const Duration _dismissDuration = Duration(hours: 24);

  Future<bool> shouldShowSoftUpdate(String? softUpdateVersion) async {
    if (softUpdateVersion == null) return false;

    final currentVersion = await _getCurrentVersion();
    if (!AppVersionChecker().shouldSoftUpdate(
      currentVersion: currentVersion,
      softUpdateVersion: softUpdateVersion,
    )) {
      return false;
    }

    final dismissedAt = await _readDismissedAt();
    if (dismissedAt != null && clock.now().difference(dismissedAt) < _dismissDuration) {
      return false;
    }

    return true;
  }

  Future<void> dismiss() async {
    await _preferences.write(key: _key, value: clock.now().millisecondsSinceEpoch.toString());
  }

  Future<DateTime?> _readDismissedAt() async {
    final value = await _preferences.read(key: _key);
    if (value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(value));
  }
}
