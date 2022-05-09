# CHANGELOG

## 1.0.5

- 为上传的分块数据 [UploadPart] 添加了 `blockSize`, 用于表示分块大小。

- 为 [BaiduUploadHelper] 添加了几个参数

  - fileTotalSize: 文件总大小
  - uploadSpeed: 上传速度
  - getProgress: 上传进度

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
