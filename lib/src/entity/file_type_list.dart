import 'package:baidupan/baidupan.dart';

class TypeFileList<T> {
  final List<T> info;

  const TypeFileList(this.info);

  static TypeFileList<T> convertToInfo<T>(
      Map json, T Function(Map json) creator) {
    final list = json['info'] as List;
    final info = list.map((e) => creator(e as Map<String, dynamic>)).toList();
    return TypeFileList<T>(info);
  }
}

mixin IFileItem on ICategoryItem {
  FileInfo get info;

  @override
  int get category => info.category;
}

class DocItem with ICategoryItem, IFileItem {
  final String lodocpreview;
  final String docpreview;

  @override
  final FileInfo info;

  DocItem(this.lodocpreview, this.docpreview, this.info);

  static DocItem fromJson(Map json) {
    return DocItem(
      json['lodocpreview'],
      json['docpreview'],
      FileInfo.fromJson(json),
    );
  }

  Map toJson() {
    return {
      'lodocpreview': lodocpreview,
      'docpreview': docpreview,
      ...info.toJson(),
    };
  }

  @override
  String toString() {
    return 'DocItem{lodocpreview: $lodocpreview, docpreview: $docpreview, info: $info}';
  }
}

class MediaThumb {
  final String? icon;
  final String url1;
  final String url2;
  final String url3;

  const MediaThumb(this.icon, this.url1, this.url2, this.url3);

  static MediaThumb fromJson(Map json) {
    return MediaThumb(
      json['icon'],
      json['url1'],
      json['url2'],
      json['url3'],
    );
  }
}

class MediaItem with ICategoryItem, IFileItem {
  final MediaThumb thumbs;

  @override
  final FileInfo info;

  MediaItem(this.thumbs, this.info);

  static MediaItem fromJson(Map json) {
    final thumbsMap = json['thumbs'] as Map;
    return MediaItem(
      MediaThumb(
        thumbsMap['icon'],
        thumbsMap['url1'],
        thumbsMap['url2'],
        thumbsMap['url3'],
      ),
      FileInfo.fromJson(json),
    );
  }
}

class BtItem with ICategoryItem, IFileItem {
  @override
  final FileInfo info;

  const BtItem(this.info);

  static BtItem fromJson(Map json) {
    return BtItem(FileInfo.fromJson(json));
  }
}
