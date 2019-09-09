package com.polyv.rn;

import android.content.Context;

import com.easefun.polyv.businesssdk.vodplayer.PolyvVodSDKClient;
import com.easefun.polyv.cloudclass.config.PolyvLiveSDKClient;
import com.easefun.polyv.foundationsdk.log.PolyvCommonLog;

/**
 * @author df
 * @create 2019/9/6
 * @Describe
 */
public class PolyvInitManager {

    public static void init(String vodKey, String decodeKey, String decodeIv, Context context){
        // Normal app init code...
        PolyvCommonLog.setDebug(true);
        PolyvLiveSDKClient liveSDKClient = PolyvLiveSDKClient.getInstance();
        liveSDKClient.initContext(null);

        PolyvVodSDKClient client = PolyvVodSDKClient.getInstance();
        //使用SDK加密串来配置
        client.setConfig(vodKey, decodeKey, decodeIv);
    }
}
