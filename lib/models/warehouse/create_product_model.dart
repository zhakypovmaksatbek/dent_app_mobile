class CreateProductModel {
  String? name;
  int? price;

  CreateProductModel({this.name, this.price});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    return data;
  }
}
