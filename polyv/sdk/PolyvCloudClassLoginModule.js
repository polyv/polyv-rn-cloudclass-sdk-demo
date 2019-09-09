'use strict';

import { NativeModules } from 'react-native';
const PolyvRNCloudClassLoginModule = NativeModules.PolyvRNCloudClassLoginModule

export const PolyvCloudClassModule = {
    //初始化
    async init (vodKey, decodeKey, decodeIv, viewerId, nickName){
        console.log(`config_${vodKey}_${decodeKey}_${decodeIv}`)
        try {
            PolyvRNCloudClassLoginModule.init(vodKey, decodeKey, decodeIv, viewerId, nickName)
            .then(ret =>{
                
            })
            console.log('result end')
            return { "code":0 }
        } catch (e) {
            var code = e.code;
            var message = e.message;
            return { code, message }
        }
    },

    async liveLogin(handler, userId, channelId, appId, appSecrect){
        console.log(`login_${userId}_${channelId}`)
        try {
            await PolyvRNCloudClassLoginModule.liveLogin(handler, userId, channelId, appId, appSecrect)
            return { "code":0 }
        } catch (e) {
            var code = e.code;
            var message = e.message;
            return { code, message }
        }
    },

    async playbackLogin(handler, userId, channelId, vid, appId, appSecrect){
        console.log(`login_${userId}_${channelId}`)
        try {
            await PolyvRNCloudClassLoginModule.playbackLogin(handler, userId, channelId, vid, appId, appSecrect)
            return { "code":0 }
        } catch (e) {
            var code = e.code;
            var message = e.message;
            return { code, message }
        }
    }
}
module.exports = PolyvCloudClassModule;