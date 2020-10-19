
# RN 云课堂集成文档

## 1. 概述

PolyvRNCloudClassDemo 支持 Android + iOS， 是专为 ReactNative 技术开发者定制的云课堂集成 demo，从属于广州易方信息科技股份有限公司旗下的 POLYV 保利威视频云核心产品“云课堂”，包含了视频教学直播、ppt 在线演示同步播放、教学连麦、在线聊天功能，以及直播回放功能。

### 1.1 支持设备

Android 5.0 (API>=21) 以上 或 iOS 9.0 以上

### 1.2 接入条件

- 了解 ReactNative 技术；
- 搭建好运行 React Native 的相关环境；
- 准备在使用 React Native 技术开发的项目中接入云课堂功能；
- 在[保利威视频云平台](http://www.polyv.net/)注册账号，并开通相关服务。

### 1.3 版本功能

RN 版本是基于原生 demo + sdk 开发的，iOS 与 android 对应版本，及 SDK 版本更新日志链接如下：

- iOS SDK 对应版本为 v0.9.0，[版本更新日志](https://github.com/polyv/polyv-ios-cloudClass-sdk-demo/releases)
- android SDK 对应版本为 v0.8.0，[版本更新日志](https://github.com/polyv/polyv-android-cloudClass-sdk-demo/releases)



## 2. 快速开始

### 2.1 RN 端集成

#### 2.1.1 安装依赖

执行如下命令下载 react 相关依赖

```js
$ npm install
```

#### 2.1.2 引入插件

云课堂的插件和 demo 的目录结构如下所示：

├── polyv
│   ├── demo
│   │   ├── img
│   │   │   └── logo_polyv.png
│   │   ├── view
│   │   │   └── LoginInput.js
│   │   ├── PolyvUserConfig.js
│   │   └── PolyvLogin.js
│   └── sdk
│       └── PolyvCloudClassLoginModule.js

如果只是需要使用到 sdk 的功能，把 sdk 目录下的文件拉到 RN 项目中即可。demo 中的功能则需要使用到 demo 目录下的文件。

#### 2.1.3 项目配置

1. 项目中 app.json 中的字段 name 需要与native 层的入口名对应，所以在 Android 与 ios 两端需要做入口名统一配置。配置文件名：

   - Android 端的 MainActivity.java 文件

     ```java
      @Override
         protected String getMainComponentName() {
             return "此处填入 app.json 里的 name 字段内容";
         }
     ```

   - iOS 端的 AppDelegate.m 文件

     ```objective-c
     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
       NSURL *jsCodeLocation;
     
       #ifdef DEBUG
         jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
       #else
         jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
       #endif
     
       RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                       moduleName:@"此处填入app.json里的name字段内容"
                                                    initialProperties:nil
                                                        launchOptions:launchOptions];
       …… // 代码省略
       return YES;
     }
     ```

2. 在 package.json 文件中配置依赖。

```json
"dependencies": {
    "react": "16.6.3",
    "react-native": "0.57.8",
	
	//polyv/demo里需要的依赖（如不需要可删除）
   "react-native-gesture-handler": "1.1.0",
    "react-navigation": "3.3.2",
    "react-native-reanimated": "^1.2.0",
    "axios": "^0.18.0"
  },
  "devDependencies": {
    "@babel/core": "^7.5.5",
    "@babel/runtime": "^7.5.5",
    "@react-native-community/eslint-config": "^0.0.5",
    "babel-jest": "23.6.0",
    "eslint": "^6.2.2",
    "jest": "23.6.0",
    "metro-react-native-babel-preset": "^0.51.1",
    "react-test-renderer": "16.6.3"
  },
```

#### 2.1.4 使用方法

云课堂的插件 PolyvCloudClassLoginModule.js 提供了如下接口：

| 函数名        | 参数                                                         | 功能说明         | 是否有返回值 |
| :------------ | ------------------------------------------------------------ | ---------------- | ------------ |
| init          | vodKey：加密串（必填）<br/>decodeKey：加密密钥（必填）<br/>decodeIv：加密向量（必填）<br/>viewerId：观看者 ID（必填）<br/>nickName：观看者昵称（选填） | SDK 初始化 | 是           |
| liveLogin     | userId：账号 ID（必填）<br/>channelId：频道号（必填）<br/>appId：应用 ID（必填）<br/>appSecret：应用密钥（必填） | 直播登录     | 是           |
| playbackLogin | userId：账号 ID（必填）<br/>channelId：频道号（必填）<br/>vodId：回放视频 ID（必填）<br/>appId：应用 ID（必填）<br/>appSecret：应用密钥（必填） | 回放登录         | 是           |

以上函数的返回值参见 2.1.5。

#### 2.1.5 返回码

| 返回码（整型） | 返回码描述              |
| -------------- | ----------------------- |
| 0              | 成功                    |
| -1             | appId 为空              |
| -2             | appSecret 为空          |
| -3             | viewerId 为空           |
| -4             | userId 为空             |
| -5             | channelId 为空          |
| -6             | vodId 为空              |
| -7             | 加密串 vodKey 为空      |
| -8             | 加密密钥 decodeKey 为空 |
| -9             | 加密向量  decodeIv 为空 |
| -10            | 登录失败                |



### 2.2 Android 端集成
#### 2.2.1 端工程说明
Android 端工程的原生插件代码分为两个部分：

- 定制的 rn 模块，就是工程的主模块app，路径是PolyvRNCloudclassDemo/android/app。
- polyv sdk 模块，主要是 polyv 相关组件的代码文件，路径是PolyvVodRnDemo/android/polyvsdk。
- - commui 模块，polyvsdky依赖的公共模块，不用添加相关配置，会自动依赖

主模块app涉及的 java 文件有：
- PolyvCloudClassRNPackage：rn 插件开发的管理类，用来注册相关的 rn 定制组件。
- PolyvCloudClassRNModule：初始化及登录组件模块，用来初始化 android 端需要的一些全局用户信息，例如 iv，secreate，userid。提供直播与回放登录接口

#### 2.2.2  集成步骤
1、相关依赖配置
用户集成工程需要进行模块项目依赖：setting.gradle
```java
rootProject.name = 'PolyvRNCloudClassDemo'

include ':app'，':commonui', ':polyvsdk'

## 如果有集成导航栏相关控件
include ':react-native-gesture-handler'
project(':react-native-gesture-handler').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-gesture-handler/android')
include ':react-native-reanimated'
project(':react-native-reanimated').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-reanimated/android')
```

主工程下依赖配置：build.gradle
```java
allprojects {
    repositories {
        mavenLocal()
        maven {
            // All of React Native (JS, Obj-C sources, Android binaries) is installed from npm
            url("$rootDir/../node_modules/react-native/android")
        }
        maven {
            // Android JSC is installed from npm
            url("$rootDir/../node_modules/jsc-android/dist")
        }

        google()
        jcenter()
        maven { url "https://jitpack.io" }
        maven {
            url 'http://maven.aliyun.com/nexus/content/repositories/releases/'
        }
        
        //polyv依赖配置
        maven { url 'https://dl.bintray.com/polyv/android' }
    }
}

//相关系统依赖版本
ext {
    supportLibVersion = "27.1.1"
    compileSdkVersion = 29
    minSdkVersion = 21
    targetSdkVersion = 29
    versionCode = 152
    versionName = "0.15.2"
}

```

app工程的相关依赖配置：build.gradle

```java
dependencies {
api project(path: ':polyvsdk')

#如果集成导航栏相关配置
api project(':react-native-gesture-handler')
api project(':react-native-reanimated')

}

//由于用到java8相关特性
compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
```
2、原生代码集成
   1. 在目标工程中的 android/app/src/main/java 目录下，增加 com 目录，形成 android/app/src/main/java/com 的目录结构（如果已有com目录，可跳过本步骤）；

   2. 把 android/app/src/main/java/com/polyv文件夹 拷贝到 上面创建的 com目录 下；

   3. 配置目标项目的 Application文件；

      ```java
              @Override
              protected List<ReactPackage> getPackages() {
                  return Arrays.<ReactPackage>asList(
                          new MainReactPackage()
                          , new PolyvCloudClassRNPackage()，  // 新增加的一行！
                          
                          //如果添加导航栏组件 添加下面
                          new RNGestureHandlerPackage(),
                          new ReanimatedPackage(),
                  );
              }
      
        			@Override
              public void onCreate() {
          			super.onCreate();
                PolyvLiveSDKClient.getInstance().initContext(this); // 新增加的一行！
                SoLoader.init(this, /* native exopackage */ false);
              }
      
      ```

   4.MainActivity配置
   ```java
      //如果添加导航栏控件需要重写以下方法
       @Override
    protected ReactActivityDelegate createReactActivityDelegate() {
        return new ReactActivityDelegate(this, getMainComponentName()) {
            @Override
            protected ReactRootView createRootView() {
                return new RNGestureHandlerEnabledRootView(MainActivity.this);
            }
        };
       }
   ```

### 2.3 iOS 端集成

iOS 端工程的原生插件代码全部包含在  ios/PolyvCloudClassModule 文件夹中。

#### 2.3.1 引入原生代码

1. 把 demo 项目的 ios/PolyvCloudClassModule 文件夹拷贝到目标项目的 ios 目录下（如果以前已经拷贝过上述文件夹，需要在 Xcode 先删除，然后再拷贝）；
2. 在 Xcode 中，把上述文件夹增加（Add Files）到项目中。

#### 2.3.2 配置 CocoaPods

1. 如果目标项目原来没有  ios/Podfile 文件，需要拷贝 demo 项目的 ios/Podfile 文件到目标项目的 ios 目录下；打开 Podfile 文件，把其中 ‘PolyvRNCloudClassDemo’ 改为 ‘自身项目名’；

2. 如果目标项目原来有 Podfile 文件，只需要把以下代码拷贝到  ios/Podfile 文件 中；

```
platform :ios, '9.0'

target '你的项目名' do
  use_frameworks!
  
  pod 'Masonry', '~> 1.1.0'
  pod 'SDWebImage', '4.4.0'
  pod 'PolyvCloudClassSDK', '0.9.0'
  
  # 执行 npm install 命令之后，有可能会自动生成下面这两行配置，需要把这两行配置删掉或者注释掉
  # pod 'RNReanimated', :path => '../node_modules/react-native-reanimated'
  # pod 'RNGestureHandler', :path => '../node_modules/react-native-gesture-handler'

end
```

注意：

- 不能遗漏 use_frameworks!
- PolyvCloudClassSDK 要带上版本号，避免自动升级；

3. 在命令行环境进入 ios 目录，执行 `pod install` 命令。

#### 2.3.3 项目配置

由于云课堂项目中的播放器，在播放过程中进行截图后会直接保存到系统相册，需要有访问系统相册的权限；直播间的聊天室，允许用户上传相册里的照片或拍照上传，也需要访问系统相册以及访问摄像头的权限；直播时的连麦功能需要访问麦克风以及摄像头的权限。想要正常使用以上功能，需要在文件 Info.plist 中添加这一系列权限。

另外，本项目支持后台播放，因此还需要开启后台播放权限。info.plist 文件新增内容如下：

```
`<?xml version=``"1.0"` `encoding=``"UTF-8"``?>``<!DOCTYPE plist PUBLIC ``"-//Apple//DTD PLIST 1.0//EN"` `"http://www.apple.com/DTDs/PropertyList-1.0.dtd"``>``<plist version=``"1.0"``>``<dict>``    ``……``    ``<key>NSPhotoLibraryUsageDescription</key>``    ``<string>允许App访问相册以保存截图或读取相册视频文件</string>``    ``<key>UIBackgroundModes</key>``    ``<array>``        ``<string>audio</string>``    ``</array>``    ``……``</dict>``</plist>`
```



#### 2.3.4 Xcode 10 升级到 Xcode 11 项目运行报错问题解决

Xcode 更新到 v11之后，运行之前 v10 的项目，提示如下错误：

```
Unknown argument type '__attribute__' in method -[RCTAppState getCurrentAppState:error:]. Extend RCTConvert to support this type
```

解决方案：

Xcode 打开项目，找到 Library 路径下的 React 项目，找到位于路径 React/Base 下的文件 RCTModuleMethod.mm 文件，找到如下方法 'RCTParseUnused'，添加 return 语句中的第二行：

```
static BOOL RCTParseUnused(const char **input)
{
  return RCTReadString(input, "__unused") ||
         RCTReadString(input, "__attribute__((__unused__))") ||
         RCTReadString(input, "__attribute__((unused))");
}
```
