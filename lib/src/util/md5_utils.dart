import 'dart:io';

import 'package:baidupan/src/util/pan_utils.dart';
import 'package:crypto/crypto.dart';

class Md5Utils {
  const Md5Utils._();

  static String getFileMd5(String filePath, [int blockSize = 1024 * 1024]) {
    final file = File(filePath);
    return md5.convert(file.readAsBytesSync()).toString();

    // final accessFile = file.openSync(mode: FileMode.read);
    //
    // file.readAsBytesSync();
    //
    // Digest? digest;
    //
    // // 循环分块读取accessFile
    // do {
    //   final block = accessFile.readSync(blockSize);
    //   // final u32List = block.buffer.asUint32List();
    //   // final u32List = block.buffer.asUint16List();
    //   if (block.isEmpty) {
    //     break;
    //   }
    //   print('block length: ${block.length}');
    //   digest = _convert(block);
    // } while (true);
    //
    // accessFile.closeSync();
    //
    // return digest.toString();
  }

  static List<String> getBlockList(
    String filePath, [
    int blockSize = 4 * 1024 * 1024,
  ]) {
    final file = File(filePath);
    final accessFile = file.openSync(mode: FileMode.read);
    final result = <String>[];

    while (true) {
      final block = accessFile.readSync(blockSize);
      if (block.isEmpty) {
        break;
      }
      result.add(md5.convert(block).toString());
    }

    return result;
  }

  // ignore: unused_element
  static Digest _convert(List<int> data) {
    var innerSink = _DigestSink();
    var outerSink = md5.startChunkedConversion(innerSink);
    outerSink.add(data);
    outerSink.close();
    return innerSink.value;
  }

  static String getFileSliceMd5(String localPath, int sliceLength) {
    final file = File(localPath);
    final accessFile = file.openSync(mode: FileMode.read);
    final buffer = accessFile.readSync(sliceLength);
    final result = md5.convert(buffer).toString();
    accessFile.closeSync();
    return result;
  }
}

class BaiduMd5 {
  final String filePath;
  final int memberLevel;

  BaiduMd5({
    required this.filePath,
    required this.memberLevel,
  });

  String? _contentMd5;

  String get contentMd5 {
    _contentMd5 ??= Md5Utils.getFileMd5(filePath);
    return _contentMd5!;
  }

  String? _sliceMd5;

  String get sliceMd5 {
    _sliceMd5 ??= Md5Utils.getFileSliceMd5(filePath, 256 * 1024);
    return _sliceMd5!;
  }

  List<String>? _blockMd5List;

  List<String> get blockMd5List {
    if (_blockMd5List != null) {
      return _blockMd5List!;
    }

    final blockSize = PanUtils.getBlockSize(memberLevel);
    _blockMd5List ??= Md5Utils.getBlockList(
      filePath,
      blockSize,
    );

    return _blockMd5List!;
  }

  Map<String, dynamic> toMap() {
    return {
      'filePath': filePath,
      'memberLevel': memberLevel,
      'blockMd5List': blockMd5List,
      'contentMd5': contentMd5,
      'sliceMd5': sliceMd5,
    };
  }

  factory BaiduMd5.fromMap(Map<String, dynamic> map) {
    final instance = BaiduMd5(
      filePath: map['filePath'],
      memberLevel: map['memberLevel'],
    );
    instance._blockMd5List =
        (map['blockMd5List'] as List).whereType<String>().toList();
    instance._contentMd5 = map['contentMd5'];
    instance._sliceMd5 = map['sliceMd5'];
    return instance;
  }
}

class _DigestSink extends Sink<Digest> {
  /// The value added to the sink.
  ///
  /// A value must have been added using [add] before reading the `value`.
  Digest get value => _value!;

  Digest? _value;

  /// Adds [value] to the sink.
  ///
  /// Unlike most sinks, this may only be called once.
  @override
  void add(Digest value) {
    if (_value != null) throw StateError('add may only be called once.');
    _value = value;
  }

  @override
  void close() {
    if (_value == null) throw StateError('add must be called once.');
  }
}
