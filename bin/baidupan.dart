// ignore_for_file: unused_element, unused_local_variable

import 'dart:convert';
import 'dart:io';

import 'package:baidupan/baidupan.dart';

Future<void> main(List<String> arguments) async {
  final authFilePath = 'authory.json';

  final authFile = File(authFilePath);
  final text = authFile.readAsStringSync();
  final auth = BaiduAuth.fromJson(json.decode(text));

  final baiduPan = BaiduPan.withAuth(auth, showLog: true);

  // await baiduPan.getUserInfo().then((userInfo) {
  //   print(userInfo);
  // });

  // baiduPan.getDiskSpace().then((diskSpace) {
  //   print(diskSpace);
  // });

  // _getFileListExample(baiduPan);

  // _getFileAll(baiduPan);

  // _getDocList(baiduPan);

  // _getCount(baiduPan);

  // _getCategoryList(baiduPan);

  // _searchAndDownload(baiduPan);

  // await _managerExample(auth);

  await createFolder(auth);
}

Future<void> createFolder(BaiduAuth auth) async {
  final manager = BaiduPanFileManager(auth.accessToken, showLog: true);
  final result = await manager.createFolder(path: '/test-create-by-api');
  print(json.encode(result));
}

Future<void> _managerExample(BaiduAuth auth) async {
  final manager = BaiduPanFileManager(auth.accessToken, showLog: true);

  await manager.copy(
    [
      CopyOrMoveItem(
        path: '/Test/1.png',
        dest: '/Test',
        newname: '2.png',
        ondup: OnDuplicateAction.fail,
      ),
      CopyOrMoveItem(
        path: '/Test/1.png',
        dest: '/Test',
        newname: '5.png',
        ondup: OnDuplicateAction.fail,
      ),
      CopyOrMoveItem(
        path: '/Test/1.png',
        dest: '/Test',
        newname: '6.png',
        ondup: OnDuplicateAction.fail,
      ),
    ],
    onDuplicateAction: OnDuplicateAction.fail,
  );

  await manager.rename(
    [
      RenameItem(
        path: '/Test/2.png',
        newName: '3.png',
      ),
    ],
  );

  await manager.move(
    [
      CopyOrMoveItem(
        path: '/Test/5.png',
        dest: '/Test/Test2',
        newname: '5.png',
        ondup: OnDuplicateAction.fail,
      ),
      CopyOrMoveItem(
        path: '/Test/6.png',
        dest: '/Test/Test2',
        newname: '6.png',
        ondup: OnDuplicateAction.fail,
      ),
    ],
    onDuplicateAction: OnDuplicateAction.fail,
  );

  await manager.delete(
    [
      '/Test/Test2/5.png',
    ],
  );
}

void _searchAndDownload(BaiduPan baiduPan) async {
  final list = await baiduPan.search(key: '师徒', recursion: true);
  final fsIds = list.list.sublist(0, 3).map((e) => e.fsId).toList();

  final metaList = await baiduPan.getMetaData(fsIds: fsIds);
  final metaItem = metaList.list[1];
  final downloadRequest = baiduPan.getDownloadRequest(metaItem);

  final file = File('output/1.mkv');
  file.createSync(recursive: true);

  final writer = file.openSync(mode: FileMode.write);
  final resp = await downloadRequest.send();

  print('download status code: ${resp.statusCode}');

  await resp.stream.listen((value) {
    writer.writeFromSync(value);
  }).asFuture();

  writer.closeSync();
}

void _getCategoryList(BaiduPan baiduPan) async {
  final categoryList = await baiduPan.getCategoryList(
    categorys: [
      BaiduCategory.audio,
      BaiduCategory.video,
      BaiduCategory.image,
    ],
    start: 0,
    limit: 30,
    ext: [/*'mp3', 'mp4',*/ 'jpg', 'png'],
    recursion: true,
  );
}

Future<void> _getCount(BaiduPan baiduPan) async {
  final count = await baiduPan.getCountOfPathByType();

  print(count.entries.map((e) => '${e.key}: ${e.value}').join('\n'));
}

void _getDocList(BaiduPan baiduPan) {
  // baiduPan.getDocList(
  //   recursion: true,
  //   number: 10,
  //   page: 1,
  // );
  // baiduPan.getImageList(recursion: true, number: 10, page: 1);
  // baiduPan.getBtList(recursion: true, number: 10, page: 1);
  baiduPan.getVideoList(recursion: true, number: 10, page: 1);
}

Future<void> _getFileAll(BaiduPan baiduPan) async {
  final firstPage = await baiduPan.getFileListAll(dir: '/', recursion: true);
  print(firstPage);

  final nextPageStartIndex = firstPage.cursor;

  final nextPage = await baiduPan.getFileListAll(
    dir: '/',
    recursion: true,
    start: nextPageStartIndex,
  );

  print(nextPage);
}

Future<void> _getFileListExample(BaiduPan pan) async {
  final fileList = await pan.getFileList();
  final list = fileList.list;
  for (final item in list) {
    if (item.isDir) {
      print(item);
    }
  }
}
