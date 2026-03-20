# yoauto_api

Flutter API Client for the **YoAuto** automotive marketplace backend.

## Package Structure
- `lib/yoauto_api.dart`: Barrel export — import this one file
- `lib/api/api_client.dart`: Dio-based HTTP client with interceptors
- `lib/api/endpoints.dart`: All endpoint path constants
- `lib/exceptions/app_exception.dart`: Typed exception hierarchy
- `lib/models/`: Data models for Auth, Listings, Search, Chat, Notifications, Config
- `lib/services/`: API Services including WebSocket real-time chat

## Quick Start
1. **Token-storage**: Local storage interface.
2. **Central API client**: Includes a `tokenRefresher` interceptor.
3. **Authentication**: Supports Magic Links and Google Authentication via `google_sign_in`.
4. **Services**: AuthApiService, ListingsService, SearchService, ChatService, NotificationService, ConfigService, WebSocketService.
5. **WebSocketService**: Connects via `connect(String accessToken)` for real-time messages.
5. **Config & Versioning**: Version check and remote maintenance flag integration.

## Error Handling
All service methods throw typed `AppException` subclasses:
- `UnauthorizedException` (401)
- `NetworkException` (No connectivity / timeout)
- `ServerException` (5xx)
- `ValidationException` (422)
- `NotFoundException` (404)
- `ConflictException` (409)
