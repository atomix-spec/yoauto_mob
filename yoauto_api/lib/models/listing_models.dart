/// Compact listing for cards/lists. NOTE: price is a String from the API.
class ListingCardResponse {
  final String id;
  final String title;
  final String slug;
  final String status;
  final String price;   // String, not double — parse as needed: double.tryParse(price)
  final String currency;
  final String? city;
  final String? coverImageUrl;
  final int photosCount;
  final int viewsCount;
  final int favoritesCount;
  final bool isBoosted;
  final bool isHighlighted;
  final bool isFeatured;
  final DateTime createdAt;

  ListingCardResponse({required this.id, required this.title, required this.slug, required this.status, required this.price, required this.currency, this.city, this.coverImageUrl, required this.photosCount, required this.viewsCount, required this.favoritesCount, required this.isBoosted, required this.isHighlighted, required this.isFeatured, required this.createdAt});

  factory ListingCardResponse.fromJson(Map<String, dynamic> json) => ListingCardResponse(
    id: json['id'],
    title: json['title'],
    slug: json['slug'],
    status: json['status'],
    price: json['price'],
    currency: json['currency'] ?? 'USD',
    city: json['city'],
    coverImageUrl: json['cover_image_url'],
    photosCount: json['photos_count'] ?? 0,
    viewsCount: json['views_count'] ?? 0,
    favoritesCount: json['favorites_count'] ?? 0,
    isBoosted: json['is_boosted'] ?? false,
    isHighlighted: json['is_highlighted'] ?? false,
    isFeatured: json['is_featured'] ?? false,
    createdAt: DateTime.parse(json['created_at']),
  );
}

/// Paginated wrapper for ListingCardResponse
class PaginatedListings {
  final List<ListingCardResponse> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  PaginatedListings({required this.items, required this.total, required this.page, required this.pageSize, required this.totalPages});

  factory PaginatedListings.fromJson(Map<String, dynamic> json) => PaginatedListings(
    items: (json['items'] as List).map((e) => ListingCardResponse.fromJson(e)).toList(),
    total: json['total'],
    page: json['page'],
    pageSize: json['page_size'],
    totalPages: json['total_pages'],
  );
}

/// Minimal vehicle info embedded in listing
class VehicleResponse {
  final String id;
  final String makeName;
  final String modelName;
  final int year;
  final String bodyType;
  final String condition;
  final String fuelType;
  final String transmission;
  final int mileage;
  final String mileageUnit;
  final double? engineCapacity;
  final int? enginePower;
  final String? colorName;
  final bool? accidentFree;
  final int? ownersCount;

  VehicleResponse({required this.id, required this.makeName, required this.modelName, required this.year, required this.bodyType, required this.condition, required this.fuelType, required this.transmission, required this.mileage, required this.mileageUnit, this.engineCapacity, this.enginePower, this.colorName, this.accidentFree, this.ownersCount});

  factory VehicleResponse.fromJson(Map<String, dynamic> json) => VehicleResponse(
    id: json['id'],
    makeName: json['make_name'],
    modelName: json['model_name'],
    year: json['year'],
    bodyType: json['body_type'],
    condition: json['condition'],
    fuelType: json['fuel_type'],
    transmission: json['transmission'],
    mileage: json['mileage'],
    mileageUnit: json['mileage_unit'],
    engineCapacity: (json['engine_capacity'] as num?)?.toDouble(),
    enginePower: json['engine_power'],
    colorName: json['color_name'],
    accidentFree: json['accident_free'],
    ownersCount: json['owners_count'],
  );
}

/// Media item for a listing
class ListingMediaResponse {
  final String id;
  final String url;
  final String? thumbnailUrl;
  final String mediaType;
  final int position;
  final bool isCover;

  ListingMediaResponse({required this.id, required this.url, this.thumbnailUrl, required this.mediaType, required this.position, required this.isCover});

  factory ListingMediaResponse.fromJson(Map<String, dynamic> json) => ListingMediaResponse(
    id: json['id'],
    url: json['url'],
    thumbnailUrl: json['thumbnail_url'],
    mediaType: json['media_type'],
    position: json['position'],
    isCover: json['is_cover'],
  );
}

/// Minimal seller info
class SellerResponse {
  final String id;
  final String? name;
  final String? avatarUrl;

  SellerResponse({required this.id, this.name, this.avatarUrl});

  factory SellerResponse.fromJson(Map<String, dynamic> json) => SellerResponse(
    id: json['id'],
    name: json['name'],
    avatarUrl: json['avatar_url'],
  );
}

/// Full listing detail
class ListingResponse {
  final String id;
  final String title;
  final String slug;
  final String status;
  final String price;
  final String currency;
  final String? description;
  final String? city;
  final String? region;
  final String country;
  final String? coverImageUrl;
  final int viewsCount;
  final int favoritesCount;
  final bool isBoosted;
  final VehicleResponse? vehicle;
  final List<ListingMediaResponse>? media;
  final SellerResponse? seller;
  final String? contactPhone;
  final String? contactName;
  final DateTime createdAt;
  final DateTime updatedAt;

  ListingResponse({required this.id, required this.title, required this.slug, required this.status, required this.price, required this.currency, this.description, this.city, this.region, required this.country, this.coverImageUrl, required this.viewsCount, required this.favoritesCount, required this.isBoosted, this.vehicle, this.media, this.seller, this.contactPhone, this.contactName, required this.createdAt, required this.updatedAt});

  factory ListingResponse.fromJson(Map<String, dynamic> json) => ListingResponse(
    id: json['id'],
    title: json['title'],
    slug: json['slug'],
    status: json['status'],
    price: json['price'],
    currency: json['currency'],
    description: json['description'],
    city: json['city'],
    region: json['region'],
    country: json['country'],
    coverImageUrl: json['cover_image_url'],
    viewsCount: json['views_count'] ?? 0,
    favoritesCount: json['favorites_count'] ?? 0,
    isBoosted: json['is_boosted'] ?? false,
    vehicle: json['vehicle'] != null ? VehicleResponse.fromJson(json['vehicle']) : null,
    media: (json['media'] as List?)?.map((e) => ListingMediaResponse.fromJson(e)).toList(),
    seller: json['seller'] != null ? SellerResponse.fromJson(json['seller']) : null,
    contactPhone: json['contact_phone'],
    contactName: json['contact_name'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
  );
}
