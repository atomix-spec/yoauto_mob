import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../models/search_models.dart';
import '../exceptions/app_exception.dart';
import 'package:dio/dio.dart';

class SearchService {
  final ApiClient _apiClient;
  SearchService(this._apiClient);

  Future<SearchResponse> search(SearchRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        Endpoints.search,
        data: request.toJson(),
      );
      return SearchResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error!;
      throw NetworkException();
    } catch (_) {
      throw ServerException();
    }
  }

  Future<List<AutocompleteSuggestion>> autocomplete(String q) async {
    try {
      final response = await _apiClient.dio.get(
        Endpoints.autocomplete,
        queryParameters: {'q': q},
      );
      final suggestions = (response.data['suggestions'] as List? ?? []);
      return suggestions
          .whereType<Map<String, dynamic>>()
          .map((e) => AutocompleteSuggestion.fromJson(e))
          .toList();
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error!;
      throw NetworkException();
    } catch (_) {
      throw ServerException();
    }
  }
}
