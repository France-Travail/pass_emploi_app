import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

sealed class FilePickerResult {}

class FilePickerSuccessResult extends FilePickerResult {
  final String path;
  final bool isTooLarge;

  FilePickerSuccessResult({required this.path, required this.isTooLarge});
}

class FilePickerEmptyResult extends FilePickerResult {}

class FilePickerErrorResult extends FilePickerResult {}

class FilePickerPermissionErrorResult extends FilePickerResult {}

class FilePickerWrapper {
  static const int maxFilesize = 5 * 1024 * 1024;
  static Future<FilePickerResult> pickFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'odt', 'ods'],
      );
      if (file == null) return FilePickerEmptyResult();
      final path = file.path;
      if (path == null) return FilePickerErrorResult();
      final size = file.lengthSync() ?? await file.length() ?? 0;
      return FilePickerSuccessResult(path: path, isTooLarge: size > maxFilesize);
    } catch (e) {
      if (e is PlatformException && e.code == "read_external_storage_denied") {
        return FilePickerPermissionErrorResult();
      }
    }
    return FilePickerErrorResult();
  }
}
