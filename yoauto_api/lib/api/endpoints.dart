class Endpoints {
  static const String baseUrl = 'https://yoauto.online';
  static const String wsUrl = 'wss://yoauto.online/api/v1/ws';

  // Auth
  static const String requestMagicLink = '/api/v1/auth/login/email';
  static const String verifyMagicLink = '/api/v1/auth/login/email/verify';
  static const String loginWithGoogle = '/api/v1/auth/login/google';
  static const String googleAuthUrl = '/api/v1/auth/google/url';
  static const String refresh = '/api/v1/auth/refresh';
  static const String logout = '/api/v1/auth/logout';
  static const String me = '/api/v1/auth/me';

  // Listings
  static const String listings = '/api/v1/listings';
  static const String myListings = '/api/v1/listings/my/listings';
  static const String myFavourites = '/api/v1/listings/my/favorites';
  static String listingDetail(String id) => '/api/v1/listings/$id';
  static String toggleFavourite(String id) => '/api/v1/listings/$id/favorite';

  // Search
  static const String search = '/api/v1/search';
  static const String autocomplete = '/api/v1/search/autocomplete';

  // Messaging
  static const String chats = '/api/v1/messaging/chats';
  static String chatMessages(String chatId) => '/api/v1/messaging/chats/$chatId/messages';
  static String markChatRead(String chatId) => '/api/v1/messaging/chats/$chatId/read';

  // Notifications
  static const String notifications = '/api/v1/notifications';
  static const String pushDevices = '/api/v1/notifications/devices';
}
