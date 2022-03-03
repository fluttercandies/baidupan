class BaiduAuth {
  final int expiresIn;
  final String refreshToken;
  final String accessToken;
  final String sessionSecret;
  final String sessionKey;
  final String scope;

  BaiduAuth({
    required this.expiresIn,
    required this.refreshToken,
    required this.accessToken,
    required this.sessionSecret,
    required this.sessionKey,
    required this.scope,
  });

  static BaiduAuth fromJson(Map<String, dynamic> json) {
    return BaiduAuth(
      expiresIn: json['expires_in'],
      refreshToken: json['refresh_token'],
      accessToken: json['access_token'],
      sessionSecret: json['session_secret'],
      sessionKey: json['session_key'],
      scope: json['scope'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expires_in': expiresIn,
      'refresh_token': refreshToken,
      'access_token': accessToken,
      'session_secret': sessionSecret,
      'session_key': sessionKey,
      'scope': scope
    };
  }

  @override
  String toString() {
    return 'AuthToken{expiresIn: $expiresIn, refreshToken: $refreshToken, accessToken: $accessToken, sessionSecret: $sessionSecret, sessionKey: $sessionKey, scope: $scope}';
  }
}
