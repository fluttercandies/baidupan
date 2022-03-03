part of 'pan.dart';

/// 操作文件的管理类
///
/// opera	string	是	copy	URL参数	文件操作:copy, move, rename, delete
class BaiduPanFileManager with BaiduPanMixin {
  const BaiduPanFileManager(
    this.accessToken, {
    this.showLog = false,
  });

  @override
  final String accessToken;

  @override
  final bool showLog;

  /// 复制
  Future<void> copy(
    List<CopyOrMoveItem> items, {
    OnDuplicateAction? onDuplicateAction,
  }) async {
    final path = 'rest/2.0/xpan/file';

    final params = {
      'opera': 'copy',
    };

    final jsonList = items.map((item) => item.toMap()).toList();

    final bodyParams = <String, String>{
      'filelist': json.encode(jsonList),
    };

    if (onDuplicateAction != null) {
      bodyParams['ondup'] = onDuplicateAction.value;
    }

    await _post(params: params, bodyParams: bodyParams);
  }

  /// 移动
  Future<void> move(
    List<CopyOrMoveItem> items, {
    OnDuplicateAction? onDuplicateAction,
  }) async {
    final path = 'rest/2.0/xpan/file';

    final params = {
      'opera': 'move',
    };

    final jsonList = items.map((item) => item.toMap()).toList();

    final bodyParams = <String, String>{
      'filelist': json.encode(jsonList),
    };

    if (onDuplicateAction != null) {
      bodyParams['ondup'] = onDuplicateAction.value;
    }

    await _post(params: params, bodyParams: bodyParams);
  }

  /// 重命名
  Future<void> rename(
    List<RenameItem> items, {
    OnDuplicateAction? onDuplicateAction,
  }) async {
    final path = 'rest/2.0/xpan/file';

    final params = {
      'opera': 'rename',
    };

    final jsonList = items.map((item) => item.toMap()).toList();

    final bodyParams = <String, String>{
      'filelist': json.encode(jsonList),
    };

    if (onDuplicateAction != null) {
      bodyParams['ondup'] = onDuplicateAction.value;
    }

    await _post(params: params, bodyParams: bodyParams);
  }

  /// 删除
  Future<void> delete(
    List<String> items, {
    OnDuplicateAction? onDuplicateAction,
  }) async {
    final path = 'rest/2.0/xpan/file';

    final params = {
      'opera': 'delete',
    };

    final bodyParams = <String, String>{
      'filelist': json.encode(items),
    };

    if (onDuplicateAction != null) {
      bodyParams['ondup'] = onDuplicateAction.value;
    }

    await _post(params: params, bodyParams: bodyParams);
  }
}

class RenameItem {
  RenameItem({
    required this.path,
    required this.newName,
  });

  final String path;
  final String newName;

  Map<String, String> toMap() {
    return {
      'path': path,
      'newname': newName,
    };
  }
}

class CopyOrMoveItem {
  final String path;
  final String dest;
  final String newname;
  final OnDuplicateAction? ondup;

  CopyOrMoveItem({
    required this.path,
    required this.dest,
    required this.newname,
    this.ondup,
  });

  Map<String, dynamic> toMap() {
    final params = {
      'path': path,
      'dest': dest,
      'newname': newname,
    };

    if (ondup != null) {
      params['ondup'] = ondup!.value;
    }

    return params;
  }
}

/// fail(默认，直接返回失败)、newcopy(重命名文件)、overwrite、skip
enum OnDuplicateAction {
  fail,
  newcopy,
  overwrite,
  skip,
}

extension OnDuplicateExt on OnDuplicateAction {
  String get value {
    switch (this) {
      case OnDuplicateAction.fail:
        return 'fail';
      case OnDuplicateAction.newcopy:
        return 'newcopy';
      case OnDuplicateAction.overwrite:
        return 'overwrite';
      case OnDuplicateAction.skip:
        return 'skip';
    }
  }
}
