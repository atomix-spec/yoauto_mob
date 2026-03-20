import 'package:flutter_test/flutter_test.dart';
import 'package:yoauto_api/yoauto_api.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

class MockTokenStorage extends Mock implements TokenStorage {}
class MockDio extends Mock implements Dio {}

void main() {
  late AuthService authService;
  late MockTokenStorage mockTokenStorage;
  late ApiClient apiClient;

  setUp(() {
    mockTokenStorage = MockTokenStorage();
    apiClient = ApiClient(
      baseUrl: 'http://test',
      getAccessToken: () async => 'access',
      getRefreshToken: () async => 'refresh',
      onTokenRefreshed: (a, r) async {},
      onUnauthorized: () async {},
    );
    authService = AuthService(apiClient, mockTokenStorage);
  });

  test('AuthService logout should clear tokens', () async {
    when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});
    await authService.logout();
    verify(() => mockTokenStorage.clearTokens()).called(1);
  });
}
