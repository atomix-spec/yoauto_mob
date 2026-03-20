import 'package:dio/dio.dart';
import '../exceptions/app_exception.dart';

class ApiClient {
  final Dio dio;
  final Dio refreshDio;

  ApiClient({
    String baseUrl = 'https://yoauto.online',
    required Future<String?> Function() getAccessToken,
    required Future<String?> Function() getRefreshToken,
    required Future<void> Function(String, String) onTokenRefreshed,
    required Future<void> Function() onUnauthorized,
  })  : dio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 15))),
        refreshDio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 15))) {

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          try {
            final refreshToken = await getRefreshToken();
            if (refreshToken == null) throw UnauthorizedException();

            final response = await refreshDio.post('/api/v1/auth/refresh', data: {'refresh_token': refreshToken});
            if (response.statusCode == 200) {
              final newAccess = response.data['access_token'];
              final newRefresh = response.data['refresh_token'];
              await onTokenRefreshed(newAccess, newRefresh);

              // Retry original request
              e.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
              final cloneReq = await dio.request(
                e.requestOptions.path,
                options: Options(
                  method: e.requestOptions.method,
                  headers: e.requestOptions.headers,
                ),
                data: e.requestOptions.data,
                queryParameters: e.requestOptions.queryParameters,
              );
              return handler.resolve(cloneReq);
            } else {
              throw UnauthorizedException();
            }
          } catch (_) {
            onUnauthorized();
            return handler.reject(DioException(
              requestOptions: e.requestOptions,
              error: UnauthorizedException(),
            ));
          }
        }

        return handler.next(_mapException(e));
      },
    ));
  }

  static DioException _mapException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return DioException(requestOptions: e.requestOptions, error: NetworkException());
    }
    final code = e.response?.statusCode;
    if (code == 401) return DioException(requestOptions: e.requestOptions, error: UnauthorizedException());
    if (code == 404) return DioException(requestOptions: e.requestOptions, error: NotFoundException());
    if (code == 409) return DioException(requestOptions: e.requestOptions, error: ConflictException());
    if (code == 422) return DioException(requestOptions: e.requestOptions, error: ValidationException());
    if (code != null && code >= 500) return DioException(requestOptions: e.requestOptions, error: ServerException('Server error', code));
    return e;
  }
}
