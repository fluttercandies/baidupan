import 'dart:io';

import 'package:baidupan/baidupan.dart';

Future<void> main(List<String> args) async {
  final accessToken = BaiduAuthUtils().getAccessToken();
  final uploader = BaiduPanUploadManager(
    accessToken: accessToken,
    showLog: true,
  );

  if (args.length < 2) {
    print('Usage: bd_upload <src_path> <remote_path>');
    exit(1);
  }

  var localPath = args[0];
  final remotePath = args[1];

  // 检查文件是否存在
  final file = File(localPath);
  if (!file.existsSync()) {
    print('File not found: $localPath');
    exit(2);
  }

  localPath = file.absolute.path;

  // 检查远端文件是否存在
  final baiduPan = BaiduPan(accessToken, showLog: true);
  final remoteName = remotePath.split('/').last;
  final remoteDir =
      remotePath.substring(0, remotePath.length - remoteName.length);

  // 搜索远端文件
  final searchResult = await baiduPan.search(key: remoteName, dir: remoteDir);

  if (searchResult.list.any((element) => element.path == remotePath)) {
    print('File already exists: $remotePath');
    exit(3);
  }

  print('准备上传文件: $localPath, 远端路径: $remotePath');

  final memberLevel = 2;

  final preCreate = await uploader.preCreate(
    remotePath: remotePath,
    localPath: localPath,
    memberLevel: memberLevel,
  );

  final blockMd5List = <String>[];

  for (final index in preCreate.blockList) {
    final partUpload = await uploader.uploadSinglePart(
      remotePath: remotePath,
      localPath: localPath,
      memberLevel: memberLevel,
      uploadid: preCreate.uploadId,
      partseq: index,
    );

    blockMd5List.add(partUpload.md5);
    print('upload progress : ${index + 1}/${preCreate.blockList.length}');
  }

  final completeUpload = await uploader.merge(
    remotePath: remotePath,
    localPath: localPath,
    uploadid: preCreate.uploadId,
    blockMd5List: blockMd5List,
  );

  print(
      'Upload complete: ${completeUpload.path}, total size: ${completeUpload.size}');
}
