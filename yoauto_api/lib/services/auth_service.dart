import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../models/auth_models.dart';
import '../exceptions/app_exception.dart';
import 'package:dio/dio.dart';

abstract class TokenStorage {
  Future<void> saveTokens(String access, String refresh);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
}

class AuthService {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthService(this._apiClient, this._tokenStorage);

  /// Step 1: Request magic link sent to email
  Future<void> requestMagicLink(String email) async {
    try {
      await _apiClient.dio.post(
        Endpoints.requestMagicLink,
        data: MagicLinkRequest(email: email).toJson(),
      );
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error!;
      throw NetworkException();
    } catch (_) {
      throw ServerException();
    }
  }

  /// Step 2: Verify magic link token and log in
  Future<LoginResponse> verifyMagicLink(String token) async {
    try {
      final response = await _apiClient.dio.post(
        Endpoints.verifyMagicLink,
        data: MagicLinkVerify(token: token).toJson(),
      );
      final loginResponse = LoginResponse.fromJson(response.data);
      await _tokenStorage.saveTokens(
        loginResponse.tokens.accessToken,
        loginResponse.tokens.refreshToken,
      );
      return loginResponse;
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error!;
      throw NetworkException();
    } catch (_) {
      throw ServerException();
    }
  }

  /// Login with Google OAuth authorization code.
  /// [code] is the server auth code from google_sign_in (account.serverAuthCode).
  /// [redirectUri] must match the redirect URI registered in your Google Cloud project.
  Future<LoginResponse> loginWithGoogle(String code, String redirectUri) async {
    try {
      final response = await _apiClient.dio.post(
        Endpoints.loginWithGoogle,
        data: GoogleAuthRequest(code: code, redirectUri: redirectUri).toJson(),
      );
      final loginResponse = LoginResponse.fromJson(response.data);
      await _tokenStorage.saveTokens(
        loginResponse.tokens.accessToken,
        loginResponse.tokens.refreshToken,
      );
      return loginResponse;
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error!;
      throw NetworkException();
    } catch (_) {
      throw ServerException();
    }
  }

  /// Logout current session
  Future<void> logout() async {
    try {
      await _apiClient.dio.post(Endpoints.logout);
    } catch (_) {
      // ignore server errors on logout
    } finally {
      await _tokenStorage.clearTokens();
    }
  }

  /// Get current user info
  Future<AuthUser> getMe() async {
    try {
      final response = await _apiClient.dio.get(Endpoints.me);
      return AuthUser.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error!;
      throw NetworkException();
    } catch (_) {
      throw ServerException();
    }
  }
}
