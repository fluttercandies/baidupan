// null safety: file

// {"errmsg":"succ","errno":0,"list":[{"category":1,"dlink":"https://d.pcs.baidu.com/file/3d0b9004fn15a13dd35763a5b44402e3?fid=2469771319-250528-698915277947\u0026rt=pr\u0026sign=FDtAER-DCb740ccc5511e5e8fedcff06b081203-D85Ege6AitWUSV8FINsoGCHTpc4%3D\u0026expires=8h\u0026chkbd=0\u0026chkv=0\u0026dp-logid=3137172297211784431\u0026dp-callid=0\u0026dstime=1646206432\u0026r=496379932\u0026origin_appid=24258181\u0026file_type=0","filename":"2021年2月24日 师徒聊行情.mkv","fs_id":698915277947,"isdir":0,"md5":"3d0b9004fn15a13dd35763a5b44402e3","oper_id":2469771319,"path":"/炒股专用/无为/常规直播/2021-02-24/2021年2月24日 师徒聊行情.mkv","server_ctime":1614220286,"server_mtime":1615352492,"size":246073844},{"category":1,"dlink":"https://d.pcs.baidu.com/file/f6b72d970r996fe58054db51a9083d84?fid=2469771319-250528-9229646240769\u0026rt=pr\u0026sign=FDtAER-DCb740ccc5511e5e8fedcff06b081203-p%2Bd%2BnN1LhBob81waZKeWo7s%2B6WY%3D\u0026expires=8h\u0026chkbd=0\u0026chkv=0\u0026dp-logid=3137172403455848731\u0026dp-callid=0\u0026dstime=1646206432\u0026r=496379932\u0026origin_appid=24258181\u0026file_type=0","filename":"11_38_2021年11月16日 师徒聊行情.mkv","fs_id":9229646240769,"isdir":0,"md5":"f6b72d970r996fe58054db51a9083d84","oper_id":2469771319,"path":"/炒股专用/无为/常规直播/2021-11-16/11_38_2021年11月16日 师徒聊行情.mkv","server_ctime":1639137026,"server_mtime":1639137026,"size":165679908},{"category":2,"dlink":"https://d.pcs.baidu.com/file/273215186if2e610fbc71cc5986b59cc?fid=2469771319-250528-10752937954086\u0026rt=pr\u0026sign=FDtAERV-DCb740ccc5511e5e8fedcff06b081203-UcfeNmcPguWUZ3TCGR062cgioXc%3D\u0026expires=8h\u0026chkbd=0\u0026chkv=2\u0026dp-logid=3137172483673899816\u0026dp-callid=0\u0026dstime=1646206432\u0026r=496379932\u0026origin_appid=24258181\u0026file_type=0","filename":"师徒聊行情.mp3","fs_id":10752937954086,"isdir":0,"md5":"273215186if2e610fbc71cc5986b59cc","oper_id":2469771319,"path":"/炒股专用/无为/常规直播/2021-08-27/师徒聊行情.mp3","server_ctime":1632311375,"server_mtime":1632311375,"size":16009028}],"names":{},"request_id":"253688891899705528"}
import 'package:baidupan/baidupan.dart';

class BaiduFileMetaList {
  final String errmsg;
  final int errno;
  final List<BaiduFileMetaItem> list;
  final String requestId;

  BaiduFileMetaList({
    required this.errmsg,
    required this.errno,
    required this.list,
    required this.requestId,
  });

  factory BaiduFileMetaList.fromJson(Map<String, dynamic> json) =>
      BaiduFileMetaList(
        errmsg: json["errmsg"],
        errno: json["errno"],
        list: List<BaiduFileMetaItem>.from(
            json["list"].map((x) => BaiduFileMetaItem.fromJson(x))),
        requestId: json["request_id"],
      );
}

class BaiduFileMetaItem with ICategoryItem {
  @override
  final int category;
  final String dlink;
  final String filename;
  final int fsId;
  final int isdir;
  final String md5;
  final int operId;
  final String path;
  final int serverCtime;
  final int serverMtime;
  final int size;

  const BaiduFileMetaItem({
    required this.category,
    required this.dlink,
    required this.filename,
    required this.fsId,
    required this.isdir,
    required this.md5,
    required this.operId,
    required this.path,
    required this.serverCtime,
    required this.serverMtime,
    required this.size,
  });

  factory BaiduFileMetaItem.fromJson(json) {
    return BaiduFileMetaItem(
      category: json['category'],
      dlink: json['dlink'],
      filename: json['filename'],
      fsId: json['fs_id'],
      isdir: json['isdir'],
      path: json['path'],
      md5: json['md5'],
      operId: json['oper_id'],
      size: json['size'],
      serverCtime: json['server_ctime'],
      serverMtime: json['server_mtime'],
    );
  }
}
