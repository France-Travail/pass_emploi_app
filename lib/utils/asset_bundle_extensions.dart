import 'package:flutter/services.dart';
import 'package:pass_emploi_app/models/brand.dart';

const _modeDemoGenericFolder = "assets/mode_demo/";
const _modeDemoCejFolder = "assets/mode_demo/cej/";
const _modeDemoBrsaFolder = "assets/mode_demo/brsa/";
const _jsonExtension = ".json";

extension AssetBundleExtensions on AssetBundle {
  Future<String> loadDemoAsset(String stringUrl) async {
    if (await _specificFileExistsForBrand(stringUrl)) return loadString(_getSpecificPathForBrand(stringUrl));
    return loadString(_getPath(stringUrl));
  }

  Future<bool> _specificFileExistsForBrand(String stringUrl) async {
    try {
      await loadString(_getSpecificPathForBrand(stringUrl));
      return true;
    } catch (e) {
      return false;
    }
  }

  String _getSpecificPathForBrand(String stringUrl) {
    switch(Brand.brand){
      case Brand.cej:
        return _modeDemoCejFolder + stringUrl + _jsonExtension;
      case Brand.brsa:
        return _modeDemoBrsaFolder + stringUrl + _jsonExtension;
    }
  }

  String _getPath(String stringUrl) => _modeDemoGenericFolder + stringUrl + _jsonExtension;
}
