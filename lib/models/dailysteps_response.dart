class DailyStepsDetails {
  String date;
  String wakeupTime;
  int dailySteps;
  double standHours;
  double activityHours;
  String sleepTime;
  double sleepHours;
  int wellnessId;

  DailyStepsDetails({
    required this.date,
    required this.wakeupTime,
    required this.dailySteps,
    required this.standHours,
    required this.activityHours,
    required this.sleepTime,
    required this.sleepHours,
    required this.wellnessId,
  });

  // Factory method to convert JSON to Detail object
  factory DailyStepsDetails.fromJson(Map<String, dynamic> json) {
    return DailyStepsDetails(
      date: json['date'],
      wakeupTime: json['wakeupTime'],
      dailySteps: json['dailySteps'],
      standHours: json['standHours'].toDouble(),
      activityHours: json['activityHours'].toDouble(),
      sleepTime: json['sleepTime'],
      sleepHours: json['sleepHours'].toDouble(),
      wellnessId: json['wellnessId'],
    );
  }

  // Convert Detail object to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date,
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


class DailyStepsResponse {
  List<DailyStepsDetails> details;
  String message;
  String status;

  DailyStepsResponse({
    required this.details,
    required this.message,
    required this.status,
  });

  // Factory method to convert JSON to WellnessData object
  factory DailyStepsResponse.fromJson(Map<String, dynamic> json) {
    var list = json['details'] as List;
    List<DailyStepsDetails> detailsList = list.map((i) => DailyStepsDetails.fromJson(i)).toList();

    return DailyStepsResponse(
      details: detailsList,
      message: json['message'],
      status: json['status'],
    );
  }

  // Convert WellnessData object to JSON
  Map<String, dynamic> toJson() {
    return {
      'details': details.map((e) => e.toJson()).toList(),
      'message': message,
      'status': status,
    };
  }
}


class DailyStepsDBModel {
  final int id;
  final String steps, date;

  DailyStepsDBModel({
    required this.id,
    required this.steps,
    required this.date,
});
}