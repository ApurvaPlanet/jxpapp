import 'package:intl/intl.dart';

class WellnessData {
  List<WellnessDetail> details;
  String message;
  String status;

  WellnessData({
    required this.details,
    required this.message,
    required this.status,
  });

  factory WellnessData.fromJson(Map<String, dynamic> json) {
    return WellnessData(
      details: (json['details'] as List)
          .map((item) => WellnessDetail.fromJson(item))
          .toList(),
      message: json['message'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'details': details.map((item) => item.toJson()).toList(),
      'message': message,
      'status': status,
    };
  }
}

class WellnessDetail {
  DateTime date;
  String wakeupTime;
  int dailySteps;
  double standHours;
  double activityHours;
  String sleepTime;
  double sleepHours;
  int wellnessId;

  WellnessDetail({
    required this.date,
    required this.wakeupTime,
    required this.dailySteps,
    required this.standHours,
    required this.activityHours,
    required this.sleepTime,
    required this.sleepHours,
    required this.wellnessId,
  });

  factory WellnessDetail.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate = DateFormat("dd-MM-yyyy").parse(json['date'] ?? "01-01-2000");
    return WellnessDetail(
      date: parsedDate,
      wakeupTime: json['wakeupTime']  ?? "",
      dailySteps: json['dailySteps'] ?? 0,
      standHours: (json['standHours'] as num).toDouble() ?? 0.0,
      activityHours: (json['activityHours'] as num).toDouble() ?? 0.0,
      sleepTime: json['sleepTime'] ?? "",
      sleepHours: (json['sleepHours'] as num).toDouble() ?? 0.0,
      wellnessId: json['wellnessId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': DateFormat("dd-MM-yyyy").format(date),
      'wakeupTime': wakeupTime,
      'dailySteps': dailySteps,
      'standHours': standHours,
      'activityHours': activityHours,
      'sleepTime': sleepTime,
      'sleepHours': sleepHours,
      'wellnessId': wellnessId,
    };
  }
}
