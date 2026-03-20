import 'package:flutter_test/flutter_test.dart';
import 'package:yoauto_app/main.dart';
import 'package:yoauto_api/yoauto_api.dart';

void main() {
  testWidgets('App initializes and shows login screen', (WidgetTester tester) async {
    final apiClient = ApiClient(
      baseUrl: 'http://test',
      getAccessToken: () async => null,
      getRefreshToken: () async => null,
      onTokenRefreshed: (a, r) async {},
      onUnauthorized: () async {},
    );

    final authService = AuthService(apiClient, _FakeTokenStorage());
    final listingsService = ListingsService(apiClient);
    final searchService = SearchService(apiClient);
    final chatService = ChatService(apiClient);
    final notificationService = NotificationService(apiClient);

    await tester.pumpWidget(MyApp(
      authService: authService,
      listingsService: listingsService,
      searchService: searchService,
      chatService: chatService,
      notificationService: notificationService,
    ));

    expect(find.text('YoAuto'), findsWidgets);
  });
}

class _FakeTokenStorage implements TokenStorage {
  @override
  Future<void> saveTokens(String access, String refresh) async {}
  @override
  Future<String?> getAccessToken() async => null;
  @override
  Future<String?> getRefreshToken() async => null;
  @override
  Future<void> clearTokens() async {}
}
