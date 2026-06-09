import 'package:pass_emploi_app/models/version.dart';

class AppVersionChecker {
  bool shouldForceUpdate({String? currentVersion, String? minimumVersion}) {
    return _isUpdateRequired(currentVersion: currentVersion, targetVersion: minimumVersion);
  }

  bool shouldSoftUpdate({String? currentVersion, String? softUpdateVersion}) {
    return _isUpdateRequired(currentVersion: currentVersion, targetVersion: softUpdateVersion);
  }

  bool _isUpdateRequired({String? currentVersion, String? targetVersion}) {
    final Version? current = currentVersion != null ? Version.fromString(currentVersion) : null;
    final Version? target = targetVersion != null ? Version.fromString(targetVersion) : null;
    if (current == null || target == null) return false;
    return current < target;
  }
}
