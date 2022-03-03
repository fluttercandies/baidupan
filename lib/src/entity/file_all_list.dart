// "cursor": 56,
// "errmsg": "succ",
// "errno": 0,
// "has_more": 0,
import 'package:baidupan/baidupan.dart';

mixin ICategoryItem {
  int get category;

  BaiduCategory get categoryEnum => BaiduCategory.values[category - 1];
}

class FileAllList {
  final int cursor;
  final String errmsg;
  final int errno;
  final int hasMore;
  final List<FileInfo> list;

  FileAllList.fromParams(
      this.cursor, this.errmsg, this.errno, this.hasMore, this.list);

  static FileAllList fromJson(Map jsonRes) {
    var list =
        (jsonRes['list'] as List).map((e) => FileInfo.fromJson(e)).toList();
    return FileAllList.fromParams(jsonRes['cursor'], jsonRes['errmsg'],
        jsonRes['errno'], jsonRes['has_more'], list);
  }

  Map toJson() => {
        'cursor': cursor,
        'errmsg': errmsg,
        'errno': errno,
        'has_more': hasMore,
        'list': list,
      };

  @override
  String toString() {
    return 'FileAllList{cursor: $cursor, hasMore: $hasMore, list: $list}';
  }
}

// "category": 6,
// "fs_id": 1074008346589767,
// "isdir": 1,
// "local_ctime": 1537621220,
// "local_mtime": 1537621220,
// "md5": "",
// "path": "/apps",
// "server_ctime": 1537621220,
// "server_filename": "apps",
// "server_mtime": 1537621220,
// "size": 0
class FileInfo with ICategoryItem {
  @override
  final int category;
  final int fsId;
  final int isdir;
  final int localCtime;
  final int localMtime;
  final String md5;
  final String path;
  final int serverCtime;
  final int serverMtime;
  final int size;

  const FileInfo({
    required this.category,
    required this.fsId,
    required this.isdir,
    required this.localCtime,
    required this.localMtime,
    required this.md5,
    required this.path,
    required this.serverCtime,
    required this.serverMtime,
    required this.size,
  });

  factory FileInfo.fromJson(Map json) {
    return FileInfo(
      category: json['category'],
      fsId: json['fs_id'],
      isdir: json['isdir'],
      localCtime: json['local_ctime'],
      localMtime: json['local_mtime'],
      md5: json['md5'],
      path: json['path'],
      serverCtime: json['server_ctime'],
      serverMtime: json['server_mtime'],
      size: json['size'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['category'] = category;
    data['fs_id'] = fsId;
    data['isdir'] = isdir;
    data['local_ctime'] = localCtime;
    data['local_mtime'] = localMtime;
    data['md5'] = md5;
    data['path'] = path;
    data['server_ctime'] = serverCtime;
    data['server_mtime'] = serverMtime;
    data['size'] = size;
    return data;
  }

  @override
  String toString() {
    return 'FileAllItem{category: $category, fsId: $fsId, isdir: $isdir, localCtime: $localCtime, localMtime: $localMtime, md5: $md5, path: $path, serverCtime: $serverCtime, serverMtime: $serverMtime, size: $size}';
  }
}
