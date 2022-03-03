// {
//   "category": 3,
//   "fs_id": 99826213137861,
//   "isdir": 0,
//   "md5": "b69a70508g865c66c598c62b76d35b15",
//   "path": "/来自：MI 8/DCIM/Screenshots/Screenshot_2022-02-03-19-57-34-699_com.android.settings.jpg",
//   "server_ctime": 1643957079,
//   "server_filename": "Screenshot_2022-02-03-19-57-34-699_com.android.settings.jpg",
//   "server_mtime": 1643957079,
//   "size": 1677010
// }
import 'package:baidupan/baidupan.dart';

///  "cursor": 223,
//   "errmsg": "succ",
//   "errno": 0,
//   "has_more": 1,
class CategoryList {
  final int errno;
  final String errmsg;
  final int hasMore;
  final int cursor;
  final List<CategoryItem> list;

  const CategoryList(
      this.errno, this.errmsg, this.hasMore, this.cursor, this.list);

  factory CategoryList.fromJson(Map<String, dynamic> json) {
    return CategoryList(
      json['errno'] as int,
      json['errmsg'] as String,
      json['has_more'] as int,
      json['cursor'] as int,
      (json['list'] as List).map((e) => CategoryItem.fromJson(e)).toList(),
    );
  }

  @override
  String toString() {
    return 'CategoryList{errno: $errno, errmsg: $errmsg, hasMore: $hasMore, cursor: $cursor, list: $list}';
  }
}

class CategoryItem with ICategoryItem {
  @override
  final int category;
  final int fsId;
  final int isdir;
  final String md5;
  final String path;
  final int serverCtime;
  final String serverFilename;
  final int serverMtime;
  final int size;

  final MediaThumb? thumbs;

  @override
  BaiduCategory get categoryEnum => BaiduCategory.values[category - 1];

  const CategoryItem({
    required this.category,
    required this.fsId,
    required this.isdir,
    required this.md5,
    required this.path,
    required this.serverCtime,
    required this.serverFilename,
    required this.serverMtime,
    required this.size,
    this.thumbs,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      category: json['category'] as int,
      fsId: json['fs_id'] as int,
      isdir: json['isdir'] as int,
      md5: json['md5'] as String,
      path: json['path'] as String,
      serverCtime: json['server_ctime'] as int,
      serverFilename: json['server_filename'] as String,
      serverMtime: json['server_mtime'] as int,
      size: json['size'] as int,
      thumbs: json['thumbs'] == null
          ? null
          : MediaThumb.fromJson(json['thumbs'] as Map<String, dynamic>),
    );
  }

  @override
  String toString() {
    return 'CategoryItem{category: $category, fsId: $fsId, isdir: $isdir, md5: $md5, path: $path, serverCtime: $serverCtime, serverFilename: $serverFilename, serverMtime: $serverMtime, size: $size, thumbs: $thumbs}';
  }
}
