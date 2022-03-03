class SearchList {
  final int errno;
  final int hasMore;
  final List<SearchItem> list;

  const SearchList({
    required this.errno,
    required this.hasMore,
    required this.list,
  });

  factory SearchList.fromJson(Map json) {
    return SearchList(
      errno: json['errno'],
      hasMore: json['has_more'],
      list: (json['list'] as List).map((e) => SearchItem.fromJson(e)).toList(),
    );
  }
}

/// {
///       "category": 1,
///       "delete_type": 0,
///       "extent_tinyint1": 0,
///       "fs_id": 698915277947,
///       "isdir": 0,
///       "local_ctime": 1614139266,
///       "local_mtime": 1614139266,
///       "md5": "3d0b9004fn15a13dd35763a5b44402e3",
///       "oper_id": 2469771319,
///       "owner_id": 0,
///       "path": "\/\u7092\u80a1\u4e13\u7528\/\u65e0\u4e3a\/\u5e38\u89c4\u76f4\u64ad\/2021-02-24\/2021\u5e742\u670824\u65e5 \u5e08\u5f92\u804a\u884c\u60c5.mkv",
///       "server_ctime": 1614220286,
///       "server_filename": "2021\u5e742\u670824\u65e5 \u5e08\u5f92\u804a\u884c\u60c5.mkv",
///       "server_mtime": 1615352492,
///       "share": 0,
///       "size": 246073844,
///       "wpfile": 0
///     }
class SearchItem {
  final int category;
  final int deleteType;
  final int extentTinyint1;
  final int fsId;
  final int isdir;
  final int localCtime;
  final int localMtime;
  final String md5;
  final int operId;
  final int ownerId;
  final String path;
  final int serverCtime;
  final String serverFilename;
  final int serverMtime;
  final int share;
  final int size;
  final int wpfile;

  const SearchItem(
      this.category,
      this.deleteType,
      this.extentTinyint1,
      this.fsId,
      this.isdir,
      this.localCtime,
      this.localMtime,
      this.md5,
      this.operId,
      this.ownerId,
      this.path,
      this.serverCtime,
      this.serverFilename,
      this.serverMtime,
      this.share,
      this.size,
      this.wpfile);

  factory SearchItem.fromJson(Map<String, dynamic> json) {
    return SearchItem(
      json['category'],
      json['delete_type'],
      json['extent_tinyint1'],
      json['fs_id'],
      json['isdir'],
      json['local_ctime'],
      json['local_mtime'],
      json['md5'],
      json['oper_id'],
      json['owner_id'],
      json['path'],
      json['server_ctime'],
      json['server_filename'],
      json['server_mtime'],
      json['share'],
      json['size'],
      json['wpfile'],
    );
  }

  @override
  String toString() {
    return 'SearchItem{category: $category, deleteType: $deleteType, extentTinyint1: $extentTinyint1, fsId: $fsId, isdir: $isdir, localCtime: $localCtime, localMtime: $localMtime, md5: $md5, operId: $operId, ownerId: $ownerId, path: $path, serverCtime: $serverCtime, serverFilename: $serverFilename, serverMtime: $serverMtime, share: $share, size: $size, wpfile: $wpfile}';
  }
}
