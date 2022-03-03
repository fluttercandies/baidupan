import 'dart:convert';
import 'dart:io';

import 'package:baidupan/baidupan.dart';

class BaiduAuthUtils {
  static const _instance = BaiduAuthUtils._();

  const BaiduAuthUtils._();

  factory BaiduAuthUtils() => _instance;

  String getAccessToken() {
    var environment = Platform.environment;
    var accessToken = environment['BAIDU_PAN_ACCESS_TOKEN'];

    if (accessToken != null) {
      return accessToken;
    }

    final homePath = environment['HOME'];
    final configPath = '$homePath/.config/baidupan/config.json';

    var config = File(configPath);
    if (!config.existsSync()) {
      throw Exception('config file ( $configPath ) not found');
    }

    var configJson = config.readAsStringSync();
    var configMap = json.decode(configJson);
    var authToken = BaiduAuth.fromJson(configMap);

    return authToken.accessToken;
  }
}
