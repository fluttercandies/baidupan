/// |type|User-Agent|分片格式|输出视频分辨率|备注|
/// |-----|-----|-----|-----|-----|
/// |M3U8_AUTO_480|xpanvideo;$appName;$appVersion;$sysName;$sysVersion;ts|视频ts|480p|通用hls协议|
/// |M3U8_AUTO_720|xpanvideo;$appName;$appVersion;$sysName;$sysVersion;ts|视频ts|720p|通用hls协议|
/// |M3U8_AUTO_1080|xpanvideo;$appName;$appVersion;$sysName;$sysVersion;ts|视频ts|1080p|通用hls协议，输出分辨率会根据原视频分辨率自动调整到最大|
/// |M3U8_FLV_264_480|xpanvideo;$appName;$appVersion;$sysName;$sysVersion;flv|视频flv|480p|私有协议，需播放器额外特殊支持，或使用网盘播放器|
/// |M3U8_MP3_128|xpanaudio;$appName;$appVersion;$sysName;$sysVersion;mp3|音频mp3|  | 私有协议，需播放器额外支持，或使用网盘播放器|
/// |M3U8_HLS_MP3_128|xpanaudio;$appName;$appVersion;$sysName;$sysVersion;ts|音频ts| | 通用hls协议|
enum MediaRequestType {
  /// M3U8_AUTO_480
  M3U8_AUTO_480,

  /// M3U8_AUTO_720
  M3U8_AUTO_720,

  /// M3U8_AUTO_1080
  M3U8_AUTO_1080,

  /// M3U8_FLV_264_480
  M3U8_FLV_264_480,

  /// M3U8_MP3_128
  M3U8_MP3_128,

  /// M3U8_HLS_MP3_128
  M3U8_HLS_MP3_128,
}

extension MediaRequestTypeExtension on MediaRequestType {
  String get value {
    switch (this) {
      case MediaRequestType.M3U8_AUTO_480:
        return 'M3U8_AUTO_480';
      case MediaRequestType.M3U8_AUTO_720:
        return 'M3U8_AUTO_720';
      case MediaRequestType.M3U8_AUTO_1080:
        return 'M3U8_AUTO_1080';
      case MediaRequestType.M3U8_FLV_264_480:
        return 'M3U8_FLV_264_480';
      case MediaRequestType.M3U8_MP3_128:
        return 'M3U8_MP3_128';
      case MediaRequestType.M3U8_HLS_MP3_128:
        return 'M3U8_HLS_MP3_128';
      default:
        return '';
    }
  }
}
