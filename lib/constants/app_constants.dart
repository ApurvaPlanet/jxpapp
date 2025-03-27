

import 'dart:io';

import 'package:flutter/material.dart';

var appthemeLight = const Color(0xFF237bad);
var appthemeDark = const Color(0xFF172A72);
var appBackground = const Color(0xFFF1F2F2);
var btnsColor = const Color(0xFF237bad);
var graphBarColor = const Color(0xFFA3C8DE);
var darkGrayColor = const Color(0xFF818599);

var sandboxBaseUrl = "http://sandbox.journeyxpro.com/jxp/mob";
var baseUrl = "https://ocs-icm.journeyxpro.com/jxp/mob";

var iosVersion = 'v1.0.1';
var androidVersion = 'v1.0.3';

String getAppVersion() {
  if (Platform.isIOS) {
    return iosVersion;
  } else if (Platform.isAndroid) {
    return androidVersion;
  }
  return "";
}

// GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
