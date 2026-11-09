import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pass_emploi_app/features/mode_demo/is_mode_demo_repository.dart';
import 'package:pass_emploi_app/features/mode_demo/mode_demo_exception.dart';
import 'package:pass_emploi_app/features/mode_demo/mode_demo_files.dart';
import 'package:pass_emploi_app/features/mode_demo/mode_demo_offline.dart';
import 'package:pass_emploi_app/features/mode_demo/plan_action/mode_demo_plan_action.dart';
import 'package:pass_emploi_app/network/interceptors/pass_emploi_base_interceptor.dart';
import 'package:pass_emploi_app/utils/asset_bundle_extensions.dart';
import 'package:pass_emploi_app/utils/log.dart';

class DemoInterceptor extends PassEmploiBaseInterceptor {
  final ModeDemoRepository demoRepository;

  DemoInterceptor(this.demoRepository);

  // Mode démo : aucune requête ne part, pas même vers un autre serveur que l'API.
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (demoRepository.isModeDemo() && !options.isPassEmploiRequest()) {
      respondWithoutNetwork(options, handler);
      return;
    }
    super.onRequest(options, handler);
  }

  @override
  void onPassEmploiRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    throwModeDemoExceptionIfNecessary(options.method == "GET", options.uri);

    if (!demoRepository.isModeDemo()) {
      handler.next(options);
      return;
    }

    final planAction = ModeDemoPlanAction.instance;
    final planActionResponse = await planAction.respond(options);
    if (planActionResponse != null) {
      if (planAction.isGeneration(options)) await Future<void>.delayed(ModeDemoPlanAction.generationDuration);
      handler.resolve(planActionResponse);
      return;
    }

    final referentielResponse = modeDemoReferentielResponse(options);
    if (referentielResponse != null) {
      handler.resolve(referentielResponse);
      return;
    }

    if (!options.uri.toString().isSupposedToBeMocked()) {
      respondWithoutNetwork(options, handler);
      return;
    }

    Log.i("Intercepting demo request for ${options.uri.path}.");
    final demoFileName = getDemoFileName(options.uri.path, options.uri.query);
    if (options.method == "GET") {
      handler.resolve(Response(requestOptions: options, data: await _readFile(demoFileName!), statusCode: 200));
    } else {
      handler.resolve(Response(requestOptions: options, statusCode: 201));
    }
  }

  Future<dynamic> _readFile(String stringUrl) async {
    final now = DateTime.now();
    final dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
    return rootBundle
        .loadDemoAsset(stringUrl)
        .then(
          (json) => json.replaceAllMapped(
            RegExp(r'(<NOW_PLUS_)(\d+)(>)'),
            (Match m) => dateFormat.format(now.add(Duration(days: int.parse(m[2]!)))),
          ),
        )
        .then(
          (json) => json.replaceAllMapped(
            RegExp(r'(<NOW_LESS_)(\d+)(>)'),
            (Match m) => dateFormat.format(now.subtract(Duration(days: int.parse(m[2]!)))),
          ),
        )
        .then((json) => jsonDecode(json));
  }
}
