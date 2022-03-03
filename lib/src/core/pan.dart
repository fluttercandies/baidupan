import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:baidupan/baidupan.dart';

part 'manager.g.dart';

part 'upload.g.dart';

part 'download.g.dart';

String get _baseUrl => 'https://pan.baidu.com';

mixin BaiduPanMixin {
  String get accessToken;

  bool get showLog;

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String> params = const {},
  }) async {
    final uri = Uri.parse('$_baseUrl/$path').replace(queryParameters: {
      ...params,
      'access_token': accessToken,
    });

    final response = await http.get(uri);
    final map = json.decode(response.body);

    if (showLog) {
      print('uri: $uri');
      print('response body: ${response.body}');
    }

    if (map['errno'] != 0) {
      throw Exception(map['errmsg']);
    }
    return map;
  }

  Future<Map> _post({
    String path = 'rest/2.0/xpan/file',
    String method = 'filemanager',
    Map<String, String> params = const {},
    Map<String, String> bodyParams = const {},
  }) async {
    final uri = Uri.parse('$_baseUrl/$path').replace(queryParameters: {
      ...params,
      'access_token': accessToken,
      'method': method,
    });

    final bodyMap = {
      ...bodyParams,
      'async': 0,
    };

    final body = bodyMap.entries.map((e) => '${e.key}=${e.value}').join('&');

    final response = await http.post(
      uri,
      body: body,
      // headers: headers,
      encoding: utf8,
    );
    var responseBody = response.body;
    final map = json.decode(responseBody);

    if (showLog) {
      print('uri: $uri');
      print('body: $body');
      print('response body: ${responseBody}');
    }

    if (map['errno'] != 0) {
      // print(response.body);
      throw BaiduPanError(response);
    }
    return map;
  }
}

/// 所有的具体的参数含义参照: 百度网盘的官方文档
///
/// 这个类包含了查询的方法
///
/// 如果你需要移动、删除、重命名等操作，请使用 [BaiduPanFileManager]
///
/// 如果你需要上传文件，请使用 [BaiduPanUploadManager]
///
/// 官方文档 https://pan.baidu.com/union/doc/pksg0s9ns
class BaiduPan with BaiduPanMixin {
  const BaiduPan(
    this.accessToken, {
    this.showLog = false,
  });

  factory BaiduPan.withAuth(BaiduAuth auth, {bool showLog = false}) {
    return BaiduPan(auth.accessToken, showLog: showLog);
  }

  @override
  final String accessToken;

  @override
  final bool showLog;

  /// 用户信息，包括账号、头像地址、会员类型等。
  ///
  /// 官方文档: https://pan.baidu.com/union/doc/pksg0s9ns
  Future<UserInfo> getUserInfo() async {
    final map = await _get('/rest/2.0/xpan/nas', params: {'method': 'uinfo'});
    return UserInfo.fromJson(map);
  }

  /// 获取网盘容量信息
  ///
  /// 官方文档: https://pan.baidu.com/union/doc/Cksg0s9ic
  Future<DiskSpace> getDiskSpace() async {
    final map = await _get('api/quota', params: {
      'checkfree': '1',
      'checkexpire': '1',
    });
    return DiskSpace.fromJson(map);
  }

  void _addCommonParams({
    required Map<String, String> params,
    required BaiduOrder order,
    required bool desc,
    int? start,
    int? end,
    int limit = 1000,
    bool web = true,
  }) {
    if (order.toParam().isNotEmpty) {
      params['order'] = order.toParam();
    }

    if (desc) {
      params['desc'] = '1';
    }
    if (start != null) {
      params['start'] = start.toString();
    }
    if (end != null) {
      params['end'] = end.toString();
    }
    params['limit'] = limit.toString();

    if (web) {
      params['web'] = '1';
    }
  }

  /// 获取文件列表
  ///
  /// [dir] 可选, 如果指定了该参数, 则返回指定目录下的文件列表，
  /// 否则返回用户的根目录下的文件列表, 这个参数必须是一个绝对路径，
  /// 以 / 开头，来源通常是 [FileItem.path]
  ///
  /// 其他请求参数查看官方文档: https://pan.baidu.com/union/doc/nksg0sat9 ，并放入[otherParams]
  Future<FileList> getFileList({
    String? dir,
    BaiduOrder order = BaiduOrder.name,
    bool desc = false,
    int? start,
    int? end,
    int limit = 1000,
    Map<String, String> otherParams = const {},
  }) async {
    final params = <String, String>{...otherParams};

    _addCommonParams(
      params: params,
      order: order,
      desc: desc,
      start: start,
      end: end,
      limit: limit,
    );

    if (dir != null) {
      params['dir'] = dir;
    }

    final map = await _get('rest/2.0/xpan/file', params: {
      'method': 'list',
      ...params,
    });
    return FileList.fromJson(map);
  }

  /// 递归获取文件列表
  ///
  /// /// 其他请求参数查看官方文档: https://pan.baidu.com/union/doc/Zksg0sb73 ，并放入[otherParams]
  Future<FileAllList> getFileListAll({
    required String dir,
    int? start,
    int? end,
    BaiduOrder order = BaiduOrder.name,
    bool desc = false,
    int limit = 1000,
    bool recursion = false,
    bool web = true,
    Map<String, String> otherParams = const {},
  }) async {
    final params = <String, String>{
      'path': dir,
      'limit': limit.toString(),
      ...otherParams,
    };

    if (recursion) {
      params['recursion'] = '1';
    }

    _addCommonParams(
      params: params,
      order: order,
      desc: desc,
      start: start,
      end: end,
      limit: limit,
      web: web,
    );

    final map = await _get('rest/2.0/xpan/multimedia', params: {
      'method': 'listall',
      ...params,
    });

    return FileAllList.fromJson(map);
  }

  /// 文档列表
  ///
  /// 参数查看 [官方文档](https://pan.baidu.com/union/doc/Eksg0saqp)
  Future<TypeFileList<DocItem>> getDocList({
    String dir = '/',
    bool recursion = false,
    int? page,
    num? number,
    BaiduOrder order = BaiduOrder.time,
    bool desc = false,
    bool web = true,
  }) async {
    final path = '/rest/2.0/xpan/file';

    var param = <String, String>{
      'method': 'doclist',
      'parent_path': dir,
    };

    if (recursion) {
      param['recursion'] = '1';
    }

    _addCommonParams(params: param, order: order, desc: desc, web: web);
    param.putIfNotNull('page', page);
    param.putIfNotNull('num', number);

    final map = await _get(path, params: param);
    return TypeFileList.convertToInfo(map, DocItem.fromJson);
  }

  /// 图片列表
  ///
  /// 参数查看 [官方文档](https://pan.baidu.com/union/doc/bksg0sayv)
  Future<TypeFileList<MediaItem>> getImageList({
    String dir = '/',
    bool recursion = false,
    int? page,
    num? number,
    BaiduOrder order = BaiduOrder.time,
    bool desc = false,
    bool web = true,
  }) async {
    final path = 'rest/2.0/xpan/file';

    var param = <String, String>{
      'method': 'imagelist',
      'parent_path': dir,
    };

    if (recursion) {
      param['recursion'] = '1';
    }

    _addCommonParams(params: param, order: order, desc: desc, web: web);
    param.putIfNotNull('page', page);
    param.putIfNotNull('num', number);

    final map = await _get(path, params: param);
    return TypeFileList.convertToInfo(map, MediaItem.fromJson);
  }

  /// 视频列表
  ///
  /// 参数查看 [官方文档](https://pan.baidu.com/union/doc/Sksg0saw0)
  Future<TypeFileList<MediaItem>> getVideoList({
    String dir = '/',
    bool recursion = false,
    int? page,
    num? number,
    BaiduOrder order = BaiduOrder.time,
    bool desc = false,
    bool web = true,
  }) async {
    final path = 'rest/2.0/xpan/file';

    var param = <String, String>{
      'method': 'videolist',
      'parent_path': dir,
    };

    if (recursion) {
      param['recursion'] = '1';
    }

    _addCommonParams(params: param, order: order, desc: desc, web: web);
    param.putIfNotNull('page', page);
    param.putIfNotNull('num', number);

    final map = await _get(path, params: param);
    return TypeFileList.convertToInfo(map, MediaItem.fromJson);
  }

  /// 种子列表
  ///
  /// 参数查看 [官方文档](https://pan.baidu.com/union/doc/xksg0sb1d)
  Future<TypeFileList<BtItem>> getBtList({
    String dir = '/',
    bool recursion = false,
    int? page,
    num? number,
    BaiduOrder order = BaiduOrder.time,
    bool desc = false,
    bool web = true,
  }) async {
    final path = 'rest/2.0/xpan/file';

    var param = <String, String>{
      'method': 'btlist',
      'parent_path': dir,
    };

    if (recursion) {
      param['recursion'] = '1';
    }

    _addCommonParams(params: param, order: order, desc: desc, web: web);
    param.putIfNotNull('page', page);
    param.putIfNotNull('num', number);

    final map = await _get(path, params: param);
    return TypeFileList.convertToInfo(map, BtItem.fromJson);
  }

  /// 获取分类文件总个数
  ///
  /// 参数查看 [官方文档](https://pan.baidu.com/union/doc/dksg0sanx)
  Future<Map<BaiduCategory, CategoryCount>> getCountOfPathByType({
    String dir = '/',
    bool recursion = true,
  }) async {
    final path = 'api/categoryinfo';
    final param = <String, String>{
      'parent_path': dir,
    };

    param.putIfNotNull('recursion', recursion ? '1' : '0');

    final map = await _get(path, params: param);

    final Map info = map['info'];

    final result = <BaiduCategory, CategoryCount>{};

    for (final categoryIndex in info.keys) {
      final infoMap = info[categoryIndex];
      if (infoMap == null) {
        continue;
      }
      final category = BaiduCategory.values[int.parse(categoryIndex) - 1];
      result[category] = CategoryCount.fromJson(infoMap);
    }

    return result;
  }

  /// 获取分类文件列表
  ///
  /// 参数查看 [官方文档](https://pan.baidu.com/union/doc/Sksg0sb40)
  Future<CategoryList> getCategoryList({
    required List<BaiduCategory> categorys,
    String parentPath = '/',
    bool showDir = false,
    bool recursion = false,
    List<String> ext = const [],
    int start = 0,
    int limit = 1000,
    BaiduOrder order = BaiduOrder.time,
    bool desc = false,
  }) async {
    if (categorys.isEmpty) {
      throw Exception('categorys is empty');
    }

    final path = 'rest/2.0/xpan/multimedia';

    var param = <String, String>{
      'method': 'categorylist',
      'parent_path': parentPath,
    };

    if (recursion) {
      param['recursion'] = '1';
    }

    _addCommonParams(params: param, order: order, desc: desc);
    param.putIfNotNull('show_dir', showDir);
    param.putIfNotNull('start', start);
    param.putIfNotNull('limit', limit);

    final categoryIndex = categorys.map((category) => category.value).join(',');
    param['category'] = categoryIndex;

    if (ext.isNotEmpty) {
      param['ext'] = ext.join(',');
    }

    final map = await _get(path, params: param);
    return CategoryList.fromJson(map);
  }

  /// 搜索文件
  ///
  /// 参数查看 [官方文档](https://pan.baidu.com/union/doc/zksg0sb9z)
  Future<SearchList> search({
    required String key,
    String dir = '/',
    int page = 1,
    bool recursion = false,
  }) async {
    final path = 'rest/2.0/xpan/file';

    var param = <String, String>{
      'method': 'search',
      'key': key,
      'dir': dir,
    };

    if (recursion) {
      param['recursion'] = '1';
    }

    param.putIfNotNull('page', page);
    // param.putIfNotNull('num', 500);
    param.putIfNotNull('num', 5);

    final map = await _get(path, params: param);
    return SearchList.fromJson(map);
  }
}

extension _MapExt on Map<String, String> {
  void putIfNotNull(String key, Object? value) {
    if (value != null) {
      this[key] = value.toString();
    }
  }
}
