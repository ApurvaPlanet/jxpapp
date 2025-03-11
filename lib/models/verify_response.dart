class VerifyResponse {
  final String userName;
  final String client;
  final int id;
  final String position;
  final String message;
  final String asset;
  final String url;
  final String status;


  VerifyResponse({
    required this.userName,
    required this.client,
    required this.id,
    required this.position,
    required this.message,
    required this.asset,
    required this.url,
    required this.status,
  });

  factory VerifyResponse.fromJson(Map<String, dynamic> json) {
    return VerifyResponse(
      userName: json["user_name"] ?? "",
      client: json["client"] ?? "",
      id: json["id"] ?? 0,
      position: json["position"] ?? "",
      message: json["message"] ?? "",
      asset: json["asset"] ?? "",
      url: json["url"] ?? "",
      status: json["status"] ?? "error",
    );
  }
}
