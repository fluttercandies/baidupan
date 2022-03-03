// rest/2.0/xpan/file

import 'package:baidupan/baidupan.dart';

class FileList {
  final String guidInfo;
  final int guid;
  final int requestId;
  final List<FileItem> list;

  FileList({
    required this.guidInfo,
    required this.guid,
    required this.requestId,
    required this.list,
  });

  static FileList fromJson(Map<String, dynamic> json) {
    return FileList(
      guidInfo: json['guid_info'],
      guid: json['guid'],
      requestId: json['request_id'],
      list: (json['list'] as List).map((e) => FileItem.fromJson(e)).toList(),
    );
  }
}

// {
//    "tkbind_id": 0,
//    "category": 6,
//    "real_category": "",
//    "isdir": 1,
//    "server_filename": "apps",
//    "path": "\/apps",
//    "wpfile": 0,
//    "server_atime": 0,
//    "server_ctime": 1537621220,
//    "extent_tinyint7": 0,
//    "owner_id": 0,
//    "local_mtime": 1537621220,
//    "size": 0,
//    "unlist": 0,
//    "share": 0,
//    "server_mtime": 1537621220,
//    "pl": 0,
//    "local_ctime": 1537621220,
//    "owner_type": 0,
//    "oper_id": 0,
//    "fs_id": 1074008346589767
//  }
class FileItem with ICategoryItem {
  final int tkbindId;
  @override
  final int category;
  final String realCategory;
  final int isdir;
  final String serverFilename;
  final String path;
  final int wpfile;
  final int serverAtime;
  final int serverCtime;
  final int extentTinyint7;
  final int ownerId;
  final int localMtime;
  final int size;
  final int unlist;
  final int share;
  final int serverMtime;
  final int pl;
  final int localCtime;
  final int ownerType;
  final int operId;
  final int fsId;

  bool get isDir => isdir == 1;

  @override
  BaiduCategory get categoryEnum => BaiduCategory.values[category - 1];

  const FileItem({
    required this.tkbindId,
    required this.category,
    required this.realCategory,
    required this.isdir,
    required this.serverFilename,
    required this.path,
    required this.wpfile,
    required this.serverAtime,
    required this.serverCtime,
    required this.extentTinyint7,
    required this.ownerId,
    required this.localMtime,
    required this.size,
    required this.unlist,
    required this.share,
    required this.serverMtime,
    required this.pl,
    required this.localCtime,
    required this.ownerType,
    required this.operId,
    required this.fsId,
  });

  static FileItem fromJson(Map<String, dynamic> json) {
    // 从json中获取值

    int tkbindId = json['tkbind_id'];
    int category = json['category'];
    String realCategory = json['real_category'];
    int isdir = json['isdir'];
    String serverFilename = json['server_filename'];
    String path = json['path'];
    int wpfile = json['wpfile'];
    int serverAtime = json['server_atime'];
    int serverCtime = json['server_ctime'];
    int extentTinyint7 = json['extent_tinyint7'];
    int ownerId = json['owner_id'];
    int localMtime = json['local_mtime'];
    int size = json['size'];
    int unlist = json['unlist'];
    int share = json['share'];
    int serverMtime = json['server_mtime'];
    int pl = json['pl'];
    int localCtime = json['local_ctime'];
    int ownerType = json['owner_type'];
    int operId = json['oper_id'];
    int fsId = json['fs_id'];

    return FileItem(
      tkbindId: tkbindId,
      category: category,
      ownerId: ownerId,
      localMtime: localMtime,
      size: size,
      unlist: unlist,
      share: share,
      serverMtime: serverMtime,
      pl: pl,
      localCtime: localCtime,
      ownerType: ownerType,
      operId: operId,
      fsId: fsId,
      realCategory: realCategory,
      isdir: isdir,
      serverFilename: serverFilename,
      path: path,
      wpfile: wpfile,
      serverAtime: serverAtime,
      serverCtime: serverCtime,
      extentTinyint7: extentTinyint7,
    );
  }

  Map toJson() {
    return {
      'tkbind_id': tkbindId,
      'category': category,
      'ownerId': ownerId,
      'localMtime': localMtime,
      'size': size,
      'unlist': unlist,
      'share': share,
      'serverMtime': serverMtime,
      'pl': pl,
      'localCtime': localCtime,
      'ownerType': ownerType,
      'operId': operId,
      'fsId': fsId,
      'realCategory': realCategory,
      'isdir': isdir,
      'serverFilename': serverFilename,
      'path': path,
      'wpfile': wpfile,
      'serverAtime': serverAtime,
      'serverCtime': serverCtime,
      'extentTinyint7': extentTinyint7,
    };
  }

  @override
  String toString() {
    return 'FileItem { server_filename: $serverFilename, path: $path, isdir: $isdir, fs_id: $fsId }';
  }
}
