import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../models/listing_models.dart';
import '../exceptions/app_exception.dart';
import 'package:dio/dio.dart';

class ListingsService {
  final ApiClient _apiClient;
  ListingsService(this._apiClient);

  Future<PaginatedListings> getFeed({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _apiClient.dio.get(
        Endpoints.listings,
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      return PaginatedListings.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error!;
      throw NetworkException();
    } catch (_) {
      throw ServerException();
    }
  }

  Future<ListingResponse> getDetail(String id) async {
    try {
      final response = await _apiClient.dio.get(Endpoints.listingDetail(id));
      return ListingResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error!;
      throw NetworkException();
    } catch (_) {
      throw ServerException();
    }
  }

  Future<PaginatedListings> getMyListings({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _apiClient.dio.get(
        Endpoints.myListings,
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      return PaginatedListings.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error!;
      throw NetworkException();
    } catch (_) {
      throw ServerException();
    }
  }

  Future<PaginatedListings> getFavourites({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _apiClient.dio.get(
        Endpoints.myFavourites,
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      return PaginatedListings.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error!;
      throw NetworkException();
    } catch (_) {
      throw ServerException();
    }
  }
}
