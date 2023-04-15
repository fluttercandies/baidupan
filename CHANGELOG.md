# CHANGELOG

## 1.1.5

- 修复了一处未关闭的 `RandomAccessFile` 的内存泄露问题. [#5](https://github.com/fluttercandies/baidupan/pull/5)

## 1.1.4

获取大文件的 md5 进行优化，可以分块获取，不会一次性读取大文件，导致内存溢出。

## 1.1.3

- 支持获取音视频文件的流信息

## 1.1.2

- 上传文件失败自动重试，默认 10 次

## 1.1.1

- 优化一处上传文件时的内存占用问题

## 1.1.0

- 为上传的分块数据 [UploadPart] 添加了 `blockSize`, 用于表示分块大小。

- 为 [BaiduUploadHelper] 添加了几个参数

  - fileTotalSize: 文件总大小
  - uploadSpeed: 上传速度
  - getProgress: 上传进度

- 支持秒传

## 1.0.4

- 修复了一处 `BaiduUploadHelper` 恢复进度的 bug

## 1.0.3

- 修复 bug： `BaiduUploadHelper`
- 为 `BaiduUploadHelper` 添加 `uploadCount` 来标识本地上传的数量

## 1.0.2

- 为 `BaiduUploadHelper` 添加了一个 `totalBlockCount` 用来标识文件块的数量

## 1.0.1

- 清理了代码

## 1.0.0

- 第一个版本, 接入了大部分代码
