# BaiduPan

百度网盘的 API, 可以帮助对接 Baidu 网盘

有一些未对接的接口可以查看 [官方文档](https://pan.baidu.com/union/doc/nksg0sbfs)

## API 的配置

到 [百度开放平台的应用列表](https://pan.baidu.com/union/console/applist) 中获取

这里主要需要的的是 AppKey 和 AppSecret

## 授权码

> 写在前面：这里要注意一点，非常重要，请仔细阅读后再继续！！！！

> 写在前面：这里要注意一点，非常重要，请仔细阅读后再继续！！！！

> 写在前面：这里要注意一点，非常重要，请仔细阅读后再继续！！！！

**不要**把 code 或 access_token 暴露给**任何人**，因为有了这个东西，别人就能**访问**你的百度网盘了，甚至可以**删除你所有数据**

### 授权码的概念

这里有一个 `code` 和 `access_token` 的概念, `code` 为登录用户给予的授权码, 需要使用 `code` 换取 `access_token`

code 10 分钟过期, 暂时是手动填入, 当然你可以自己寻求自动化的进程, 或者如果你有服务器端, 也可以使用服务端授权模式，这和本 SDK 无关

获取到 accessToken 后保存下来，下次需要时直接使用即可， 这个 accessToken 的有效期为 30 天，可以使用 `refresh_token` 刷新， 但是我这里没做刷新的相关逻辑，有需要的时候请重新获取
accessToken

### 使用代码简化步骤

`BaiduAuthManager` 可以简化这个过程

```dart

void main() async {
  final authManager = BaiduAuthManager(appId, appSecret);
  final uri = authManager.getAuthUrl();
  print(uri); // 这里使用浏览器访问这个 url ，然后复制 code,

  final auth = await authManager.requestAccessToken(code);
  print(auth.accessToken); // 这里就是 accessToken， 其他字段的含义请参考官方文档
}
```

## 使用说明

因为百度网盘的 API 有一些坑，这里进行了一些封装，然后使用 3 个核心类来对应不同的功能具体功能参照类说明文档

入口类有 3 个，分别对应查询，操作，上传

- `BaiduPan`: 对应百度网盘的核心 API，主要是获取信息
  - `getUserInfo`: 获取用户信息
  - `getDiskSpace`: 获取网盘空间信息
  - `getFileList`: 获取文件列表
  - `getFileListAll`: 递归获取文件列表
  - `getDocList`: 获取文档列表
  - `getImageList`: 获取图片列表
  - `getVideoList`: 获取视频列表
  - `getBtList`: 获取 BT 列表
  - `getCountOfPathByType`: 获取某个目录下的文件类型数量
  - `getCategoryList`: 获取网盘分类列表
  - `search`: 搜索
  - `getMetaData`: 获取文件元数据
  - `getDownloadRequest`: 获取下载请求
  - `getDownloadUrl`: 获取下载地址
- `BaiduPanFileManager`: 操作文件的管理类
  - `copy`: 复制文件
  - `move`: 移动文件
  - `rename`: 重命名文件
  - `delete`: 删除文件
- `BaiduPanUploadManager`: 上传文件的管理类
  - `preCreate`: 预创建文件
  - `uploadSinglePart`: 上传分片文件
  - `merge`: 合并分片（上传完成）

## 上传文件的断点续传问题

如果文件过大或网络不稳定，可能会中断，这里封装了一个类可以帮助解决这个问题

`BaiduUploadHelper`

### 运行在内存中

这种情况适用于程序未关闭的情况下，比如 app 或服务器端程序

只需要重新调用同一个对象的`startUpload`即可

原理是对象内保存了下载的 md5 列表和 uploadId, 这样可以自动续传

### 运行在命令行中

因为每次可能都要开启一个新的程序来上传，这时需要将断点信息保存至文件内，在下次加载时传入对象内

使用 `saveProgressToFile` 来保存进度信息到 file

使用 `BaiduUploadHelper.resumeFromFile` 来从文件恢复

## 命令行工具

项目提供了一个简单的上传工具，需要配合 [pub global][] 使用

使用前需要配置文件或环境变量以访问 access_token，

### 安装

```zsh
dart pub global activate baidupan
```

### 使用配置文件

配置文件的方式：生成一个 `config.json` 文件，`$HOME/.config/baidupan/config.json`，这个文件的格式如下

```json
{
  "expires_in": 2592000,
  "refresh_token": "",
  "access_token": "",
  "session_secret": "",
  "session_key": "",
  "scope": "basic netdisk"
}
```

这个文件可以使用 `requset_baidu_auth` 工具生成

```sh
export baidu_app_id=xxx
export baidu_app_secret=xxx

# 如果你已经获取了 code，请设置环境变量
export baidu_request_code=xxx

dart run bin/request_baidu_auth.dart

or

request_baidu_auth
```

### 环境变量

还可以通过环境变量设置 access_token

```sh
export BAIDU_PAN_ACCESS_TOKEN=xxx
```

### 上传文件

```shell

# 上传
bd_upload <local_path> <remote_path>
```

## LICENSE

Apache 2.0

[pub global]: https://dart.cn/tools/pub/cmd/pub-global
