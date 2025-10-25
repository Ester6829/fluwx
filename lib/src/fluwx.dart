import 'dart:async';

import 'package:flutter/services.dart';

import 'foundation/arguments.dart';
import 'foundation/cancelable.dart';
import 'method_channel/fluwx_platform_interface.dart';
import 'response/wechat_response.dart';
import 'wechat_enums.dart';

class Fluwx {
  Fluwx() {
    _responseSubscription = FluwxPlatform.instance.responseEventHandler.listen(
      _responseEventListener,
      onDone: () {
        _responseSubscription?.cancel();
      },
    );
  }

  final _responseListeners = <WeChatResponseSubscriber>[];
  StreamSubscription<WeChatResponse>? _responseSubscription;

  void _responseEventListener(WeChatResponse event) {
    for (final listener in _responseListeners.toList()) {
      listener(event);
    }
  }

  Future<bool> get isWeChatInstalled => FluwxPlatform.instance.isWeChatInstalled;

  /// Open given target. See [OpenType] for more details
  Future<bool> open({required OpenType target}) {
    return FluwxPlatform.instance.open(target);
  }

  /// It's ok if you register multi times.
  /// [appId] is not necessary.
  /// if [doOnIOS] is true ,fluwx will register WXApi on iOS.
  /// if [doOnAndroid] is true, fluwx will register WXApi on Android.
  /// [universalLink] is required if you want to register on iOS.
  Future<bool> registerApi({
    required String appId,
    bool doOnIOS = true,
    bool doOnAndroid = true,
    String? universalLink,
  }) async {
    return FluwxPlatform.instance.registerApi(
        appId: appId,
        doOnAndroid: doOnAndroid,
        doOnIOS: doOnIOS,
        universalLink: universalLink);
  }

  /// Share your requests to WeChat.
  /// This depends on the actual type of [what].
  Future<bool> share(WeChatShareModel what) async {
    return FluwxPlatform.instance.share(what);
  }

  /// Login by WeChat.See [AuthType] for more details.
  Future<bool> authBy({required AuthType which}) async {
    return FluwxPlatform.instance.authBy(which);
  }

  /// Stop QR service
  Future<bool> stopAuthByQRCode() => FluwxPlatform.instance.stopAuthByQRCode();

  /// please read * [official docs](https://pay.weixin.qq.com/wiki/doc/api/wxpay_v2/papay/chapter3_2.shtml).
  Future<bool> autoDeduct({required AutoDeduct data}) async {
    return FluwxPlatform.instance.autoDeduct(data);
  }

  Future<bool> get isSupportOpenBusinessView async =>
      await FluwxPlatform.instance.isSupportOpenBusinessView;

  Future<bool> openBusinessView({
    required FluwxBusinessScene businessType,
    required String query,
  }) async {
    return FluwxPlatform.instance.openBusinessView(
      businessType: businessType,
      query: query,
    );
  }

  Future<String?> getExtMsg() async {
    return FluwxPlatform.instance.getExtMsg();
  }

  /// Pay with WeChat. See [PayType]
  Future<bool> pay({required PayType which}) async {
    return FluwxPlatform.instance.pay(which);
  }

  /// Try to reload data from cold boot. For example, the app is launched by mini program and
  /// we can get ext message by calling this.
  Future<void> attemptToResumeMsgFromWx() async {
    return FluwxPlatform.instance.attemptToResumeMsgFromWx();
  }

  /// Only works on iOS in debug mode.
  /// Check if your app can work with WeChat correctly.
  /// Please make sure [registerApi] returns true before self check.
  Future<void> selfCheck() async {
    return FluwxPlatform.instance.selfCheck();
  }

  /// Add a subscriber to subscribe responses from WeChat
  FluwxCancelable addSubscriber(WeChatResponseSubscriber listener) {
    _responseListeners.add(listener);
    return FluwxCancelableImpl(onCancel: () {
      removeSubscriber(listener);
    });
  }

  /// remove your subscriber from WeChat
  void removeSubscriber(WeChatResponseSubscriber listener) {
    _responseListeners.remove(listener);
  }

  /// remove all existing
  void clearSubscribers() {
    _responseListeners.clear();
  }

  void dispose() {
    _responseSubscription?.cancel();
    _responseListeners.clear();
  }
}
