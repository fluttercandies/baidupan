// total	int	总空间大小，单位B
// expire	bool	7天内是否有容量到期
// used	int	已使用大小，单位B
// free	int	剩余大小，单位B

class DiskSpace {
  final int total;
  final bool expire;
  final int used;
  final int free;

  DiskSpace({
    required this.total,
    required this.expire,
    required this.used,
    required this.free,
  });

  static DiskSpace fromJson(Map<String, dynamic> json) {
    return DiskSpace(
      total: json['total'],
      expire: json['expire'],
      used: json['used'],
      free: json['free'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'expire': expire,
      'used': used,
      'free': free,
    };
  }

  @override
  String toString() {
    return 'DiskSpace{total: $total, expire: $expire, used: $used, free: $free}';
  }
}
