import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoauto_api/yoauto_api.dart';
import 'core/token_storage.dart';
import 'providers/auth_provider.dart';
import 'providers/listings_provider.dart';
import 'providers/search_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notifications_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/listings/listing_detail_screen.dart';
import 'screens/chat/chat_messages_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = SharedPreferencesTokenStorage();

  final apiClient = ApiClient(
    baseUrl: 'https://yoauto.online',
    getAccessToken: tokenStorage.getAccessToken,
    getRefreshToken: tokenStorage.getRefreshToken,
    onTokenRefreshed: (access, refresh) => tokenStorage.saveTokens(access, refresh),
    onUnauthorized: () async { /* handled by AuthProvider */ },
  );

  final authService = AuthService(apiClient, tokenStorage);
  final listingsService = ListingsService(apiClient);
  final searchService = SearchService(apiClient);
  final chatService = ChatService(apiClient);
  final notificationService = NotificationService(apiClient);

  runApp(MyApp(
    authService: authService,
    listingsService: listingsService,
    searchService: searchService,
    chatService: chatService,
    notificationService: notificationService,
  ));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final ListingsService listingsService;
  final SearchService searchService;
  final ChatService chatService;
  final NotificationService notificationService;

  const MyApp({
    super.key,
    required this.authService,
    required this.listingsService,
    required this.searchService,
    required this.chatService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),
        ChangeNotifierProvider(
          create: (_) => ListingsProvider(listingsService),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(searchService),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(chatService),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationsProvider(notificationService),
        ),
      ],
      child: MaterialApp(
        title: 'YoAuto',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/home': (_) => const HomeScreen(),
          '/listing-detail': (_) => const ListingDetailScreen(),
          '/chat-messages': (_) => const ChatMessagesScreen(),
        },
      ),
    );
  }
}
