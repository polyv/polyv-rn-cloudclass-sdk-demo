import React, { Component } from "react";
import {
    Text,
    View,
    Image,
    TextInput,
    Dimensions,
    StyleSheet,
    ScrollView,
    KeyboardAvoidingView
} from "react-native";
import {
    createMaterialTopTabNavigator,
    createAppContainer
} from "react-navigation";
import { findNodeHandle } from 'react-native';
import PropTypes from 'prop-types';

import PolyvCloudClassModule from '../sdk/PolyvCloudClassLoginModule'
import PolyvUserConfig from '../demo/PolyvUserConfig'

const img = require("./img/logo_polyv.png")
const { width, height } = Dimensions.get("window")
const PolyvViewManager = {
    refCollection: {}
}

export default class PolyvLogin extends Component {
    // static propTypes = {
    //     loginInfo: PropTypes.object,
    // }
    static defaultProps = {
        // init
        // 初始化所需的数据
        vodKey: PolyvUserConfig.User.vodKey,
        decodeKey: PolyvUserConfig.User.decodeKey,
        decodeIv: PolyvUserConfig.User.decodeIv,
        viewerId: PolyvUserConfig.User.viewerId,
        nickName: PolyvUserConfig.User.nickName,
    }

    constructor(props) {
        super(props);
        this.state = {
            pressed:false,
            showTitleText: false,
            loginInfo: {},
            tabIndex: 0
        }
        this.handleNavigationChange = this.handleNavigationChange.bind(this)
    }


    componentWillMount() {
        console.log("componentWillMount");
        PolyvCloudClassModule.init(this.props.vodKey, this.props.decodeKey,
            this.props.decodeIv, this.props.viewerId, this.props.nickName)
            .then(ret => {
                if (ret.code != 0) {
                    // 初始化失败
                    var str = "初始化失败  errCode=" + ret.code + "  errMsg=" + ret.message;
                    console.log(str);
                    alert(str);
                } else {
                    // 初始化成功
                    console.log("初始化成功");
                }
            })
    }

    handleNavigationChange(prevState, newState, action) {
        console.log(`${prevState}   ${newState}   ${action}`)
        this.state.tabIndex = newState.index
        if (newState.index == 1) {//回放
            this.state.loginInfo = PolyvViewManager.refCollection['PlayBackLogin'].state.playbackInfo
        } else {
            this.state.loginInfo = PolyvViewManager.refCollection['LiveLogin'].state.liveInfo
        }

    }
    /**
     * 检查输入的合法性
     */
      checkInputIlleage() {
        var loginInfo = this.state.loginInfo
        if(!loginInfo.userId){
            alert("input userId")
            return false;
        }
        if(!loginInfo.channelId){
            alert("input channelId")
            return false;
        }
        if(!loginInfo.appId){
            alert("input appId")
            return false;
        }
        if(!loginInfo.appScrect){
            alert("input appScrect")
            return false;
        }
        if(this.state.tabIndex == 0){
            return true
        }else {
            if(!loginInfo.vid){
                alert("input vid")
                return false;
            }

            return true
        }
    }

    myPress() {
        if (this.state.pressed == true) {
            console.log("处理中，请稍后")
            return
        }
        this.state.pressed = true

        if (this.state.tabIndex == 1) {//回放
            this.state.loginInfo = PolyvViewManager.refCollection['PlayBackLogin'].state.playbackInfo
        } else {
            this.state.loginInfo = PolyvViewManager.refCollection['LiveLogin'].state.liveInfo
        }
        var loginInfo = this.state.loginInfo
        if (!loginInfo) {
            alert("input login info")
            this.state.pressed = false
            return
        }

        if(this.checkInputIlleage()){
            if(this.state.tabIndex == 0){ // 直播登录
                PolyvCloudClassModule.liveLogin(findNodeHandle(this), loginInfo.userId,
                loginInfo.channelId, loginInfo.appId, loginInfo.appScrect)
                .then(ret => {
                    this.state.pressed = false
                    if (ret.code != 0) {
                        var str = "登录失败  errCode=" + ret.code + "  errMsg=" + ret.message;
                        console.log(str);
                        alert(str);
                    } else {
                        console.log("登录成功");
                    }
                })
            } else { // 回放登录
                PolyvCloudClassModule.playbackLogin(findNodeHandle(this), loginInfo.userId,
                loginInfo.channelId, loginInfo.vid, loginInfo.appId, loginInfo.appScrect)
                .then(ret => {
                    this.state.pressed = false
                    if (ret.code != 0) {
                        var str = "登录失败  errCode=" + ret.code + "  errMsg=" + ret.message;
                        console.log(str);
                        alert(str);
                    } else {
                        console.log("登录成功");
                    }
                })
            }

            
        } else {
            this.state.pressed = false
        }
    }

    render() {
        let title = this.state.showTitleText ?
            <Text>POLYV&#160;&#160;云课堂</Text> :
            <Image source={img} style={styles.img}></Image>
        return (
            <View style={styles.container}>
                {title}
                <AppContainer style={styles.tab} onNavigationStateChange={this.handleNavigationChange} ref={'tab'} />
                <View style={styles.center}>
                    <Text style={styles.text}
                        onPress={() => {this.myPress()}}>登录</Text>
                </View>

            </View>
        )
    }

}

class LiveLogin extends Component {
    constructor(props) {
        super(props)
        this.state = {
            liveInfo: {
                channelId: PolyvUserConfig.User.inputChannelId,
                appId: PolyvUserConfig.User.inputAppId,
                appScrect: PolyvUserConfig.User.inputAppSecret,
                userId: PolyvUserConfig.User.inputUserId,
              },
        }
        PolyvViewManager.refCollection['LiveLogin'] = this
    }
    static navigationOptions = {
        tabBarLabel: "直播"
    };
    render() {
        console.log('render LiveLogin')
        return (
            <ScrollView >

                <TextInput style={styles.input} placeholder={"用户ID"}
                    underlineColorAndroid='gray'
                    onChangeText={text => {
                        this.state.liveInfo.userId = text
                        this.setState({ liveInfo: this.state.liveInfo })
                    }}>
                    {this.state.liveInfo.userId}
                </TextInput>
                <TextInput style={styles.input} placeholder={"频道ID"}
                    underlineColorAndroid='gray'
                    onChangeText={text => {
                        this.state.liveInfo.channelId = text
                        this.setState({ liveInfo: this.state.liveInfo })
                    }}>
                    {this.state.liveInfo.channelId}
                </TextInput>
                <TextInput style={styles.input} placeholder={"APP ID"}
                    underlineColorAndroid='gray'
                    onChangeText={text => {
                        this.state.liveInfo.appId = text
                        this.setState({ liveInfo: this.state.liveInfo })
                    }}>
                    {this.state.liveInfo.appId}
                </TextInput>
                <TextInput style={styles.input} placeholder={"APP Secrect"}
                    underlineColorAndroid='gray'
                    onChangeText={text => {
                        this.state.liveInfo.appScrect = text
                        this.setState({ liveInfo: this.state.liveInfo })
                    }}>
                    {this.state.liveInfo.appScrect}
                </TextInput>
                {/* <Text style={styles.text}
                        onPress={() => {
                            PolyvCloudClassModule.login(findNodeHandle(this), loginInfo.userId,
                                loginInfo.channelId, loginInfo.vid, loginInfo.appId, loginInfo.appScrect)
                        }}>登录</Text> */}

            </ScrollView>
        );
    }
}
class PlayBackLogin extends Component {
    static navigationOptions = {
        tabBarLabel: "回放"
    };
    constructor(props) {
        super(props)
        this.state = {
            playbackInfo: {
                appId: PolyvUserConfig.User.inputAppId,
                channelId: PolyvUserConfig.User.inputChannelId,
                appScrect: PolyvUserConfig.User.inputAppSecret,
                userId: PolyvUserConfig.User.inputUserId,
                vid: PolyvUserConfig.User.inputVid, 
              },
        }
        PolyvViewManager.refCollection['PlayBackLogin'] = this
    }
    render() {
        console.log('render PlayBackLogin')
        return (
            <ScrollView>
                <TextInput style={styles.input} placeholder={"用户ID"}
                    underlineColorAndroid='gray'
                    onChangeText={text => {
                        this.state.playbackInfo.userId = text
                        this.setState({ playbackInfo: this.state.playbackInfo })
                    }}>
                    {this.state.playbackInfo.userId}
                </TextInput>
                <TextInput style={styles.input} placeholder={"频道ID"}
                    underlineColorAndroid='gray'
                    onChangeText={text => {
                        this.state.playbackInfo.channelId = text
                        this.setState({ playbackInfo: this.state.playbackInfo })
                    }}>
                    {this.state.playbackInfo.channelId}
                </TextInput>
                <TextInput style={styles.input} placeholder={"APP ID"}
                    underlineColorAndroid='gray'
                    onChangeText={text => {
                        this.state.playbackInfo.appId = text
                        this.setState({ playbackInfo: this.state.playbackInfo })
                    }}>
                    {this.state.playbackInfo.appId}
                </TextInput>
                <TextInput style={styles.input} placeholder={"APP Secrect"}
                    underlineColorAndroid='gray'
                    onChangeText={text => {
                        this.state.playbackInfo.appScrect = text
                        this.setState({ playbackInfo: this.state.playbackInfo })
                    }}>
                    {this.state.playbackInfo.appScrect}
                </TextInput>
                <TextInput style={styles.input} placeholder={"回放VID"}
                    underlineColorAndroid='gray'
                    onChangeText={text => {
                        this.state.playbackInfo.vid = text
                        this.setState({ playbackInfo: this.state.playbackInfo })
                    }}>
                    {this.state.playbackInfo.vid}
                </TextInput>
            </ScrollView>);
    }
}

const AppContainer = createAppContainer(
    createMaterialTopTabNavigator(
        {
            live_login: { screen: LiveLogin },
            playback_login: { screen: PlayBackLogin },
        },
        {
            initialRouteName: "live_login",
            tabBarOptions: {
                activeTintColor: "tomato",
                inactiveTintColor: "gray",
                indicatorStyle: {
                    width: 50,
                    borderRadius: 5,
                    marginLeft: width / (2 * 2) - 25,
                    position: "absolute",
                    backgroundColor: "#2196F3"
                },
                labelStyle: {},
                tabStyle: {},
                style: {
                    backgroundColor: "white"
                }
            }
        }
    )
);

const styles = StyleSheet.create({

    container: {
        position: "relative",
        display: 'flex',
        flexDirection: 'column',
        flex: 1,
    },
    center: {
        position: "relative",
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center'
    },

    tab: {
        backgroundColor: "gray"
    },
    input: {

        display: 'flex',
        alignItems: 'center',
        height: 42,
        marginLeft: 50,
        marginRight: 50,
        margin: 10,
    },
    img: {
        height: 60,
        width: width,
        marginTop: 50,
        resizeMode: 'center',
    },
    txt: {
        flex: 1,
        top: 10,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        fontSize: 18,
        color: '#000000',

    },
    text: {
        textAlign: 'center',
        width: width * 0.8,
        borderRadius: 5,
        justifyContent: 'center',
        alignItems: 'center',
        fontSize: 20,
        height: 50,
        backgroundColor: "#63B8FF",
        margin: 10,
        padding: 10,
    },
});