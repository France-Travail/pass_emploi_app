import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/auth/auth_access_checker.dart';
import 'package:pass_emploi_app/network/interceptors/expired_token_interceptor.dart';

class MockAuthAccessChecker extends Mock implements AuthAccessChecker {}

class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  late ExpiredTokenInterceptor interceptor;
  late MockAuthAccessChecker authAccessChecker;
  late MockErrorInterceptorHandler handler;

  setUp(() {
    authAccessChecker = MockAuthAccessChecker();
    interceptor = ExpiredTokenInterceptor(authAccessChecker);
    handler = MockErrorInterceptorHandler();
  });

  test('calls logoutUserIfTokenIsExpired on normal request error', () {
    // Given
    final dioError = DioException(
      requestOptions: RequestOptions(path: '/test'),
      response: Response(
        statusCode: 401,
        data: 'Unauthorized',
        requestOptions: RequestOptions(path: '/test'),
      ),
    );

    // When
    interceptor.onPassEmploiError(dioError, handler);

    // Then
    verify(() => authAccessChecker.logoutUserIfTokenIsExpired('Unauthorized', 401)).called(1);
    verify(() => handler.next(dioError)).called(1);
  });

  test('handles error with missing status code', () {
    // Given
    final dioError = DioException(
      requestOptions: RequestOptions(path: '/test'),
    );

    // When
    interceptor.onPassEmploiError(dioError, handler);

    // Then
    verify(() => authAccessChecker.logoutUserIfTokenIsExpired(null, -1)).called(1);
    verify(() => handler.next(dioError)).called(1);
  });
}
