class Response {
  final int statusCode;
  final dynamic data;

  Response({
    required this.statusCode,
    required this.data,
  });

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      statusCode: json['statusCode'],
      data: json['data'],
    );
  }
}
