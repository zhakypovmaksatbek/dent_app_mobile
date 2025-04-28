class ServiceModel {
  String? serviceType;
  List<ServiceItem>? serviceItem;

  ServiceModel({this.serviceType, this.serviceItem});

  ServiceModel.fromJson(Map<String, dynamic> json) {
    serviceType = json['serviceType'];
    if (json['serviceResponses'] != null) {
      serviceItem = <ServiceItem>[];
      json['serviceResponses'].forEach((v) {
        serviceItem!.add(ServiceItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['serviceType'] = serviceType;
    if (serviceItem != null) {
      data['serviceResponses'] = serviceItem!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceItem {
  int? id;
  String? name;
  double? price;
  String? createdAt;

  ServiceItem({this.id, this.name, this.price, this.createdAt});

  ServiceItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price']?.toDouble();
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['createdAt'] = createdAt;
    return data;
  }
}
