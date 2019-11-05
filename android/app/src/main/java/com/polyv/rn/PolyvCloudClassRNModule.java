package com.polyv.rn;

import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.text.TextUtils;
import android.util.Log;

import com.easefun.polyv.businesssdk.PolyvChatDomainManager;
import com.easefun.polyv.businesssdk.model.chat.PolyvChatDomain;
import com.easefun.polyv.businesssdk.model.video.PolyvPlayBackVO;
import com.easefun.polyv.businesssdk.service.PolyvLoginManager;
import com.easefun.polyv.businesssdk.vodplayer.PolyvVodSDKClient;
import com.easefun.polyv.cloudclass.config.PolyvLiveSDKClient;
import com.easefun.polyv.cloudclass.model.PolyvLiveStatusVO;
import com.easefun.polyv.cloudclass.net.PolyvApiManager;
import com.easefun.polyv.cloudclassdemo.watch.PolyvCloudClassHomeActivity;
import com.easefun.polyv.foundationsdk.log.PolyvCommonLog;
import com.easefun.polyv.foundationsdk.net.PolyvResponseBean;
import com.easefun.polyv.foundationsdk.net.PolyvResponseExcutor;
import com.easefun.polyv.foundationsdk.net.PolyvrResponseCallback;
import com.easefun.polyv.linkmic.PolyvLinkMicClient;
import com.easefun.polyv.thirdpart.blankj.utilcode.util.ToastUtils;
import com.easefun.polyvsdk.cloudclass.R;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;

import java.io.IOException;

import io.reactivex.disposables.Disposable;
import retrofit2.adapter.rxjava2.HttpException;

import static com.polyv.rn.PolyvErrorCode.channleLoadFailed;

/**
 * @author df
 * @create 2019/9/6
 * @Describe
 */
public class PolyvCloudClassRNModule extends ReactContextBaseJavaModule {
    private static final String TAG = "PolyvRNCloudClassLoginModule";
    private ProgressDialog progress;
    private Disposable getTokenDisposable, verifyDispose;

    public PolyvCloudClassRNModule(ReactApplicationContext reactContext) {
        super(reactContext);

    }

    private void initProgress() {
        progress = new ProgressDialog(getCurrentActivity());
        progress.setMessage(getReactApplicationContext().getResources().getString(R.string.login_waiting));
        progress.setCanceledOnTouchOutside(false);
        progress.setOnDismissListener(new DialogInterface.OnDismissListener() {
            @Override
            public void onDismiss(DialogInterface dialog) {
                if (getTokenDisposable != null) {
                    getTokenDisposable.dispose();
                }
                if (verifyDispose != null) {
                    verifyDispose.dispose();
                }
            }
        });
    }

    @Override
    public String getName() {
        return TAG;
    }

    @ReactMethod
    public void init(String vodKey, String decodeKey, String decodeIv, String viewerId, String nickName, Promise promise) {
        initProgress();
        int code = PolyvErrorCode.success;

        if (TextUtils.isEmpty(viewerId)) {
            code = PolyvErrorCode.noViewId;
        } else if (TextUtils.isEmpty(vodKey)) {
            code = PolyvErrorCode.noVodKey;
        } else if (TextUtils.isEmpty(decodeKey)) {
            code = PolyvErrorCode.noDecodeKey;
        } else if (TextUtils.isEmpty(decodeIv)) {
            code = PolyvErrorCode.noDecodeIv;
        }

        if (code == PolyvErrorCode.success) {
            PolyvInitManager.init(vodKey, decodeKey, decodeIv, getReactApplicationContext());

            sendSuccessMessage(promise);
        } else {
            sendErrorMessage(promise, code);

        }
    }

    private void sendSuccessMessage(Promise promise) {
        WritableMap map = Arguments.createMap();
        map.putInt("code", PolyvErrorCode.success);
        promise.resolve(map);
    }

    private void sendErrorMessage(Promise promise, int code) {
        String errorCode = "" + code;
        String errorDesc = PolyvErrorCode.getDesc(code);
        Throwable throwable = new Throwable(errorDesc);
        Log.e(TAG, "errorCode=" + errorCode + "  errorDesc=" + errorDesc);
        promise.reject(errorCode, errorDesc, throwable);
    }

    @ReactMethod
    public void playbackLogin(int handler, String userId, String channelId,
                              String vid, String appId, String appScrect, Promise promise) {
        int code = PolyvErrorCode.success;

        if (TextUtils.isEmpty(userId)) {
            code = PolyvErrorCode.noUserId;
        } else if (TextUtils.isEmpty(channelId)) {
            code = PolyvErrorCode.noChannelId;
        } else if (TextUtils.isEmpty(vid)) {
            code = PolyvErrorCode.noVideoId;
        } else if (TextUtils.isEmpty(appId)) {
            code = PolyvErrorCode.noAppId;
        } else if (TextUtils.isEmpty(appScrect)) {
            code = PolyvErrorCode.noAppScrect;
        }

        if(code == PolyvErrorCode.success){
            progress.show();
            checkToken(userId,appScrect,channelId,vid,appId,false,promise);
        }else {
            sendErrorMessage(promise, code);
        }
    }

    @ReactMethod
    public void liveLogin(int handler, String userId, String channelId, String appId, String appScrect, Promise promise) {
        int code = PolyvErrorCode.success;

        if (TextUtils.isEmpty(userId)) {
            code = PolyvErrorCode.noUserId;
        } else if (TextUtils.isEmpty(channelId)) {
            code = PolyvErrorCode.noChannelId;
        } else if (TextUtils.isEmpty(appId)) {
            code = PolyvErrorCode.noAppId;
        } else if (TextUtils.isEmpty(appScrect)) {
            code = PolyvErrorCode.noAppScrect;
        }

        if(code == PolyvErrorCode.success){
            progress.show();
            checkToken(userId,appScrect,channelId,null,appId,true, promise);

        }else {
            sendErrorMessage(promise, code);
        }
    }

    private void checkToken(String userId, String appSecret, String channel, String vid, String appId, boolean live, Promise promise) {
        String secret = live ? appSecret : "";
        //请求token接口
        getTokenDisposable = PolyvLoginManager.checkLoginToken(userId, secret, appId,
                channel, vid,
                new PolyvrResponseCallback<PolyvChatDomain>() {
                    @Override
                    public void onSuccess(PolyvChatDomain responseBean) {
                        PolyvLinkMicClient.getInstance().setAppIdSecret(appId, appSecret);
                        PolyvLiveSDKClient.getInstance().setAppIdSecret(appId, appSecret);
                        PolyvVodSDKClient.getInstance().initConfig(appId, appSecret);

                        if (!live) {
                            requestPlayBackStatus(userId,channel, vid,promise);
                            return;
                        }
                        requestLiveStatus(userId, channel,promise);

                        PolyvChatDomainManager.getInstance().setChatDomain(responseBean);
                    }

                    @Override
                    public void onFailure(PolyvResponseBean<PolyvChatDomain> responseBean) {
                        super.onFailure(responseBean);
                        failedStatus(responseBean.getMessage());
                    }

                    @Override
                    public void onError(Throwable e) {
                        super.onError(e);
                        errorStatus(e,promise);
                    }
                });
    }

    private void requestPlayBackStatus(String userId, String channelId, String vid, Promise promise) {
        if (TextUtils.isEmpty(vid)) {
            return;
        }
        verifyDispose = PolyvLoginManager.getPlayBackType(vid, new PolyvrResponseCallback<PolyvPlayBackVO>() {
            @Override
            public void onSuccess(PolyvPlayBackVO playBack) {
                sendSuccessMessage(promise);
                boolean isLivePlayBack = playBack.getLiveType() == 0;
                startActivityForPlayback(vid,channelId,userId, isLivePlayBack);
            }

            @Override
            public void onFailure(PolyvResponseBean<PolyvPlayBackVO> responseBean) {
                super.onFailure(responseBean);
                failedStatus(responseBean.getMessage());
            }

            @Override
            public void onError(Throwable e) {
                super.onError(e);
                errorStatus(e, promise);
            }
        });
    }

    public void failedStatus(String message) {
        ToastUtils.showLong(message);
    }

    public void errorStatus(Throwable e, Promise promise) {
        PolyvCommonLog.exception(e);
        progress.dismiss();
        if (e instanceof HttpException) {
            try {
                sendErrorMessage(promise,channleLoadFailed);
                ToastUtils.showLong(((HttpException) e).response().errorBody().string());
            } catch (IOException e1) {
                e1.printStackTrace();
            }
        } else {
            ToastUtils.showLong(e.getMessage());
        }
    }

    private void requestLiveStatus(String userId, String channelId, Promise promise) {
        verifyDispose = PolyvResponseExcutor.excuteUndefinData(PolyvApiManager.getPolyvLiveStatusApi().geLiveStatusJson(channelId)
                , new PolyvrResponseCallback<PolyvLiveStatusVO>() {
                    @Override
                    public void onSuccess(PolyvLiveStatusVO statusVO) {
                        String data = statusVO.getData();
                        String[] dataArr = data.split(",");

                        boolean isAlone = "alone".equals(dataArr[1]);//是否有ppt
                        sendSuccessMessage(promise);
                        startActivityForLive(userId, channelId, isAlone);
                        progress.dismiss();
                    }

                    @Override
                    public void onFailure(PolyvResponseBean<PolyvLiveStatusVO> responseBean) {
                        super.onFailure(responseBean);
                        failedStatus(responseBean.getMessage());
                    }

                    @Override
                    public void onError(Throwable e) {
                        super.onError(e);
                        errorStatus(e, promise);
                    }
                });
    }

    private String getTrim(String playbackUserId) {
        return playbackUserId.trim();
    }

    // <editor-fold defaultstate="collapsed" desc="startActivity">
    private void startActivityForLive(String userId, String channelId, boolean isAlone) {
        PolyvCloudClassHomeActivity.startActivityForLive(getCurrentActivity(),
                getTrim(channelId), userId, isAlone);
    }

    private void startActivityForPlayback(String playbackVideoId,String playbackChannelId,String playbackUserId, boolean isNormalLivePlayBack) {
        progress.dismiss();
        PolyvCloudClassHomeActivity.startActivityForPlayBack(getCurrentActivity(),
                getTrim(playbackVideoId), getTrim(playbackChannelId), getTrim(playbackUserId), isNormalLivePlayBack);
    }
    // </editor-fold>
}
