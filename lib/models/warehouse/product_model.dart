class ProductDataModel {
  int? quantity;
  double? totalPrice;
  List<ProductModel>? itemResponses;

  ProductDataModel({this.quantity, this.totalPrice, this.itemResponses});

  ProductDataModel.fromJson(Map<String, dynamic> json) {
    quantity = json['quantity'];
    totalPrice = json['totalPrice']?.toDouble();
    if (json['itemResponses'] != null) {
      itemResponses = <ProductModel>[];
      json['itemResponses'].forEach((v) {
        itemResponses!.add(ProductModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['quantity'] = quantity;
    data['totalPrice'] = totalPrice;
    if (itemResponses != null) {
      data['itemResponses'] = itemResponses!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProductModel {
  int? id;
  String? name;
  double? price;
  int? quantity;
  double? totalPrice;

  ProductModel({
    this.id,
    this.name,
    this.price,
    this.quantity,
    this.totalPrice,
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price']?.toDouble();
    quantity = json['quantity'];
    totalPrice = json['totalPrice']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['quantity'] = quantity;
    data['totalPrice'] = totalPrice;
    return data;
  }
}
