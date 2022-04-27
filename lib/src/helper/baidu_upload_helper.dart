import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:baidupan/baidupan.dart';

/// 对于上传百度网盘的包装类
///
/// 用于支持续传，而不要求一次性全传完
class BaiduUploadHelper with ILogger {
  /// 百度网盘上传的包装类
  ///
  /// [accessToken] 百度网盘的token
  /// [localPath] 本地文件路径
  /// [remotePath] 网盘文件路径
  /// [memberLevel] 百度网盘的用户等级
  BaiduUploadHelper({
    required this.accessToken,
    required this.localPath,
    required this.remotePath,
    required this.memberLevel,
  });

  /// [accessToken] 百度网盘的token
  /// [resumeMap] 续传的map, 一般由 [saveProgress] 返回
  factory BaiduUploadHelper.resumeFromMap({
    required String accessToken,
    required Map resumeMap,
  }) {
    final helper = BaiduUploadHelper(
      accessToken: accessToken,
      localPath: resumeMap['localPath'],
      remotePath: resumeMap['remotePath'],
      memberLevel: resumeMap['memberLevel'],
    );

    helper.resumeProgressInfo(resumeMap);
    return helper;
  }

  /// [accessToken] 百度网盘的token
  /// [resumeFile] 续传的配置文件，一般来自于 [saveProgressToFile]
  factory BaiduUploadHelper.resumeFromFile({
    required String accessToken,
    required File resumeFile,
  }) {
    final map = json.decode(resumeFile.readAsStringSync());
    return BaiduUploadHelper.resumeFromMap(
      accessToken: accessToken,
      resumeMap: map,
    );
  }

  /// 百度网盘的accessToken
  final String accessToken;

  /// 本地文件的路径
  final String localPath;

  /// 网盘的路径
  final String remotePath;

  /// 会员等级： 0 为非会员，1 为普通会员，2 为超级会员
  final int memberLevel;

  /// 记录已上传部分的md5码
  final Map<int, String> _blockMd5Map = {};

  /// 已上传的文件块
  Map<int, String> get uploadedBlocks {
    return LinkedHashMap.fromEntries(
      _blockMd5Map.entries.toList()..sort((a, b) => a.key - b.key),
    );
  }

  bool _isUploading = false;

  /// 是否正在上传
  bool get isUploading => _isUploading;

  String? _uploadId;

  /// 共有多少个文件块
  int totalBlockCount = 0;

  /// 获取应该被保存的 map
  Map<String, dynamic> saveProgress() {
    if (_uploadId == null) {
      throw Exception('uploadId is null, please call startUpload() first');
    }

    return {
      'uploadId': _uploadId,
      'uploadedBlocks': uploadedBlocks,
      'localPath': localPath,
      'remotePath': remotePath,
      'memberLevel': memberLevel,
    };
  }

  /// 恢复上传进度，注意这里还是需要自行调用 [startUpload] 方法
  void resumeProgressInfo(Map progress) {
    final localPath = progress['localPath'] as String;
    final remotePath = progress['remotePath'] as String;
    final memberLevel = progress['memberLevel'] as int;

    if (localPath != this.localPath || remotePath != this.remotePath) {
      throw Exception('localPath or remotePath is not equal');
    }

    if (memberLevel != this.memberLevel) {
      throw Exception('memberLevel 不一致，可能会造成分块大小不同，所以不支持续传');
    }

    _uploadId = progress['uploadId'];
    _blockMd5Map.addAll(progress['uploadedBlocks']);
  }

  /// 保存进度到文件
  void saveProgressToFile(String filePath) {
    final progress = saveProgress();
    final text = json.encode(progress);
    final bytes = utf8.encode(text);
    final file = File(filePath);
    file.writeAsBytesSync(bytes);
  }

  /// 从文件中恢复进度
  void loadProgressFromFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      return;
    }
    final text = file.readAsStringSync();
    final progress = json.decode(text);
    resumeProgressInfo(progress);
  }

  /// 开始上传
  Future<void> startUpload([UploadHelperListener? uploadHandler]) async {
    if (isUploading) {
      return;
    }
    _isUploading = true;
    try {
      uploadHandler?.onUploadStart(this);
      await _upload(uploadHandler);
      uploadHandler?.onUploadComplete(this);
      _isUploading = false;
    } catch (e, st) {
      if (uploadHandler != null) {
        uploadHandler.onUploadError(this, e, st);
      } else {
        logError('上传出错', e, st);
      }
      _isUploading = false;
    }
  }

  Future<void> _upload(UploadHelperListener? uploadHandler) async {
    final uploader = BaiduPanUploadManager(accessToken: accessToken);
    final preCreate = await uploader.preCreate(
      remotePath: remotePath,
      localPath: localPath,
      memberLevel: memberLevel,
      uploadid: _uploadId,
    );

    final uploadId = preCreate.uploadId;
    _uploadId = uploadId;

    totalBlockCount = preCreate.blockList.length;

    for (final blockIndex in preCreate.blockList) {
      if (_blockMd5Map.containsKey(blockIndex)) {
        log('已经上传过的块：$blockIndex, 跳过');
        continue;
      }
      final block = await uploader.uploadSinglePart(
        remotePath: remotePath,
        localPath: localPath,
        memberLevel: memberLevel,
        uploadid: uploadId,
        partseq: blockIndex,
      );

      _blockMd5Map[blockIndex] = block.md5;
      uploadHandler?.onUploadPartComplete(this, blockIndex, block.md5);
    }

    final md5List = _blockMd5Map.entries.toList();
    md5List.sort((a, b) => a.key.compareTo(b.key));
    final blockMd5List = md5List.map((e) => e.value).toList();

    final complete = await uploader.merge(
      remotePath: remotePath,
      localPath: localPath,
      uploadid: uploadId,
      blockMd5List: blockMd5List,
    );

    log('上传完成：$complete');
  }
}

/// 上传的回调， 是一个 mixin
///
/// 按需自行覆盖对应的方法
///
/// [onUploadStart]: 开始上传
///
/// [onUploadPartComplete]: 上传一个块完毕后的回调
///
/// [onUploadComplete]: 上传完成时的回调
///
/// [onUploadError]: 上传出错时的回调
mixin UploadHelperListener {
  /// 上传开始
  void onUploadStart(BaiduUploadHelper helper) {}

  void onUploadPartComplete(
    BaiduUploadHelper helper,
    int index,
    String md5,
  ) {}

  void onUploadComplete(
    BaiduUploadHelper helper,
  ) {}

  void onUploadError(
    BaiduUploadHelper helper,
    Object error,
    StackTrace stackTrace,
  ) {}
}
