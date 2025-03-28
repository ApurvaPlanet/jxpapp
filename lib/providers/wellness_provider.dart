import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'package:jxp_app/models/bmi_response.dart';
import 'package:jxp_app/models/schedule_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:jxp_app/models/wellness_response.dart';

import '../models/wellness_response.dart';
import '../services/api_interceptor.dart';

class WellnessProvider with ChangeNotifier{

  final Dio _dio = Dio();
  bool _isLoading = false;

  WellnessData? _wellnessData;
  BmiResponse? bmiResponse;
  ScheduleResponse? scheduleResponse;

  WellnessProvider(){
    _dio.interceptors.add(ApiInterceptor(_dio)); // Attach interceptor
  }

   WellnessData? get wellnessData => _wellnessData;

  bool get isLoading => _isLoading;

  ScheduleResponse? get scheduleData => scheduleResponse;

  Future<Response> _apiCall(String endpoint, Object data) async {
    return await _dio.post("/$endpoint", data: data); // Ensure leading slash
  }

  Future<void> getWellnessDetail (String action, String from, String to) async{

    var prefs = await SharedPreferences.getInstance();
    var idStr = prefs.get('userId').toString();
    var id = int.parse(idStr);

    _isLoading = true;
    notifyListeners();

    try{
      final response = await _apiCall("getwellnessdetails", {
        "id": id,
        "action": action,
        "from": from,
        "to": to,
      });

      if (response.statusCode == 200) {

         _wellnessData = WellnessData.fromJson(response.data);

      } else {
        throw Exception("Server Error");
      }

    }catch(e){
      throw Exception("getWellnessDetail api Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }


  Future<void> getBMIDetail (int id, String action) async{
    _isLoading = true;
    notifyListeners();

    try{
      final response = await _apiCall("getwellnessdetails", {
        "id": id,
        "action": action,
      });

      if (response.statusCode == 200) {
        bmiResponse = BmiResponse.fromJson(response.data);
      } else {
        throw Exception("Server Error");
      }

    }catch(e){
      throw Exception("getBMIDetail api Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getScheduleDetails () async{

    var prefs = await SharedPreferences.getInstance();
    var idStr = prefs.get('userId').toString();
    var id = int.parse(idStr);

    _isLoading = true;
    notifyListeners();

    try{
      final response = await _apiCall("getschedule", {
        "id": id
      });

      if (response.statusCode == 200) {
        scheduleResponse = ScheduleResponse.fromJson(response.data);
      } else {
        throw Exception("Server Error");
      }

    }catch(e){
      throw Exception("getScheduleDetails api Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveHours(String module, String timeValue, String wakeupTime, String sleepHours) async {
    var prefs = await SharedPreferences.getInstance();
    var idStr = prefs.getString('userId') ?? "0";
    var id = int.tryParse(idStr) ?? 0;

    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> requestBody = {
        "id": id,
      };

      if (module == 'sleephours') {
        requestBody.addAll({
          "sleepTime": timeValue,
          "wakeupTime": wakeupTime,
          "sleepHours": sleepHours,
        });
      } else if (module == 'standhours') {
        requestBody["standHours"] = timeValue;
      } else if (module == 'activehours') {
        requestBody["activityHours"] = timeValue;
      }

      final response = await _apiCall("setschedule", requestBody);

      if (response.statusCode == 200) {
        debugPrint("Hours saved successfully.");
      } else {
        debugPrint("Failed to save hours. ");
      }
    } catch (e) {
      debugPrint("Error saving hours: $e");
    }

    _isLoading = false;
    notifyListeners();
  }


  Future<void> editHours(int wellnessId, String module, String wakeupTime, int dailySteps, double standHours, double activeHours, String sleepTime, double sleepHours) async {
    var prefs = await SharedPreferences.getInstance();
    var idStr = prefs.get('userId').toString();
    var id = int.parse(idStr);

    _isLoading = true;
    notifyListeners();

    try {
      final requestBody = {
        "id": id,
        "wellnessId": wellnessId,
        "wakeupTime": wakeupTime,
        "dailySteps": dailySteps,
        "standHours": standHours,
        "activityHours": activeHours,
        "sleepTime":sleepTime,
        "sleepHours":sleepHours
      };

      final response = await _apiCall("setwellnessdetails", requestBody);

      if (response.statusCode == 200) {
        debugPrint("Hours saved successfully.");
      } else {
        debugPrint("Failed to save hours.");
      }
    } catch (e) {
      debugPrint("Error saving hours: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

}