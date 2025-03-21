class ScheduleResponse {
  final String? wakeupTime;
  final double? standHours;
  final double? activityHours;
  final String? sleepTime;
  final double? sleepHours;
  final String? message;
  final String? status;

  // Constructor
  ScheduleResponse({
    this.wakeupTime,
    this.standHours,
    this.activityHours,
    this.sleepTime,
    this.sleepHours,
    this.message,
    this.status,
  });

  // Factory method to create a ScheduleResponse object from JSON
  factory ScheduleResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleResponse(
      wakeupTime: json['wakeupTime'] as String?,
      standHours: (json['standHours'] as num?)?.toDouble(),
      activityHours: (json['activityHours'] as num?)?.toDouble(),
      sleepTime: json['sleepTime'] as String?,
      sleepHours: (json['sleepHours'] as num?)?.toDouble(),
      message: json['message'] as String?,
      status: json['status'] as String?,
    );
  }

  // Method to convert a ScheduleResponse object to JSON
  Map<String, dynamic> toJson() {
    return {
      'wakeupTime': wakeupTime,
      'standHours': standHours,
      'activityHours': activityHours,
      'sleepTime': sleepTime,
      'sleepHours': sleepHours,
      'message': message,
      'status': status,
    };
  }

  // CopyWith method for updating specific fields
  ScheduleResponse copyWith({
    String? wakeupTime,
    double? standHours,
    double? activityHours,
    String? sleepTime,
    double? sleepHours,
    String? message,
    String? status,
  }) {
    return ScheduleResponse(
      wakeupTime: wakeupTime ?? this.wakeupTime,
      standHours: standHours ?? this.standHours,
      activityHours: activityHours ?? this.activityHours,
      sleepTime: sleepTime ?? this.sleepTime,
      sleepHours: sleepHours ?? this.sleepHours,
      message: message ?? this.message,
      status: status ?? this.status,
    );
  }
}
