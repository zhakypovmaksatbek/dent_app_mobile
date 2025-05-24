class ResponseModel {
  String? httpStatus;
  String? message;

  ResponseModel({this.httpStatus, this.message});

  ResponseModel.fromJson(Map<String, dynamic> json) {
    httpStatus = json['httpStatus'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['httpStatus'] = httpStatus;
    data['message'] = message;
    return data;
  }
}
