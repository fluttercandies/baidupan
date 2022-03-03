part of 'pan.dart';

extension BaiduPanExt1 on BaiduPan {
  /// 获取文件信息
  Future<BaiduFileMetaList> getMetaData({
    required List<int> fsIds,
  }) async {
    if (fsIds.isEmpty) {
      throw ArgumentError('fsids is empty');
    }

    if (fsIds.length > 100) {
      throw ArgumentError('fsids length is too long');
    }

    final path = 'rest/2.0/xpan/multimedia';
    final method = 'filemetas';

    final idString = '[${fsIds.join(',')}]';

    final map = await _get(path, params: {
      'method': method,
      'fsids': idString,
      'dlink': '1',
    });

    return BaiduFileMetaList.fromJson(map);
  }

  /// 获取下载链接，这里的下载要求拼接accessToken，同时要求header，所以返回的是一个http.Request
  /// [BaiduFileMetaItem] 为 [getMetaData] 的返回值
  ///
  /// 并且这个请求的响应结果一定包含 302 的重定向，所以注意处理
  http.Request getDownloadRequest(BaiduFileMetaItem item) {
    final uri = Uri.parse('${item.dlink}&access_token=$accessToken');

    if (showLog) {
      print('origin url: ${item.dlink}');
      print('download url: ${uri.toString()}');
    }

    final request = http.Request(
      'GET',
      uri,
    );

    // 文档中标注必须要加这个，实测如果加了会出错，应该是文档标注错误，不加则能正常下载
    // request.headers.addAll({
    //   'User-Agent': 'pan.baidu.com',
    // });

    return request;
  }

  /// 获取文件下载链接
  /// [BaiduFileMetaItem] 为 [getMetaData] 的返回值
  ///
  /// Uri 包含 302 的重定向
  Uri getDownloadUrl(BaiduFileMetaItem item) {
    final uri = Uri.parse('${item.dlink}&access_token=$accessToken');

    if (showLog) {
      print('origin url: ${item.dlink}');
      print('download url: ${uri.toString()}');
    }

    return uri;
  }
}
