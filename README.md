# Fluwx

本插件二次开发基于：https://github.com/OpenFlutter/fluwx 
具体原文档请点击查看：[原创链接](https://github.com/OpenFlutter/fluwx)

## 更新了什么？
添加了商家转账领取功能！


## 使用方法
 ```
  String _result = "无";
  final Fluwx fluwx = Fluwx();
  FluwxCancelable? _cancelable;

  @override
  void initState() {
    super.initState();
    doInit();
  }

  doInit() async {
    // 注册插件
    await fluwx.registerApi(
      appId: 'xxx',
      doOnAndroid: true,
      doOnIOS: true,
      universalLink: 'xxxx',
    );
    var result = await fluwx.isWeChatInstalled;
    debugPrint('is installed $result');

    // 监听微信的响应,是否转账成功
    _cancelable = fluwx.addSubscriber((response) {
      // 调试：打印收到的所有响应类型和数据
      print("Fluwx response type: ${response.runtimeType}");
      print("Fluwx response data: ${response.toString()}");

      if (response is WeChatOpenBusinessViewResponse) {
        _result =
            "业务类型: ${response.businessType}\n错误码: ${response.errCode}\n结果: ${response.isSuccessful ? "成功" : "失败"}";
        print(_result);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _cancelable?.cancel();
    super.dispose();
  }

  void _startBusinessTransfer() {
    fluwx.openBusinessView(
        businessType: FluwxBusinessScene.requestMerchantTransfer,
        query: Uri(queryParameters: {
          "appId": "xxxx",
          "mchId": "xxx",
          "package":"xxxx",
        }).query);
  }

```

