class ImageResponseModel {
  int? imageId;
  String? link;

  ImageResponseModel({this.imageId, this.link});

  ImageResponseModel.fromJson(Map<String, dynamic> json) {
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
