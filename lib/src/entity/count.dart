/// {"real_server_mtime_2":"1551423842","size":80051673570,"total":5630,"count":5630}
class CategoryCount {
  final String realServerMtime2;
  final int size;
  final int total;
  final int count;

  CategoryCount(this.realServerMtime2, this.size, this.total, this.count);

  factory CategoryCount.fromJson(Map<String, dynamic> json) {
    return CategoryCount(
      json['real_server_mtime_2'],
      json['size'],
      json['total'],
      json['count'],
    );
  }

  @override
  String toString() {
    return 'CategoryCount{realServerMtime2: $realServerMtime2, size: $size, total: $total, count: $count}';
  }
}
