import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_contest_flutter_app/util/colors_util.dart';
import 'package:image_contest_flutter_app/util/navigation_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String header;
  final String url;
  WebViewScreen(this.header, this.url);

  @override
  WebViewState createState() => WebViewState(header, url);
}

class WebViewState extends State<WebViewScreen> {
  final String header;
  final String url;
  WebViewState(this.header, this.url);

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: ColorsUtil.appThemeColor,
            centerTitle: true,
            elevation: 0.0,
            title: Text(
              header,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            leading: InkWell(
                onTap: () => NavigationService.instance.goBack(),
                child:
                Icon(Icons.arrow_back_ios_rounded, color: Colors.white))),
        body: WebView(
          initialUrl: url,
        ));
  }
}
