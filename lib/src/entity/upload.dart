// The file: null-safety

// {"path":"\/apps\/dart\u4e0a\u4f20\/1.dart","uploadid":"N1-MjIxLjIxOS4xODQuODA6MTY0NjE5NDAzMzoyNTAzNjA1OTg3MDUxNTYwNTE=","return_type":1,"block_list":[0],"errno":0,"request_id":250360598705156051}
class PreCreate {
  final String? path;
  final int returnType;

  /// 文件块的 index 数组，理论上这个为空数组时，表示不需要上传文件块，可以支持秒传
  final List<int> blockList;
  final int errno;
  final int requestId;
  final String? uploadId;

  // 秒传
  bool get fastUpload => uploadId == null && blockList.isEmpty;

  const PreCreate({
    required this.path,
    required this.returnType,
    required this.blockList,
    required this.errno,
    required this.requestId,
    required this.uploadId,
  });

  static PreCreate fromJson(Map json) {
    List<int> blockList;
    final blockJson = json['block_list'];
    if (blockJson != null) {
      // ignore: no_leading_underscores_for_local_identifiers
      final _blockValue = blockJson as List;
      blockList = _blockValue.whereType<int>().toList();
    } else {
      blockList = [];
    }

    return PreCreate(
      path: json['path'],
      returnType: json['return_type'],
      blockList: blockList,
      errno: json['errno'],
      requestId: json['request_id'],
      uploadId: json['uploadid'],
    );
  }
}

// {"md5":"1fdb978218079ba2c728a995a66e4e46","request_id":1405365793443231054}
class UploadPart {
  final String md5;
  final int requestId;
  final int blockSize;

  UploadPart({
    required this.md5,
    required this.requestId,
    required this.blockSize,
  });

  factory UploadPart.fromJson(Map json, int fileSize) {
    return UploadPart(
      md5: json['md5'],
      requestId: json['request_id'],
      blockSize: fileSize,
    );
  }
}

// {"category":4,"ctime":1646214940,"from_type":1,"fs_id":739070475455326,"isdir":0,"md5":"aba19e3afi901c068bfbc22abd903dea","mtime":1646214940,"path":"\/Test\/Hello\/test_20220302_175540.txt","server_filename":"test_20220302_175540.txt","size":1340,"errno":0,"name":"\/Test\/Hello\/test_20220302_175540.txt"}
class UploadSuccess {
  final int category;
  final int ctime;
  final int fromType;
  final int fsId;
  final int isdir;
  final String md5;
  final int mtime;
  final String path;
  final String? serverFilename;
  final int size;
  final int errno;
  final String name;

  UploadSuccess({
    required this.category,
    required this.ctime,
    required this.fromType,
    required this.fsId,
    required this.isdir,
    required this.md5,
    required this.mtime,
    required this.path,
    required this.serverFilename,
    required this.size,
    required this.errno,
    required this.name,
  });

  factory UploadSuccess.fromJson(Map json) {
    return UploadSuccess(
      category: json['category'],
      ctime: json['ctime'],
      fromType: json['from_type'],
      fsId: json['fs_id'],
      isdir: json['isdir'],
      md5: json['md5'],
      mtime: json['mtime'],
      path: json['path'],
      serverFilename: json['server_filename'],
      size: json['size'],
      errno: json['errno'],
      name: json['name'],
    );
  }
}
