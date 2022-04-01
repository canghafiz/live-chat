import 'package:flutter/material.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPage extends StatelessWidget {
  const WebPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConfig.colorPrimary,
      ),
      body: const WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: "https://hafizarrahman.com/",
      ),
    );
  }
}
