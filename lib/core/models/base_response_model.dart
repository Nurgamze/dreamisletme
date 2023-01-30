class ResponseModel<T> {
  T? responseData;
  int statusCode;
  String? errorMessage;

  ResponseModel({
    this.responseData,
    required this.statusCode,
    this.errorMessage,
  });
}