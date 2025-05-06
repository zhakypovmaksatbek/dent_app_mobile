class CreateDocumentModel {
  String? supplier;
  String? description;
  int? totalPrice;
  List<ItemAddQuantityRequests>? itemAddQuantityRequests;

  CreateDocumentModel({
    this.supplier,
    this.description,
    this.totalPrice,
    this.itemAddQuantityRequests,
  });

  CreateDocumentModel.fromJson(Map<String, dynamic> json) {
    supplier = json['supplier'];
    description = json['description'];
    totalPrice = json['totalPrice'];
    if (json['itemAddQuantityRequests'] != null) {
      itemAddQuantityRequests = <ItemAddQuantityRequests>[];
      json['itemAddQuantityRequests'].forEach((v) {
        itemAddQuantityRequests!.add(ItemAddQuantityRequests.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['supplier'] = supplier;
    data['description'] = description;
    data['totalPrice'] = totalPrice;
    if (itemAddQuantityRequests != null) {
      data['itemAddQuantityRequests'] =
          itemAddQuantityRequests!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ItemAddQuantityRequests {
  int? itemId;
  int? price;
  int? quantity;

  ItemAddQuantityRequests({this.itemId, this.price, this.quantity});

  ItemAddQuantityRequests.fromJson(Map<String, dynamic> json) {
    itemId = json['itemId'];
    price = json['price'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['itemId'] = itemId;
    data['price'] = price;
    data['quantity'] = quantity;
    return data;
  }
}
