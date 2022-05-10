import 'dart:convert';
import 'dart:io';

import 'package:baidupan/baidupan.dart';

Future<void> main() async {
  final auth = loadAuth();

  try {
    final uploaderManager = BaiduPanUploadManager(
      accessToken: auth.accessToken,
      showLog: true,
    );

    var localFilePath = './bin/bd_upload.dart';
    var memberLevel = 2;
    var remotePath = '/Test/Hello/test.txt';
    final preCreate = await uploaderManager.preCreate(
      remotePath: remotePath,
      localPath: localFilePath,
      memberLevel: memberLevel,
    );

    final blockMd5List = <UploadPart>[];

    if (preCreate.fastUpload) {
      // 快速上传
      print('秒传成功');
      return;
    }

    final uploadId = preCreate.uploadId;

    if (uploadId == null) {
      throw Exception('uploadId is null');
    }

    for (final blockIndex in preCreate.blockList) {
      final part = await uploaderManager.uploadSinglePart(
        remotePath: remotePath,
        localPath: localFilePath,
        memberLevel: memberLevel,
        uploadid: uploadId,
        partseq: blockIndex,
      );

      blockMd5List.add(part);

      print('part of $blockIndex uploaded, md5: ${part.md5}');
    }

    await uploaderManager.merge(
      remotePath: remotePath,
      localPath: localFilePath,
      uploadid: uploadId,
      blockMd5List: blockMd5List.map((e) => e.md5).toList(),
    );
  } catch (e, st) {
    print('发生错误: $e');
    print('错误堆栈: $st');
  }

  // final watch = Stopwatch();
  // watch.start();
  // var fileMd5 = Md5Utils.getFileMd5('/Users/jinglongcai/Downloads/abc.mp4');
  // watch.stop();
  //
  // print('fileMd5: $fileMd5, run time: ${watch.elapsedMilliseconds}ms');
}

BaiduAuth loadAuth() {
  final authFilePath = 'authory.json';

  final authFile = File(authFilePath);
  final text = authFile.readAsStringSync();
  final auth = BaiduAuth.fromJson(json.decode(text));

  return auth;
}
