/// 如果接口包含多种类型，则优先按类型排序，再按此字段排序
/// 官方文档说明： https://pan.baidu.com/union/doc/nksg0sat9 参考请求的order字段的说明
///
/// time表示先按文件类型排序，后按修改时间排序
/// name表示先按文件类型排序，后按文件名称排序
/// size表示先按文件类型排序，后按文件大小排序
enum BaiduOrder {
  name,
  time,
  size,
  type,
}

extension OrderMapExt on BaiduOrder {
  String toParam() {
    String value;

    switch (this) {
      case BaiduOrder.name:
        value = 'name';
        break;
      case BaiduOrder.time:
        value = 'time';
        break;
      case BaiduOrder.size:
        value = 'size';
        break;
      case BaiduOrder.type:
        value = '';
    }

    return value;
  }
}
