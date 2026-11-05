import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:pass_emploi_app/auth/auth_access_checker.dart';
import 'package:pass_emploi_app/auth/auth_access_token_retriever.dart';
import 'package:pass_emploi_app/features/mode_demo/is_mode_demo_repository.dart';
import 'package:pass_emploi_app/network/cache_manager.dart';
import 'package:pass_emploi_app/network/interceptors/auth_interceptor.dart';
import 'package:pass_emploi_app/network/interceptors/cache_interceptor.dart';
import 'package:pass_emploi_app/network/interceptors/demo_interceptor.dart';
import 'package:pass_emploi_app/network/interceptors/expired_token_interceptor.dart';
import 'package:pass_emploi_app/network/interceptors/logging_interceptor.dart';
import 'package:pass_emploi_app/network/interceptors/logout_after_too_many_401_interceptor.dart';
import 'package:pass_emploi_app/network/interceptors/monitoring_interceptor.dart';

class PassEmploiDioBuilder {
  /// Since dio_cache_interceptor 4, codes are an allow-list (formerly `hitCacheOnErrorExcept: [401, 403, 404]`).
  /// To keep the same behaviour, we serve the cache on any non-2xx status code except those ones.
  static final List<int> _hitCacheOnErrorCodes = [
    for (var code = 100; code < 600; code++)
      if ((code < 200 || code >= 300) && ![401, 403, 404].contains(code)) code,
  ];

  final String baseUrl;
  final CacheStore cacheStore;
  final ModeDemoRepository modeDemoRepository;
  final AuthAccessTokenRetriever accessTokenRetriever;
  final AuthAccessChecker authAccessChecker;
  final MonitoringInterceptor monitoringInterceptor;
  final LogoutAfterTooMany401Interceptor unauthorizedInterceptor;

  PassEmploiDioBuilder({
    required this.baseUrl,
    required this.cacheStore,
    required this.modeDemoRepository,
    required this.accessTokenRetriever,
    required this.authAccessChecker,
    required this.monitoringInterceptor,
    required this.unauthorizedInterceptor,
  });

  Dio build() {
    final cacheOptions = CacheOptions(
      store: cacheStore,
      hitCacheOnNetworkFailure: true,
      hitCacheOnErrorCodes: _hitCacheOnErrorCodes,
      policy: CachePolicy.request,
      keyBuilder: ({required url, headers, body}) => PassEmploiCacheManager.getCacheKey(url.toString()),
    );
    final dioClient = Dio(BaseOptions(baseUrl: baseUrl));
    dioClient.interceptors
      ..add(DemoInterceptor(modeDemoRepository))
      ..add(monitoringInterceptor)
      ..add(AuthInterceptor(accessTokenRetriever))
      ..add(CacheInterceptor(DioCacheInterceptor(options: cacheOptions)))
      ..add(LoggingNetworkInterceptor())
      ..add(ExpiredTokenInterceptor(authAccessChecker))
      ..add(unauthorizedInterceptor);
    return dioClient;
  }
}
