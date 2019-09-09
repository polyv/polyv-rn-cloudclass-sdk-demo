//
//  PolyvRNCloudClassLoginModule.m
//  PolyvRNCloudClassDemo
//
//  Created by MissYasiky on 2019/9/2.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "PolyvRNCloudClassLoginModule.h"
#import <PolyvCloudClassSDK/PLVLiveVideoConfig.h>
#import <React/RCTLog.h>
#import <React/RCTUIManager.h>
#import <PolyvFoundationSDK/PLVProgressHUD.h>
#import <PolyvCloudClassSDK/PLVLiveVideoAPI.h>
#import "PLVLiveViewController.h"
#import "PLVVodViewController.h"
#import "PCCUtils.h"

NSString * NSStringFromErrorCode(PolyvCloudClassErrorCode code) {
  switch (code) {
    case PolyvCloudClassError_Success:
      return @"成功";
    case PolyvCloudClassError_NoAppId:
      return @"AppId为空";
    case PolyvCloudClassError_NoAppSecret:
      return @"AppSecret为空";
    case PolyvCloudClassError_NoUserId:
      return @"UserId为空";
    case PolyvCloudClassError_NoChannelId:
      return @"ChannelId为空";
    case PolyvCloudClassError_NoVodId:
      return @"VodId为空";
    case PolyvCloudClassError_LoginFailed:
      return @"频道登录失败";
    default:
      return @"";
  }
}

@implementation PolyvRNCloudClassLoginModule

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

// 初始化
// 参数 vodKey (选填)
// 参数 decodeKey (选填)
// 参数 decodeIv（选填）
// 参数 viewerId（必填）
// 参数 nickName（选填）
RCT_EXPORT_METHOD(
                  init:(NSString *)vodKey
                  decodeKey:(NSString *)decodeKey
                  decodeIv:(NSString *)decodeIv
                  viewerId:(NSString *)viewerId
                  nickName:(NSString *)nickName
                  findEventsWithResolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject
                  )
{
  NSLog(@"init() - %@ 、 %@ 、  %@ 、 %@ 、 %@", vodKey, decodeKey, decodeIv, viewerId, nickName);
  RCTLogInfo(@"init() - %@ 、 %@ 、 %@ 、 %@、 %@", vodKey, decodeKey, decodeIv, viewerId, nickName);
  
  if (viewerId.length > 0) { // 配置统计后台参数：用户Id、用户昵称及自定义参数
    [PLVLiveVideoConfig setViewLogParam:viewerId param2:nickName param4:nil param5:nil];
    resolve(@[@(PolyvCloudClassError_Success)]);
  } else {
    PolyvCloudClassErrorCode errorCode = PolyvCloudClassError_NoViewerId;
    NSString *errorDesc = NSStringFromErrorCode(errorCode);
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey:errorDesc}];
    NSLog(@"%@", errorDesc);
    reject([@(errorCode) stringValue], errorDesc, error);
  }
}

// 直播登录
// 参数 userId（必填）
// 参数 channelId (必填)
// 参数 appId (必填)
// 参数 appSecret (必填)
RCT_EXPORT_METHOD(
                  liveLogin:(nonnull NSNumber *)reactTag
                  userId:(NSString *)userId
                  channelId:(NSString *)channelId
                  appId:(NSString *)appId
                  appSecret:(NSString *)appSecret
                  findEventsWithResolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject
                  )
{
  NSLog(@"init() - %@ 、 %@ 、  %@ 、 %@", appId, appSecret, channelId, userId);
  RCTLogInfo(@"init() - %@ 、 %@ 、 %@ 、 %@", appId, appSecret, channelId, userId);
  
  PolyvCloudClassErrorCode errorCode = PolyvCloudClassError_Success;
  
  if (!appId.length) {
    errorCode = PolyvCloudClassError_NoAppId;
  } else if (!appSecret.length) {
    errorCode = PolyvCloudClassError_NoAppSecret;
  } else if (!userId.length) {
    errorCode = PolyvCloudClassError_NoUserId;
  } else if (!channelId.length) {
    errorCode = PolyvCloudClassError_NoChannelId;
  }
  
  if (errorCode != PolyvCloudClassError_Success) {
    NSString *errorDesc = NSStringFromErrorCode(errorCode);
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey:errorDesc}];
    NSLog(@"%@", errorDesc);
    reject([@(errorCode) stringValue], errorDesc, error);
  }
  
  RCTUIManager *uiManager = _bridge.uiManager;
  dispatch_async(uiManager.methodQueue, ^{
    [uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
      UIView *view = viewRegistry[reactTag];
      UIViewController *viewController = (UIViewController *)view.reactViewController;
      
      PLVProgressHUD *hud = [PLVProgressHUD showHUDAddedTo:viewController.view animated:YES];
      [hud.label setText:@"登录中..."];
      
      [PLVLiveVideoAPI verifyPermissionWithChannelId:channelId.integerValue vid:@"" appId:appId userId:userId appSecret:appSecret completion:^{
        [PLVLiveVideoAPI liveStatus:channelId completion:^(BOOL liveing, NSString *liveType) {
          [PLVLiveVideoAPI getChannelMenuInfos:channelId.integerValue completion:^(PLVLiveVideoChannelMenuInfo *channelMenuInfo) {
            
            [hud hideAnimated:YES];
            
            [PLVLiveVideoConfig liveConfigWithUserId:userId appId:appId appSecret:appSecret];
            [PLVLiveVideoConfig sharedInstance].channelId = channelId;
            
            PLVLiveViewController *liveVC = [PLVLiveViewController new];
            liveVC.liveType = [@"ppt" isEqualToString:liveType] ? PLVLiveViewControllerTypeCloudClass : PLVLiveViewControllerTypeLive;
            liveVC.playAD = !liveing;
            liveVC.channelMenuInfo = channelMenuInfo;
            
//            // 抽奖功能必须固定唯一的 nickName 和 userId，如果忘了填写上次的中奖信息，有固定的 userId 还会再次弹出相关填写页面
//            liveVC.nickName = @"iOS user"; // 设置登录聊天室的用户名
//            liveVC.avatarUrl = @"https://"; // 设置自定义聊天室用户头像地址
            [viewController presentViewController:liveVC animated:YES completion:nil];
            
            resolve(@[@(PolyvCloudClassError_Success)]);
            
          } failure:^(NSError *error) {
            
            [hud hideAnimated:YES];
            
            [PLVLiveVideoConfig liveConfigWithUserId:userId appId:appId appSecret:appSecret];
            [PLVLiveVideoConfig sharedInstance].channelId = channelId;
            
            PLVLiveViewController *liveVC = [PLVLiveViewController new];
            liveVC.liveType = [@"ppt" isEqualToString:liveType] ? PLVLiveViewControllerTypeCloudClass : PLVLiveViewControllerTypeLive;
            liveVC.playAD = !liveing;
            
//            // 抽奖功能必须固定唯一的 nickName 和 userId，如果忘了填写上次的中奖信息，有固定的 userId 还会再次弹出相关填写页面
//            liveVC.nickName = @"iOS user"; // 设置登录聊天室的用户名
//            liveVC.avatarUrl = @"https://"; // 设置自定义聊天室用户头像地址
            [viewController presentViewController:liveVC animated:YES completion:nil];
            
            NSLog(@"频道菜单获取失败！%@",error);
            resolve(@[@(PolyvCloudClassError_Success)]);
            
          }];
        } failure:^(NSError *error) {
          
          [hud hideAnimated:YES];
          
          NSString *errorDesc = NSStringFromErrorCode(PolyvCloudClassError_LoginFailed);
          NSError *aError = [NSError errorWithDomain:NSURLErrorDomain code:PolyvCloudClassError_LoginFailed userInfo:@{NSLocalizedDescriptionKey:errorDesc}];
          
          NSLog(@"%@", errorDesc);
          [PCCUtils presentAlertViewController:@"" message:errorDesc inViewController:viewController];
          reject([@(PolyvCloudClassError_LoginFailed) stringValue], errorDesc, aError);
          
        }];
      } failure:^(NSError *error) {
        
        [hud hideAnimated:YES];
        
        NSString *errorDesc = NSStringFromErrorCode(PolyvCloudClassError_LoginFailed);
        NSError *aError = [NSError errorWithDomain:NSURLErrorDomain code:PolyvCloudClassError_LoginFailed userInfo:@{NSLocalizedDescriptionKey:errorDesc}];
        
        NSLog(@"%@", errorDesc);
        [PCCUtils presentAlertViewController:@"" message:errorDesc inViewController:viewController];
        reject([@(PolyvCloudClassError_LoginFailed) stringValue], errorDesc, aError);
        
      }];
    }];
  });
}

// 回放登录
// 参数 userId（必填）
// 参数 channelId (必填)
// 参数 vodId (必填)
// 参数 appId (必填)
// 参数 appSecret (必填)
RCT_EXPORT_METHOD(
                  playbackLogin:(nonnull NSNumber *)reactTag
                  userId:(NSString *)userId
                  channelId:(NSString *)channelId
                  vodId:(NSString *)vodId
                  appId:(NSString *)appId
                  appSecret:(NSString *)appSecret
                  findEventsWithResolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject
                  )
{
  NSLog(@"init() - %@ 、 %@ 、  %@ 、 %@ 、 %@", appId, appSecret, channelId, userId, vodId);
  RCTLogInfo(@"init() - %@ 、 %@ 、 %@ 、 %@、 %@", appId, appSecret, channelId, userId, vodId);
  
  PolyvCloudClassErrorCode errorCode = PolyvCloudClassError_Success;
  
  if (!appId.length) {
    errorCode = PolyvCloudClassError_NoAppId;
  } else if (!appSecret.length) {
    errorCode = PolyvCloudClassError_NoAppSecret;
  } else if (!userId.length) {
    errorCode = PolyvCloudClassError_NoUserId;
  } else if (!channelId.length) {
    errorCode = PolyvCloudClassError_NoChannelId;
  } else if (!vodId.length) {
    errorCode = PolyvCloudClassError_NoVodId;
  }
  
  if (errorCode != PolyvCloudClassError_Success) {
    NSString *errorDesc = NSStringFromErrorCode(errorCode);
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey:errorDesc}];
    NSLog(@"%@", errorDesc);
    reject([@(errorCode) stringValue], errorDesc, error);
  }
  
  RCTUIManager *uiManager = _bridge.uiManager;
  dispatch_async(uiManager.methodQueue, ^{
    [uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
      UIView *view = viewRegistry[reactTag];
      UIViewController *viewController = (UIViewController *)view.reactViewController;
      
      PLVProgressHUD *hud = [PLVProgressHUD showHUDAddedTo:viewController.view animated:YES];
      [hud.label setText:@"登录中..."];
      
      [PLVLiveVideoAPI verifyPermissionWithChannelId:0 vid:vodId appId:appId userId:userId appSecret:@"" completion:^{
        [PLVLiveVideoAPI getVodType:vodId completion:^(BOOL vodType) {
          [PLVLiveVideoAPI getChannelMenuInfos:channelId.integerValue completion:^(PLVLiveVideoChannelMenuInfo *channelMenuInfo) {
            
            [hud hideAnimated:YES];
            
            [PLVLiveVideoConfig liveConfigWithUserId:userId appId:appId appSecret:appSecret];
            [PLVLiveVideoConfig sharedInstance].channelId = channelId;
            [PLVLiveVideoConfig sharedInstance].vodId = vodId;
            
            PLVVodViewController *vodVC = [PLVVodViewController new];
            vodVC.vodType = vodType ? PLVVodViewControllerTypeCloudClass : PLVVodViewControllerTypeLive;
            vodVC.channelMenuInfo = channelMenuInfo;
            [viewController presentViewController:vodVC animated:YES completion:nil];
            
            resolve(@[@(PolyvCloudClassError_Success)]);
            
          } failure:^(NSError *error) {
            
            [hud hideAnimated:YES];
            
            [PLVLiveVideoConfig liveConfigWithUserId:userId appId:appId appSecret:appSecret];
            [PLVLiveVideoConfig sharedInstance].channelId = channelId;
            [PLVLiveVideoConfig sharedInstance].vodId = vodId;
            
            PLVVodViewController *vodVC = [PLVVodViewController new];
            vodVC.vodType = vodType ? PLVVodViewControllerTypeCloudClass : PLVVodViewControllerTypeLive;
            [viewController presentViewController:vodVC animated:YES completion:nil];
            
            NSLog(@"频道菜单获取失败！%@",error);
            resolve(@[@(PolyvCloudClassError_Success)]);
            
          }];
        } failure:^(NSError *error) {
          
          [hud hideAnimated:YES];
          
          NSString *errorDesc = NSStringFromErrorCode(PolyvCloudClassError_LoginFailed);
          NSError *aError = [NSError errorWithDomain:NSURLErrorDomain code:PolyvCloudClassError_LoginFailed userInfo:@{NSLocalizedDescriptionKey:errorDesc}];
          
          NSLog(@"%@", errorDesc);
          [PCCUtils presentAlertViewController:@"" message:errorDesc inViewController:viewController];
          reject([@(PolyvCloudClassError_LoginFailed) stringValue], errorDesc, aError);
          
        }];
      } failure:^(NSError *error) {
        
        [hud hideAnimated:YES];
        
        NSString *errorDesc = NSStringFromErrorCode(PolyvCloudClassError_LoginFailed);
        NSError *aError = [NSError errorWithDomain:NSURLErrorDomain code:PolyvCloudClassError_LoginFailed userInfo:@{NSLocalizedDescriptionKey:errorDesc}];
        
        NSLog(@"%@", errorDesc);
        [PCCUtils presentAlertViewController:@"" message:errorDesc inViewController:viewController];
        reject([@(PolyvCloudClassError_LoginFailed) stringValue], errorDesc, aError);
        
      }];
    }];
  });
}

@end
