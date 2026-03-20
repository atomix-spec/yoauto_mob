import 'package:flutter/material.dart';
import 'package:yoauto_api/yoauto_api.dart';

class ListingsProvider extends ChangeNotifier {
  final ListingsService listingsService;
  ListingsProvider(this.listingsService);

  List<ListingCardResponse> _feed = [];
  List<ListingCardResponse> _myListings = [];
  List<ListingCardResponse> _favourites = [];
  ListingResponse? _selectedDetail;
  bool _isLoading = false;
  String? _error;

  List<ListingCardResponse> get feed => _feed;
  List<ListingCardResponse> get myListings => _myListings;
  List<ListingCardResponse> get favourites => _favourites;
  ListingResponse? get selectedDetail => _selectedDetail;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFeed() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final paginated = await listingsService.getFeed();
      _feed = paginated.items;
    } on AppException catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyListings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final paginated = await listingsService.getMyListings();
      _myListings = paginated.items;
    } on AppException catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFavourites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final paginated = await listingsService.getFavourites();
      _favourites = paginated.items;
    } on AppException catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDetail(String id) async {
    _isLoading = true;
    _error = null;
    _selectedDetail = null;
    notifyListeners();
    try {
      _selectedDetail = await listingsService.getDetail(id);
    } on AppException catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
