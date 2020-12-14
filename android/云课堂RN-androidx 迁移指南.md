# 云课堂RN-androidx 迁移指南

由于RN 0.60+ 开始支持Androidx，部分开发者已经在项目中使用了Androidx，而云课堂RN的中安卓原生使用的是support库，所以在集成的时候会遇到冲突问题。如

```groovy
1、utdid无法下载
...
> Could not find com.aliyun.ams:alicloud-android-utdid:1.1.5.4.
...
  
2、包文件不存在
//....省略
错误: 程序包android.support.annotation不存在
import android.support.annotation.NonNull;
                                 ^
100 个错误

FAILURE: Build failed with an exception.
```

开发者需要对云课堂RN进行Androidx的项目迁移，迁移之后才能正常集成使用。

## 1. utdid 库无法下载

```java
* What went wrong:
Could not determine the dependencies of task ':app:compileDebugJavaWithJavac'.
> Could not resolve all task dependencies for configuration ':app:debugCompileClasspath'.
   > Could not find com.aliyun.ams:alicloud-android-utdid:1.1.5.4.
     Required by:
         project :app > com.aliyun.ams:alicloud-android-beacon:1.0.4.3
   > Could not find com.aliyun.ams:alicloud-android-utdid:1.1.5.4.
     Required by:
         project :app > com.aliyun.ams:alicloud-android-ut:5.4.3
```

这是由于Gradle的兼容问题，会导致库拉不下来，只需要在commonui/build.gradle下添加

```groovy
dependencies {
    //...
    api 'com.aliyun.ams:alicloud-android-utdid:1.5.2'
}

```

## 2. 迁移项目到Androidx

开发者运行项目，可能会出现以下xxx不存在的报错，这需要对项目进行Androidx的转换才能正常使用。

**注意：请将Demo转换为Androidx成功后，再集成Android部分到开发者项目。转换前请做好备份工作！！！**

```groovy
//....省略
错误: 程序包android.support.annotation不存在
import android.support.annotation.NonNull;
                                 ^
100 个错误

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':commonui:compileDebugJavaWithJavac'.
> Compilation failed; see the compiler error output for details.
```



### 2.1 开启AndroidStudio 自动转化

修改`android/build.gradle` 下的版本，升级到28。AndroidStudio 的 Androidx 迁移功能需要28以上才能进行。

```
ext {
    compileSdkVersion = 28
    minSdkVersion = 16
    targetSdkVersion = 28
		//...
}
```

开启 AndroidStudio，依次打开 Refactor-Migrate to Androidx，AndroidStudio 会自动帮你转化为 Androidx 的工程。扫描之后会弹出 Refactoring Preview，点击 Do Refactor 就会开始自动转化。

### 2.2 修改依赖

按照以上步骤完成，点击一下AndroidStudio的小锤子，(或者点击 build -> make Project)，会发现还会有编译报错如下

```groovy
1、
程序包android.support.annotation不存在
2、
错误: 找不到符号
符号:   类 CheckResult
位置: 类 GlideOptions
```

这是因为原有的注解在Androidx中不再支持了，且云课堂 SDK 中引用的 Glide 4.7.1 不支持 Androidx的注解，所以我们要修改部分依赖。修改完成后编译运行即可。

```groovy
dependencies {
		//...

    /////------改动-start--------
    //1、排除polyvSDKCloudClass的Glide依赖，以下版本不要直接复制，原来是多少就是多少
    api ('com.easefun.polyv:polyvSDKCloudClass:0.15.2'){
        exclude group:'com.github.bumptech.glide',module:'glide'
        exclude group:'com.github.bumptech.glide',module:'gifdecoder'
    }
    //2、添加Glide依赖4.10.0
    api 'com.github.bumptech.glide:glide:4.10.0'
    annotationProcessor 'com.github.bumptech.glide:compiler:4.10.0'
    //3、注释原来的注解
    //annotationProcessor 'com.github.bumptech.glide:compiler:4.7.1'
  
  	//如果出现Could not find com.aliyun.ams:alicloud-android-utdid:1.1.5.4.请添加下面依赖
  	api 'com.aliyun.ams:alicloud-android-utdid:1.5.2'

		//...
}

```



### 2.3 全局替换错误的类库路径

一般情况下以上两步已经可以将demo转为Androidx的工程，正常运行到手机上了。但是由于 AndroidStudio 版本，项目环境等差异，导致可能转化过程中出现转化的路径不是最新的异常。以下为收集到的高频次异常。开发者可以全局替换。

转化后点击以下小锤子，然后会报错提示找不到符号，大多是以 `import androidx.xxx` 开头的，需要全局替换。

**注意只需要修改`import `开头的，类库正常引入后其他代码就能运行了。**如下所示，根据报错信息在下方替换表中找到对应的路径，把`import androidx.appcompat.widget.GridLayoutManager;` 全局替换成`import androidx.recyclerview.widget.GridLayoutManager;`

```java
import androidx.appcompat.widget.GridLayoutManager;
                                ^
  符号:   类 GridLayoutManager
  位置: 程序包 androidx.appcompat.widget
```

以下列出常用的替换表：

| 修改前android.support                                        | 修改后androidx                                               |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| import androidx.appcompat.widget.RecyclerView;               | import androidx.recyclerview.widget.RecyclerView;            |
| import androidx.core.view.ViewPager;                         | import androidx.viewpager.widget.ViewPager;                  |
| import androidx.core.view.PagerAdapter;                      | import androidx.viewpager.widget.PagerAdapter;               |
| import androidx.core.app.Fragment;                           | import androidx.fragment.app.Fragment;                       |
| import androidx.core.app.FragmentManager;                    | import androidx.fragment.app.FragmentManager;                |
| import androidx.core.app.FragmentTransaction;                | import androidx.fragment.app.FragmentTransaction;            |
| import androidx.core.content.LocalBroadcastManager;          | import androidx.localbroadcastmanager.content.LocalBroadcastManager; |
| import androidx.appcompat.widget.DefaultItemAnimator;        | import androidx.recyclerview.widget.DefaultItemAnimator;     |
| import androidx.appcompat.widget.LinearLayoutManager;        | import androidx.recyclerview.widget.LinearLayoutManager;     |
| import androidx.appcompat.widget.GridLayoutManager;          | import androidx.recyclerview.widget.GridLayoutManager;       |
| import androidx.appcompat.widget.StaggeredGridLayoutManager; | import androidx.recyclerview.widget.StaggeredGridLayoutManager; |
| import android.support.design.widget.CoordinatorLayout;      | import androidx.coordinatorlayout.widget.CoordinatorLayout;  |
| import android.support.design.widget.CoordinatorLayout;      | import androidx.coordinatorlayout.widget.CoordinatorLayout;  |
| import android.support.design.widget.TabLayout;              | import com.google.android.material.tabs.TabLayout;           |
| import android.support.design.widget.AppBarLayout;           | import com.google.android.material.appbar.AppBarLayout       |
| import androidx.appcompat.widget.SimpleItemAnimator;         | import androidx.recyclerview.widget.SimpleItemAnimator;      |
| import android.support.design.widget.FloatingActionButton;   | import com.google.android.material.floatingactionbutton.FloatingActionButton; |
| import androidx.core.app.FragmentPagerAdapter;               | import androidx.fragment.app.FragmentPagerAdapter;           |
| import androidx.core.app.FragmentStatePagerAdapter;          | import androidx.fragment.app.FragmentStatePagerAdapter;      |
| import androidx.core.widget.SwipeRefreshLayout;              | import androidx.swiperefreshlayout.widget.SwipeRefreshLayout; |



此外， xml文件中也可能会出现这种问题，但是这种难以察觉，一般在运行时才会报错，可以参考上表做控件的替换，不要import即可。

在这里总结了笔者遇到的

| 文件                                                         | 修改前                                  | 修改后                                                |
| ------------------------------------------------------------ | --------------------------------------- | ----------------------------------------------------- |
| polyv_chat_layout.xml                                        | androidx.core.view.ViewPager            | androidx.viewpager.widget.ViewPager                   |
| polyv_cloudclass_controller_more.xml<br />polyv_chat_emo_list_layout.xml | androidx.appcompat.widget.RecyclerView  | androidx.recyclerview.widget.RecyclerView             |
| polyv_fragment_groupchat.xml                                 | androidx.core.widget.SwipeRefreshLayout | androidx.swiperefreshlayout.widget.SwipeRefreshLayout |



##  3. 可能出现的问题

### 3.1 Android 5.x 进入直播间崩溃，其他版本正常

该情况往往是由于Androidx库："androidx.appcompat:appcompat:1.1.0" 的 bug，在部分 5.0 的手机中会提示以下错误，需要将该库升级为 1.2.0-alpha02 版本。

```
android.view.InflateException: Binary XML file line #7: Error inflating class android.webkit.WebView
  ...
  Caused by: android.content.res.Resources$NotFoundException: String resource ID #0x2040003
```



### 3.2 方法数超限

如果编译没通过，如下提示，就是方法数超限了。

```groovy
Cannot fit requested classes in a single dex file (# methods: 88028 > 65536 ; # fields: 79345 > 65536)
```

需要在`android/build.gradle` 下添加 `multiDexEnabled true`

```groovy
android {
		//省略

    defaultConfig {
        applicationId "your package name"
        minSdkVersion rootProject.ext.minSdkVersion
        targetSdkVersion rootProject.ext.targetSdkVersion
        versionCode 1
        versionName "1.0"

        multiDexEnabled true//新增
    }
```



### 3.3 react-native-gesture-handler 升级

如果用到 react-native-gesture-handler，需要升级到1.4.0+才支持RN 0.60+
