import 'dart:convert';
import 'dart:io';

import 'package:baidupan/baidupan.dart';

Future<void> main(List<String> args) async {
  final appId = Platform.environment['baidu_app_id'];
  final appSecret = Platform.environment['baidu_app_secret'];
  final code = Platform.environment['baidu_request_code'];

  if (appId == null || appSecret == null) {
    print('使用说明：');
    print('1. 设置环境变量： export baidu_app_id=xxx');
    print('2. 设置环境变量： export baidu_app_secret=xxx');

    print('3. 如果你已经获取了 code，请设置环境变量： export baidu_request_code=xxx');

    print('然后使用命令行执行： dart run bin/request_auth.dart / request_auth');
    exit(1);
  }

  if (code != null) {
    final authManager = BaiduAuthManager(appId, appSecret);
    final auth = await authManager.requestAccessToken(code);
    print('生成的config内容：');
    print(json.encode(auth.toJson()));
    return;
  }

  print('baidu_request_code 环境变量不存在，请使用浏览器访问如下链接获取 code: ');
  final baiduAuth = BaiduAuthManager(appId, appSecret);

  final authUri = baiduAuth.getAuthUrl();
  print(authUri);
}
