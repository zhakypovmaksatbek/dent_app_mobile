class ClinicModel {
  int? id;
  String? name;
  String? address;
  String? startWorkTime;
  String? endWorkTime;
  String? currency;
  String? phoneNumber;
  ImageResponse? imageResponse;

  ClinicModel({
    this.id,
    this.name,
    this.address,
    this.startWorkTime,
    this.endWorkTime,
    this.currency,
    this.phoneNumber,
    this.imageResponse,
  });

  ClinicModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    startWorkTime = json['startWorkTime'];
    endWorkTime = json['endWorkTime'];
    currency = json['currency'];
    phoneNumber = json['phoneNumber'];
    imageResponse =
        json['imageResponse'] != null
            ? ImageResponse.fromJson(json['imageResponse'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['address'] = address;
    data['startWorkTime'] = startWorkTime;
    data['endWorkTime'] = endWorkTime;
    data['currency'] = currency;
    data['phoneNumber'] = phoneNumber;
    if (imageResponse != null) {
      data['imageResponse'] = imageResponse!.toJson();
    }
    return data;
  }
}

class ImageResponse {
  int? imageId;
  String? link;

  ImageResponse({this.imageId, this.link});

  ImageResponse.fromJson(Map<String, dynamic> json) {
    imageId = json['imageId'];
    link = json['link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['imageId'] = imageId;
    data['link'] = link;
    return data;
  }
}
