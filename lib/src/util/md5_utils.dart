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

  int _getBlockSize(int memberLevel) => PanUtils.getBlockSize(memberLevel);

  List<String> get blockMd5List {
    final blockSize = _getBlockSize(memberLevel);
    return Md5Utils.getBlockList(
      filePath,
      blockSize,
    );
  }

  String get contentMd5 => Md5Utils.getFileMd5(filePath);

  String get sliceMd5 => Md5Utils.getFileSliceMd5(filePath, 256 * 1024);
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
