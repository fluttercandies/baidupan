part of 'pan.dart';

typedef Md5Calculated = void Function(BaiduMd5 md5);

/// 处理上传文件
///
/// 具体的上传能力和限制请参考 [官网](https://pan.baidu.com/union/doc/3ksg0s9ye)
///
/// 总体步骤是：
///
/// 1. 预上传
/// 2. 分片上传
/// 3. 合并分片
///
///
/// 切片规则
///
/// 普通用户单个分片大小固定为4MB（文件大小如果小于4MB，无需切片，直接上传即可），单文件总大小上限为4G。
/// 普通会员用户单个分片大小上限为16MB，单文件总大小上限为10G。
/// 超级会员用户单个分片大小上限为32MB，单文件总大小上限为20G。
class BaiduPanUploadManager with BaiduPanMixin {
  /// > 官方关于上传文件夹限制的说明
  /// >
  /// > 每个第三方在网盘只能拥有一个文件夹用于存储上传文件，该文件夹必须位于/apps目录下，
  /// > apps下的文件夹名称为申请接入填写的申请接入的产品名称，假如你申请接入的产品名称为”云存储“，
  /// > 那么该文件夹为/apps/云存储，用户看到的文件夹为/我的应用数据/云存储。
  ///
  /// 但事实上，这限制经我测试，不存在
  const BaiduPanUploadManager({
    required this.accessToken,
    this.showLog = false,
  });

  @override
  final String accessToken;

  @override
  final bool showLog;

  // final String appName;

  /// 预上传，其实就是在远端创建文件或文件夹
  ///
  /// [remotePath] 为远端的上传
  /// [localPath] 为本地的文件路径
  /// [rtype] 为重命名策略
  /// [uploadid] 为上传的id, 这个是远端的上传id，理论上是用于后续的分片上传
  /// [memberLevel] 为用户的会员等级，这个等级决定了可以上传多大的文件和切片规则
  /// [md5Calculated] 为md5计算完成后的回调，用于获取到md5值
  ///
  Future<PreCreate> preCreate({
    required String remotePath,
    required String localPath,
    UploadRenameRtype rtype = UploadRenameRtype.none,
    required int memberLevel,
    String? uploadid,
    BaiduMd5? md5,
    Md5Calculated? onMd5Calculated,
  }) async {
    final path = 'rest/2.0/xpan/file';
    final method = 'precreate';

    // remotePath = '/apps/$appName/$remotePath';
    final body = <String, String>{
      'path': Uri.encodeComponent(remotePath),
      // 'path': remotePath,
      'autoinit': '1',
      'rtype': rtype.index.toString(),
    };

    // final srcLocalPath = localPath;
    // // 先找到真实路径
    // localPath = findRealPath(localPath);
    //
    // if (showLog) {
    //   print('$srcLocalPath => $localPath');
    // }

    // path 上传后使用的文件绝对路径，需要urlencode
    // size	int	是	4096	RequestBody参数	文件或目录的大小，单位B，目录的话大小为0
    // isdir	int	是	0	RequestBody参数	是否目录，0 文件、1 目录
    // autoinit	int	是	1	RequestBody参数	固定值1
    // rtype	int	否	1	RequestBody参数	文件命名策略，默认0
    // 0 为不重命名，返回冲突
    // 1 为只要path冲突即重命名
    // 2 为path冲突且block_list不同才重命名
    // 3 为覆盖
    // uploadid	string	否	P1-MTAuMjI4LjQzLjMxOjE1OTU4NTg==	RequestBody参数	上传id
    // block_list	string	是	["98d02a0f54781a93e354b1fc85caf488", "ca5273571daefb8ea01a42bfa5d02220"]	RequestBody参数	文件各分片MD5数组的json串。block_list的含义如下，如果上传的文件小于4MB，其md5值（32位小写）即为block_list字符串数组的唯一元素；如果上传的文件大于4MB，需要将上传的文件按照4MB大小在本地切分成分片，不足4MB的分片自动成为最后一个分片，所有分片的md5值（32位小写）组成的字符串数组即为block_list。
    // content-md5	string	否	b20f8ac80063505f264e5f6fc187e69a	RequestBody参数	文件MD5
    // slice-md5	string	否	9aa0aa691s5c0257c5ab04dd7eddaa47	RequestBody参数	文件校验段的MD5，校验段对应文件前256KB
    // local_ctime	string	否	1595919297	RequestBody参数	客户端创建时间， 默认为当前时间戳
    // local_mtime	string	否	1595919297	RequestBody参数	客户端修改时间，默认为当前时间戳

    // 根据本地的 localPath 来创建参数
    if (FileSystemEntity.isDirectorySync(localPath)) {
      // 文件夹
      body['size'] = '0';
      body['isdir'] = '1';
    } else if (FileSystemEntity.isFileSync(localPath)) {
      body['size'] = File(localPath).lengthSync().toString();
      body['isdir'] = '0';
    } else {
      throw Exception('不支持的类型');
    }

    final baiduMd5 = md5 ??
        BaiduMd5(
          filePath: localPath,
          memberLevel: memberLevel,
        );

    final blockMd5 = baiduMd5.blockMd5List;

    body['block_list'] = json.encode(blockMd5);

    body['content-md5'] = baiduMd5.contentMd5;
    body['slice-md5'] = baiduMd5.sliceMd5;

    onMd5Calculated?.call(baiduMd5);

    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    body['local_ctime'] = now.toString();
    body['local_mtime'] = now.toString();

    if (uploadid != null) {
      body['uploadid'] = uploadid;
    }

    final map = await _post(
      path: path,
      method: method,
      bodyParams: body,
    );

    return PreCreate.fromJson(map);
  }

  int _getBlockSize(int memberLevel) => PanUtils.getBlockSize(memberLevel);

  Future<UploadPart> uploadSinglePart({
    required String remotePath,
    required String localPath,
    required int memberLevel,
    required String uploadid,
    required int partseq,
  }) async {
    final pcsHost = 'd.pcs.baidu.com';

    final path = 'rest/2.0/pcs/superfile2';
    final method = 'upload';

    final params = {
      'type': 'tmpfile',
      'path': Uri.encodeComponent(remotePath),
      'uploadid': uploadid,
      'partseq': partseq.toString(),
    };

    final blockSize = _getBlockSize(memberLevel);

    final file = File(localPath);
    final accessFile = file.openSync();
    final start = blockSize * partseq;
    var end = start + blockSize;
    final fileLength = file.lengthSync();
    if (end > fileLength) {
      end = fileLength;
    }

    final bufferSize = end - start;
    final buffer = List<int>.filled(bufferSize, 0, growable: true);

    accessFile.setPositionSync(start);
    final readBufferSize = accessFile.readIntoSync(buffer, 0, bufferSize);
    accessFile.closeSync();
    final uploadBytes = buffer.sublist(0, readBufferSize);

    final fileName = Uri.file(remotePath).pathSegments.last;
    final formFile =
        http.MultipartFile.fromBytes('file', uploadBytes, filename: fileName);

    final queryParameters = {
      'access_token': accessToken,
      'method': method,
      ...params,
    };
    final uri = Uri(
      host: pcsHost,
      scheme: 'https',
      path: path,
      queryParameters: queryParameters,
    );

    final request = http.MultipartRequest('POST', uri);
    request.files.add(formFile);
    final response = await request.send();
    final body = await utf8.decodeStream(response.stream);
    final map = json.decode(body);

    return UploadPart.fromJson(map, uploadBytes.length);
  }

  /// 合并分片文件，并创建远端文件
  Future<UploadSuccess> merge({
    required String remotePath,
    required String localPath,
    required String uploadid,
    required List<String> blockMd5List,
    UploadRenameRtype rtype = UploadRenameRtype.alwaysRename,
  }) async {
    final method = 'create';
    var isdir = FileSystemEntity.isDirectorySync(localPath);
    String size;
    if (isdir) {
      // 文件夹
      size = '0';
    } else if (FileSystemEntity.isFileSync(localPath)) {
      size = File(localPath).lengthSync().toString();
    } else {
      throw Exception('不支持的类型');
    }

    final bodyParams = {
      'path': Uri.encodeComponent(remotePath),
      'size': size,
      'isdir': isdir ? '1' : '0',
      'uploadid': uploadid,
      'rtype': rtype.index.toString(),
      'block_list': json.encode(blockMd5List),
    };

    final map = await _post(
      method: method,
      bodyParams: bodyParams,
    );

    return UploadSuccess.fromJson(map);
  }
}

/// 上传文件的命名策略
///
/// 文件命名策略，默认0
/// 0 为不重命名，返回冲突
/// 1 为只要path冲突即重命名
/// 2 为path冲突且block_list不同才重命名
/// 3 为覆盖
enum UploadRenameRtype {
  /// 不重命名
  none,

  /// 只要 path 冲突即重命名
  alwaysRename,

  /// path 冲突且 block_list 不同才重命名
  renameOnBlockList,

  /// 覆盖
  overwrite,
}

typedef BaiduUploadProgress = Function(int count, int max);
