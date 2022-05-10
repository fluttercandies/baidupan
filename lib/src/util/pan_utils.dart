/// 一些百度网盘的方法
class PanUtils {
  static int getBlockSize(int memberLevel) {
    int blockSize;

    switch (memberLevel) {
      case 1:
        blockSize = 16 * 1024 * 1024;
        break;
      case 2:
        blockSize = 32 * 1024 * 1024;
        break;
      default:
        blockSize = 4 * 1024 * 1024;
    }
    return blockSize;
  }
}
