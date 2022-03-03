// 1 视频、2 音频、3 图片、4 文档、5 应用、6 其他、7 种子

enum BaiduCategory {
  video,
  audio,
  image,
  document,
  application,
  other,
  torrent,
}

extension FileCategoryExt on BaiduCategory {
  int get value => index + 1;
}
