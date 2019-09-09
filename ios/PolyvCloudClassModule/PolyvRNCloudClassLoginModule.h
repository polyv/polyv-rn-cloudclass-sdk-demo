//
//  PolyvRNCloudClassLoginModule.h
//  PolyvRNCloudClassDemo
//
//  Created by MissYasiky on 2019/9/2.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PolyvCloudClassErrorCode) {
  PolyvCloudClassError_Success = 0,
  PolyvCloudClassError_NoAppId = -1,
  PolyvCloudClassError_NoAppSecret = -2,
  PolyvCloudClassError_NoViewerId = -3,
  PolyvCloudClassError_NoUserId = -4,
  PolyvCloudClassError_NoChannelId = -5,
  PolyvCloudClassError_NoVodId = -6,
  PolyvCloudClassError_LoginFailed = -10,
};

@interface PolyvRNCloudClassLoginModule : NSObject <RCTBridgeModule>

@end

NS_ASSUME_NONNULL_END
