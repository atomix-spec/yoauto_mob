/// Send magic link request
class MagicLinkRequest {
  final String email;
  MagicLinkRequest({required this.email});
  Map<String, dynamic> toJson() => {'email': email};
}

/// Verify magic link token
class MagicLinkVerify {
  final String token;
  MagicLinkVerify({required this.token});
  Map<String, dynamic> toJson() => {'token': token};
}

/// Token pair returned by auth endpoints
class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  TokenResponse({required this.accessToken, required this.refreshToken, required this.tokenType, required this.expiresIn});
  factory TokenResponse.fromJson(Map<String, dynamic> json) => TokenResponse(
    accessToken: json['access_token'],
    refreshToken: json['refresh_token'],
    tokenType: json['token_type'] ?? 'bearer',
    expiresIn: json['expires_in'],
  );
}

/// Authenticated user info
class AuthUser {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final String role;
  final String status;
  final List<String> permissions;
  AuthUser({required this.id, required this.email, this.name, this.avatarUrl, required this.role, required this.status, required this.permissions});
  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'],
    email: json['email'],
    name: json['name'],
    avatarUrl: json['avatar_url'],
    role: json['role'],
    status: json['status'] is String ? json['status'] : json['status'].toString(),
    permissions: (json['permissions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
  );
}

/// Google OAuth authorization code exchange request
class GoogleAuthRequest {
  final String code;
  final String redirectUri;
  GoogleAuthRequest({required this.code, required this.redirectUri});
  Map<String, dynamic> toJson() => {'code': code, 'redirect_uri': redirectUri};
}

/// Login response: user + token pair
class LoginResponse {
  final AuthUser user;
  final TokenResponse tokens;
  LoginResponse({required this.user, required this.tokens});
  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    user: AuthUser.fromJson(json['user']),
    tokens: TokenResponse.fromJson(json['tokens']),
  );
}
