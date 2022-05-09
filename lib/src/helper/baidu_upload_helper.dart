import 'dart:convert';
import 'dart:io';

import 'package:baidupan/baidupan.dart';
import 'package:baidupan/src/util/pan_utils.dart';

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
  List<_PartBlock> get uploadedBlocks {
    return _blockMd5Map.entries.map((e) => _PartBlock(e.key, e.value)).toList();
  }

  bool _isUploading = false;

  /// 是否正在上传
  bool get isUploading => _isUploading;

  String? _uploadId;

  /// 共有多少个文件块
  int totalBlockCount = 0;

  /// uploadCount 已上传的文件块数量
  int uploadCount = 0;

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

    return totalUploadBytes / fileTotalSize;
  }

  /// 获取应该被保存的 map
  Map<String, dynamic> saveProgress() {
    if (_uploadId == null) {
      throw Exception('uploadId is null, please call startUpload() first');
    }

    return {
      'uploadId': _uploadId,
      'uploadedBlocks': uploadedBlocks.map((e) => e.toJson()).toList(),
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

    final uploadedBlocks = progress['uploadedBlocks'] as List;
    uploadedBlocks.forEach((e) {
      final block = _PartBlock.fromMap(e);
      _blockMd5Map[block.block] = block.md5;
    });
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

    final stopwatch = Stopwatch();
    stopwatch.start();
    var uploadBytes = 0;

    uploadCount = 0;

    for (final blockIndex in preCreate.blockList) {
      if (_blockMd5Map.containsKey(blockIndex)) {
        uploadCount++;
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

      final uploadTimeMs = stopwatch.elapsedMilliseconds;
      uploadBytes += block.blockSize;
      uploadSpeed = uploadBytes ~/ (uploadTimeMs / 1000);

      _blockMd5Map[blockIndex] = block.md5;
      uploadCount++;
      uploadHandler?.onUploadPartComplete(this, blockIndex, block.md5);
    }
    stopwatch.stop();

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

class _PartBlock {
  final int block;
  final String md5;

  _PartBlock(this.block, this.md5);

  _PartBlock.fromMap(Map map)
      : block = map['block'] as int,
        md5 = map['md5'] as String;

  Map<String, dynamic> toJson() {
    return {
      'block': block,
      'md5': md5,
    };
  }
}
