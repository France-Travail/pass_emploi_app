import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/auth/auth_access_token_retriever.dart';
import 'package:pass_emploi_app/features/too_many_requests/too_many_requests_actions.dart';
import 'package:pass_emploi_app/network/interceptors/too_many_requests_interceptor.dart';

import '../../doubles/spies.dart';

class _MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  final now = DateTime(2026, 11, 23, 10);
  late TooManyRequestsInterceptor interceptor;
  late _MockErrorInterceptorHandler handler;
  late StoreSpy store;

  setUpAll(() {
    registerFallbackValue(
      DioException(requestOptions: RequestOptions(path: '')),
    );
  });

  setUp(() {
    store = StoreSpy();
    interceptor = TooManyRequestsInterceptor()..setStore(store);
    handler = _MockErrorInterceptorHandler();
    when(() => handler.next(any())).thenReturn(null);
  });

  void onError(DioException error) => withClock(
    Clock.fixed(now),
    () => interceptor.onPassEmploiError(error, handler),
  );

  test('429 de l\'API : signale la limite jusqu\'à la fin indiquée par Retry-After', () {
    // When
    onError(_httpError(429, retryAfter: '30'));

    // Then
    expect(store.dispatchedAction, isA<TooManyRequestsAction>());
    expect(
      (store.dispatchedAction as TooManyRequestsAction).retryNotBefore,
      now.add(Duration(seconds: 30)),
    );
  });

  test(
    '429 de l\'API sans Retry-After : signale la limite pour une minute',
    () {
      // When
      onError(_httpError(429));

      // Then
      expect(
        (store.dispatchedAction as TooManyRequestsAction).retryNotBefore,
        now.add(Duration(minutes: 1)),
      );
    },
  );

  test('refresh refusé par connect : signale la limite jusqu\'à la fin de la pause du refresh', () {
    // Given
    final retryNotBefore = now.add(Duration(minutes: 2));

    // When
    onError(_refreshRefusedError(retryNotBefore));

    // Then
    expect(
      (store.dispatchedAction as TooManyRequestsAction).retryNotBefore,
      retryNotBefore,
    );
  });

  test('autre erreur : ne signale rien', () {
    // When
    onError(_httpError(500));

    // Then
    expect(store.dispatchedActions, isEmpty);
  });

  test('transmet toujours l\'erreur aux écrans', () {
    // Given
    final error = _httpError(429);

    // When
    onError(error);

    // Then
    verify(() => handler.next(error)).called(1);
  });

  group('isTooManyRequests', () {
    test(
      'vrai pour un 429 de l\'API et pour un refresh refusé par connect',
      () {
        expect(_httpError(429).isTooManyRequests(), isTrue);
        expect(_refreshRefusedError(now).isTooManyRequests(), isTrue);
      },
    );

    test('faux pour les autres erreurs', () {
      expect(_httpError(500).isTooManyRequests(), isFalse);
      expect(_httpError(401).isTooManyRequests(), isFalse);
      expect(
        DioException(
          requestOptions: RequestOptions(path: '/test'),
          error: Exception('network'),
        ).isTooManyRequests(),
        isFalse,
      );
    });
  });
}

DioException _httpError(int statusCode, {String? retryAfter}) {
  final requestOptions = RequestOptions(path: '/test');
  return DioException(
    requestOptions: requestOptions,
    response: Response(
      statusCode: statusCode,
      requestOptions: requestOptions,
      headers: Headers.fromMap({
        if (retryAfter != null) 'retry-after': [retryAfter],
      }),
    ),
  );
}

DioException _refreshRefusedError(DateTime retryNotBefore) {
  return DioException(
    requestOptions: RequestOptions(path: '/test'),
    error: TokenRefreshTemporarilyRefusedException(retryNotBefore),
  );
}
