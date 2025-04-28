class SaveServiceModel {
  String? name;
  int? price;
  String? description;
  int? warranty;
  String? serviceType;

  SaveServiceModel({
    this.name,
    this.price,
    this.description,
    this.warranty,
    this.serviceType,
  });

  SaveServiceModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
    description = json['description'];
    warranty = json['warranty'];
    serviceType = json['serviceType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    data['description'] = description;
    data['warranty'] = warranty;
    data['serviceType'] = serviceType;
    return data;
  }
}
