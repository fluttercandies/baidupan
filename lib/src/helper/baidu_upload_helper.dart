import 'dart:convert';
import 'dart:io';

import 'package:baidupan/baidupan.dart';

/// 对于上传百度网盘的包装类
///
/// 用于支持续传，在网络出错或上传合成失败的情况下，也可以重新上传
class BaiduUploadHelper with ILogger {
  /// 百度网盘上传的包装类
  ///
  /// [accessToken] 百度网盘的token
  /// [localPath] 本地文件路径
  /// [remotePath] 网盘文件路径
  /// [memberLevel] 百度网盘的用户等级
  BaiduUploadHelper({
    required this.accessToken,
    required String localPath,
    required this.remotePath,
    required this.memberLevel,
    this.totalRetryCount = 10,
  })  : localPath = File(localPath).absolute.path,
        lastModified = File(localPath).lastModifiedSync();

  /// [accessToken] 百度网盘的token
  /// [resumeMap] 续传的map, 一般由 [getSaveProgressMap] 返回
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

  /// 本地文件的路径， 保存进度的一部分
  final String localPath;

  /// 网盘的路径， 保存进度的一部分
  final String remotePath;

  /// 会员等级： 0 为非会员，1 为普通会员，2 为超级会员， 保存进度的一部分
  final int memberLevel;

  /// 重试次数
  final int totalRetryCount;

  /// 上传的文件 md5 值， 保存进度的一部分
  BaiduMd5? _md5;

  BaiduMd5 get md5 {
    _md5 ??= BaiduMd5(
      filePath: localPath,
      memberLevel: memberLevel,
    );

    return _md5!;
  }

  DateTime lastModified;

  bool _isUploading = false;

  /// 是否正在上传
  bool get isUploading => _isUploading;

  String? _uploadId;

  /// 共有多少个文件块
  int totalBlockCount = 0;

  /// uploadCount 已上传的文件块数量，会被保存到 progress 里
  int uploadCount = 0;

  /// 当前上传的文件块数量
  int currentUploadCount = 0;

  /// 文件大小 [File.lengthSync]
  int get fileTotalSize => File(localPath).lengthSync();

  /// 上传的速度，单位为字节/秒
  int uploadSpeed = 0;

  /// 上传的进度, 范围为 0.0 - 1.0
  double getProgress() {
    if (totalBlockCount == 0) {
      return 0.0;
    }
    // 文件块的总数量
    final blockSize = PanUtils.getBlockSize(memberLevel);

    // 获取已上传的文件块数量，并计算总上传的字节数
    final totalUploadBytes = blockSize * uploadCount;

    final progress = totalUploadBytes / fileTotalSize;

    if (progress > 1.0) {
      return 1.0;
    }

    return progress;
  }

  /// 获取应该被保存的 map
  Map<String, dynamic> getSaveProgressMap() {
    return {
      'uploadId': _uploadId,
      'localPath': localPath,
      'remotePath': remotePath,
      'memberLevel': memberLevel,
      'saveFileLength': fileTotalSize,
      'md5': md5.toMap(),
      'uploadCount': uploadCount,
      'lastModified': lastModified.millisecondsSinceEpoch,
    };
  }

  /// 恢复上传进度，注意这里还是需要自行调用 [startUpload] 方法
  void resumeProgressInfo(Map progress) {
    final localPath = progress['localPath'] as String;
    final remotePath = progress['remotePath'] as String;
    final memberLevel = progress['memberLevel'] as int;
    final saveFileLength = progress['saveFileLength'] as int;

    final lastModifiedMs = progress['lastModified'] as int;

    if (lastModifiedMs != lastModified.millisecondsSinceEpoch) {
      throw Exception('修改时间不一致，可能文件被修改过，不支持续传');
    }

    if (saveFileLength != fileTotalSize) {
      throw Exception('文件大小不一致，可能文件已经被修改，不支持续传');
    }

    // 读取上传的文件的 md5 码

    if (localPath != this.localPath || remotePath != this.remotePath) {
      throw Exception('localPath or remotePath is not equal');
    }

    if (memberLevel != this.memberLevel) {
      throw Exception('memberLevel 不一致，可能会造成分块大小不同，所以不支持续传');
    }

    _uploadId = progress['uploadId'];

    // 恢复生成的 md5 值
    _md5 = BaiduMd5.fromMap(progress['md5']);

    uploadCount = progress['uploadCount'] as int;
  }

  /// 保存进度到文件
  void saveProgressToFile(String filePath) {
    final progress = getSaveProgressMap();
    final text = json.encode(progress);
    final bytes = utf8.encode(text);
    final file = File(filePath);
    if (!file.existsSync()) {
      file.createSync();
    }
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

  int _currentRetryCount = 0;

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
      _isUploading = false;
      if (uploadHandler != null) {
        uploadHandler.onUploadError(this, e, st);
      } else {
        logError('上传出错', e, st);
      }
      _currentRetryCount++;
      if (_currentRetryCount < totalRetryCount) {
        await Future.delayed(Duration(seconds: 1));
        await startUpload(uploadHandler);
      }
    }
  }

  Future<void> _upload(UploadHelperListener? uploadHandler) async {
    final uploader = BaiduPanUploadManager(
      accessToken: accessToken,
      showLog: isShowLog,
    );

    final preCreate = await uploader.preCreate(
      remotePath: remotePath,
      localPath: localPath,
      memberLevel: memberLevel,
      uploadid: _uploadId,
      md5: md5,
      onMd5Calculated: (md5) {
        uploadHandler?.onLocalMd5Complete(this);
      },
    );

    if (preCreate.fastUpload) {
      // 快速上传
      return;
    }

    final uploadId = preCreate.uploadId;

    if (uploadId == null) {
      throw Exception('uploadId is null');
    }

    _uploadId = uploadId;

    totalBlockCount = preCreate.blockList.length;

    final stopwatch = Stopwatch();
    stopwatch.start();
    var uploadBytes = 0;

    currentUploadCount = 0;

    for (final blockIndex in preCreate.blockList) {
      final block = await uploader.uploadSinglePart(
        remotePath: remotePath,
        localPath: localPath,
        memberLevel: memberLevel,
        uploadid: uploadId,
        partseq: blockIndex,
      );

      currentUploadCount++;
      uploadCount++;

      final uploadTimeMs = stopwatch.elapsedMilliseconds;
      uploadBytes += block.blockSize;
      uploadSpeed = uploadBytes ~/ (uploadTimeMs / 1000);

      uploadHandler?.onUploadPartComplete(this, blockIndex, block.md5);
    }
    stopwatch.stop();

    final blockMd5List = md5.blockMd5List;

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
/// [onUploadStart] :开始上传
///
/// [onUploadPartComplete] :上传一个块完毕后的回调
///
/// [onUploadComplete] :上传完成时的回调
///
/// [onUploadError] :上传出错时的回调
mixin UploadHelperListener {
  /// 上传开始
  void onUploadStart(BaiduUploadHelper helper) {}

  /// 计算完 md5 后的回调
  void onLocalMd5Complete(BaiduUploadHelper helper) {}

  /// 一个块上传完成的回调
  ///
  /// [index] 为块索引， [md5] 为块的md5
  void onUploadPartComplete(
    BaiduUploadHelper helper,
    int index,
    String md5,
  ) {}

  /// 上传完成的回调
  void onUploadComplete(
    BaiduUploadHelper helper,
  ) {}

  /// 上传出错的回调
  void onUploadError(
    BaiduUploadHelper helper,
    Object error,
    StackTrace stackTrace,
  ) {}
}
