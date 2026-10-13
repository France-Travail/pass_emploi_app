import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/network/interceptors/auth_interceptor.dart';

import '../../doubles/mocks.dart';

class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}

void main() {
  late AuthInterceptor interceptor;
  late MockAuthAccessTokenRetriever accessTokenRetriever;
  late MockRequestInterceptorHandler handler;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(DioException(requestOptions: RequestOptions(path: '')));
  });

  setUp(() {
    accessTokenRetriever = MockAuthAccessTokenRetriever();
    interceptor = AuthInterceptor(accessTokenRetriever);
    handler = MockRequestInterceptorHandler();
    when(() => handler.next(any())).thenReturn(null);
    when(() => handler.reject(any(), any())).thenReturn(null);
  });

  test('adds Bearer token from retriever on normal request', () async {
    // Given
    accessTokenRetriever.withAccessToken();
    final options = RequestOptions(path: '/test');

    // When
    interceptor.onPassEmploiRequest(options, handler);
    await Future.delayed(Duration.zero);

    // Then
    expect(options.headers['Authorization'], 'Bearer accessToken');
    verify(() => handler.next(options)).called(1);
    verify(() => accessTokenRetriever.accessToken()).called(1);
  });

  test('rejects request when retriever throws exception', () async {
    // Given
    accessTokenRetriever.throwException();
    final options = RequestOptions(path: '/test');

    // When
    interceptor.onPassEmploiRequest(options, handler);
    await Future.delayed(Duration.zero);

    // Then
    verify(() => handler.reject(any(), true)).called(1);
    verify(() => accessTokenRetriever.accessToken()).called(1);
  });
}
