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
  Future<Map> copy(
    List<CopyOrMoveItem> items, {
    OnDuplicateAction? onDuplicateAction,
  }) async {
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

    return _post(params: params, bodyParams: bodyParams);
  }

  /// 移动
  Future<Map> move(
    List<CopyOrMoveItem> items, {
    OnDuplicateAction? onDuplicateAction,
  }) async {
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

    return _post(params: params, bodyParams: bodyParams);
  }

  /// 重命名
  Future<Map> rename(
    List<RenameItem> items, {
    OnDuplicateAction? onDuplicateAction,
  }) async {
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

    return _post(params: params, bodyParams: bodyParams);
  }

  /// 删除
  Future<Map> delete(
    List<String> items, {
    OnDuplicateAction? onDuplicateAction,
  }) async {
    final params = {
      'opera': 'delete',
    };

    final bodyParams = <String, String>{
      'filelist': json.encode(items),
    };

    if (onDuplicateAction != null) {
      bodyParams['ondup'] = onDuplicateAction.value;
    }

    return _post(params: params, bodyParams: bodyParams);
  }

  /// 创建文件夹
  ///
  /// [path] 为绝对路径，必须以 / 开头
  ///
  Future<Map> createFolder({
    required String path,
    OnDuplicateAction onDuplicateAction = OnDuplicateAction.fail,
    DateTime? createTime,
    DateTime? modifyTime,
  }) {
    final bodyParams = <String, String>{
      'path': Uri.encodeComponent(path),
      'isdir': '1',
      'rtype': onDuplicateAction.rtype.toString(),
    };

    if (createTime != null) {
      bodyParams['local_ctime'] =
          (createTime.millisecondsSinceEpoch ~/ 1000).toString();
    }

    if (modifyTime != null) {
      bodyParams['local_mtime'] =
          (modifyTime.millisecondsSinceEpoch ~/ 1000).toString();
    }

    return _post(
      method: 'create',
      bodyParams: bodyParams,
    );
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

/// fail(默认，直接返回失败)、newcopy(重命名文件)、overwrite(覆写）、skip（跳过）
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

  int get rtype {
    switch (this) {
      case OnDuplicateAction.fail:
        return 0;
      case OnDuplicateAction.newcopy:
        return 1;
      case OnDuplicateAction.skip:
        return 2;
      case OnDuplicateAction.overwrite:
        return 3;
    }
  }
}
