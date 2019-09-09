package com.polyv.rn;

/**
 * @author df
 * @create 2019/1/26
 * @Describe
 */
public class PolyvErrorCode {
    /**
     * code，返回码定义：
     *      0  成功
     *      -1 AppId为空
     *      -2 AppSecret为空
     *      -3 viewerId为空
     *      -4 UserId为空
     *      -5 ChannelId为空
     *      -6 频道加载失败
     */
    public final static int success = 0;
    public final static int noAppId = -1;
    public final static int noAppScrect = -2;
    public final static int noViewId = -3;
    public final static int noUserId = -4;
    public final static int noChannelId = -5;
    public final static int noVideoId = -6;
    public final static int noVodKey = -7;
    public final static int noDecodeKey = -8;
    public final static int noDecodeIv = -9;
    public final static int channleLoadFailed = -10;

    public static String getDesc(int code) {
        switch (code) {
            case PolyvErrorCode.success:
                return "成功";
            case PolyvErrorCode.noAppId:
                return "AppId为空";
            case PolyvErrorCode.noAppScrect:
                return "AppSecret为空";
            case PolyvErrorCode.noViewId:
                return "viewerId为空";
            case PolyvErrorCode.noUserId:
                return "UserId为空";
            case PolyvErrorCode.noChannelId:
                return "ChannelId为空";
            case PolyvErrorCode.noVideoId:
                return "videoId为空";
            case PolyvErrorCode.channleLoadFailed:
                return "频道加载失败";
            case PolyvErrorCode.noVodKey:
                return "VodKey为空";
            case PolyvErrorCode.noDecodeKey:
                return "DecodeKey为空";
            case PolyvErrorCode.noDecodeIv:
                return "DecodeIv为空";
            default:
                return "";
        }
    }
}
