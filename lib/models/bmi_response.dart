class BmiResponse {
  final int weight;
  final String message;
  final String status;
  final int height;

  // Constructor
  BmiResponse({
    required this.weight,
    required this.message,
    required this.status,
    required this.height,
  });

  // Factory method to create a DataResponse object from JSON
  factory BmiResponse.fromJson(Map<String, dynamic> json) {
    return BmiResponse(
      weight: json['weight'],
      message: json['message'],
      status: json['status'],
      height: json['height'],
    );
  }

  // Method to convert a DataResponse object to JSON
  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'message': message,
      'status': status,
      'height': height,
    };
  }
}
