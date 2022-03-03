import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart';

/// 表示百度网盘的错误信息
///
/// 百度网盘的错误通常是一个枚举，如果是公共错误可以通过 [errno] 到 [官网](https://pan.baidu.com/union/doc/okumlx17r) 查询来获取具体的错误信息。
///
/// 具体到某个接口的错误信息可以到对应接口的文档中查询。
class BaiduPanError with MapMixin<String, dynamic> implements Exception {
  const BaiduPanError(this.response);

  final Response response;

  String get body => response.body;

  Map<String, dynamic> get responseMap =>
      response.body.isEmpty ? {} : json.decode(response.body);

  /// 错误码，为0表示没有错误，其他情况可以通过 [官网](https://pan.baidu.com/union/doc/okumlx17r) 查询
  int get errno => responseMap['errno'];

  /// 错误信息，可能为空
  String? get errmsg => responseMap['errmsg'];

  @override
  dynamic operator [](Object? key) {
    return responseMap[key];
  }

  @override
  void operator []=(String key, value) {
    throw UnimplementedError('[]= is not supported');
  }

  @override
  void clear() {
    throw UnimplementedError('The method "clear" is not implemented.');
  }

  @override
  Iterable<String> get keys => responseMap.keys;

  @override
  dynamic remove(Object? key) {
    throw UnimplementedError();
  }

  @override
  String toString() {
    return 'BaiduPanError: ${json.encode(responseMap)}';
  }
}
