import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jxp_app/widgets/blur_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  String? url;
  late SharedPreferences prefs;

  @override
  void dispose() {
    // TODO: implement dispose
    // _webViewController.dispose();
    _webViewController.clearCache();
    _webViewController.setNavigationDelegate(NavigationDelegate()); // Remove delegate
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setUserAgent(
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );

    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        url = prefs.getString('webviewUrl') ??
            'http://sandbox.journeyxpro.com/jxp/crewlogin/';
        print("URL: $url");
      });
    }

    if (url != null) {
      _webViewController.loadRequest(Uri.parse(url!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (url != null) WebViewWidget(controller: _webViewController),
            if (_isLoading)
              BlurLoader(),
              // const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
