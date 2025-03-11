class OtpResponse {
  final int crId;
  final int otpId;
  final String crewName;
  final String message;
  final String status;

  OtpResponse({
    required this.crId,
    required this.otpId,
    required this.crewName,
    required this.message,
    required this.status,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      crId: json['cr_id'],
      otpId: json['otp_id'],
      crewName: json['crew_name'],
      message: json['message'],
      status: json['status'],
    );
  }
}
