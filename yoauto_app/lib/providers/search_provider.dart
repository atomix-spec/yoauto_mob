import 'package:flutter/material.dart';
import 'package:yoauto_api/yoauto_api.dart';

class SearchProvider extends ChangeNotifier {
  final SearchService searchService;
  SearchProvider(this.searchService);

  List<SearchHit> _results = [];
  List<AutocompleteSuggestion> _suggestions = [];
  int _totalResults = 0;
  bool _isLoading = false;
  String? _error;

  List<SearchHit> get results => _results;
  List<AutocompleteSuggestion> get suggestions => _suggestions;
  int get totalResults => _totalResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> search(SearchRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await searchService.search(request);
      _results = response.hits;
      _totalResults = response.total;
    } on AppException catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSuggestions(String q) async {
    if (q.isEmpty) {
      _suggestions = [];
      notifyListeners();
      return;
    }
    _error = null;
    try {
      _suggestions = await searchService.autocomplete(q);
    } on AppException catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  void clearSuggestions() {
    _suggestions = [];
    notifyListeners();
  }
}
