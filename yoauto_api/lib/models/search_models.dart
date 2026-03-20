/// Search filters
class SearchFilters {
  final double? priceFrom;
  final double? priceTo;
  final String? currency;
  final String? makeId;
  final String? modelId;
  final int? yearFrom;
  final int? yearTo;
  final List<String>? bodyType;
  final List<String>? fuelType;
  final List<String>? transmission;
  final int? mileageFrom;
  final int? mileageTo;
  final String? city;
  final String? country;
  final String? sellerType;
  final String status;

  SearchFilters({this.priceFrom, this.priceTo, this.currency, this.makeId, this.modelId, this.yearFrom, this.yearTo, this.bodyType, this.fuelType, this.transmission, this.mileageFrom, this.mileageTo, this.city, this.country, this.sellerType, this.status = 'active'});

  Map<String, dynamic> toJson() => {
    if (priceFrom != null) 'price_from': priceFrom,
    if (priceTo != null) 'price_to': priceTo,
    if (currency != null) 'currency': currency,
    if (makeId != null) 'make_id': makeId,
    if (modelId != null) 'model_id': modelId,
    if (yearFrom != null) 'year_from': yearFrom,
    if (yearTo != null) 'year_to': yearTo,
    if (bodyType != null) 'body_type': bodyType,
    if (fuelType != null) 'fuel_type': fuelType,
    if (transmission != null) 'transmission': transmission,
    if (mileageFrom != null) 'mileage_from': mileageFrom,
    if (mileageTo != null) 'mileage_to': mileageTo,
    if (city != null) 'city': city,
    if (country != null) 'country': country,
    if (sellerType != null) 'seller_type': sellerType,
    'status': status,
  };
}

/// Search request body
class SearchRequest {
  final String query;
  final SearchFilters? filters;
  final String? sortBy;
  final int page;
  final int pageSize;

  SearchRequest({this.query = '', this.filters, this.sortBy, this.page = 1, this.pageSize = 20});

  Map<String, dynamic> toJson() => {
    'query': query,
    if (filters != null) 'filters': filters!.toJson(),
    if (sortBy != null) 'sort_by': sortBy,
    'page': page,
    'page_size': pageSize,
  };
}

/// Single search result item
class SearchHit {
  final String id;
  final String title;
  final String slug;
  final String price;
  final String currency;
  final String makeName;
  final String modelName;
  final int year;
  final String? city;
  final String? coverImageUrl;
  final int photosCount;
  final bool isBoosted;
  final bool isFeatured;

  SearchHit({required this.id, required this.title, required this.slug, required this.price, required this.currency, required this.makeName, required this.modelName, required this.year, this.city, this.coverImageUrl, required this.photosCount, required this.isBoosted, required this.isFeatured});

  factory SearchHit.fromJson(Map<String, dynamic> json) => SearchHit(
    id: json['id'],
    title: json['title'],
    slug: json['slug'],
    price: json['price'],
    currency: json['currency'],
    makeName: json['make_name'],
    modelName: json['model_name'],
    year: json['year'],
    city: json['city'],
    coverImageUrl: json['cover_image_url'],
    photosCount: json['photos_count'] ?? 0,
    isBoosted: json['is_boosted'] ?? false,
    isFeatured: json['is_featured'] ?? false,
  );
}

/// Search response
class SearchResponse {
  final List<SearchHit> hits;
  final int total;
  final int page;
  final int pageSize;
  final String query;

  SearchResponse({required this.hits, required this.total, required this.page, required this.pageSize, required this.query});

  factory SearchResponse.fromJson(Map<String, dynamic> json) => SearchResponse(
    hits: (json['hits'] as List).map((e) => SearchHit.fromJson(e)).toList(),
    total: json['total'],
    page: json['page'],
    pageSize: json['page_size'],
    query: json['query'] ?? '',
  );
}

/// Autocomplete suggestion - the API returns a list of opaque objects
class AutocompleteSuggestion {
  final String text;
  final Map<String, dynamic> raw;
  AutocompleteSuggestion({required this.text, required this.raw});
  factory AutocompleteSuggestion.fromJson(Map<String, dynamic> json) {
    // The API returns opaque objects - try common fields
    final text = json['title'] ?? json['name'] ?? json['text'] ?? json.values.first?.toString() ?? '';
    return AutocompleteSuggestion(text: text.toString(), raw: json);
  }
}
