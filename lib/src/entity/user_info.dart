// 参数名称	类型	描述
// baidu_name	string	百度账号
// netdisk_name	string	网盘账号
// avatar_url	string	头像地址
// vip_type	int	会员类型，0普通用户、1普通会员、2超级会员
// uk	int	用户ID

import 'dart:convert';

class UserInfo {
  final String baiduName;
  final String netdiskName;
  final String avatarUrl;
  final int vipType;
  final int uk;

  const UserInfo({
    required this.baiduName,
    required this.netdiskName,
    required this.avatarUrl,
    required this.vipType,
    required this.uk,
  });

  static UserInfo fromJson(Map<String, dynamic> res) {
    return UserInfo(
      baiduName: res['baidu_name'],
      netdiskName: res['netdisk_name'],
      avatarUrl: res['avatar_url'],
      vipType: res['vip_type'],
      uk: res['uk'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baidu_name': baiduName,
      'netdisk_name': netdiskName,
      'avatar_url': avatarUrl,
      'vip_type': vipType,
      'uk': uk,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
