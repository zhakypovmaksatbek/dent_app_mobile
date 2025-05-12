class ToothModel {
  int? toothNumber;
  MainModel? main;
  MainModel? jow;
  InnerToothResponse? innerToothResponse;

  ToothModel({this.toothNumber, this.main, this.jow, this.innerToothResponse});

  ToothModel.fromJson(Map<String, dynamic> json) {
    toothNumber = json['toothNumber'];
    main = json['main'] != null ? MainModel.fromJson(json['main']) : null;
    jow = json['jow'] != null ? MainModel.fromJson(json['jow']) : null;
    innerToothResponse =
        json['innerToothResponse'] != null
            ? InnerToothResponse.fromJson(json['innerToothResponse'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['toothNumber'] = toothNumber;
    if (main != null) {
      data['main'] = main!.toJson();
    }
    if (jow != null) {
      data['jow'] = jow!.toJson();
    }
    if (innerToothResponse != null) {
      data['innerToothResponse'] = innerToothResponse!.toJson();
    }
    return data;
  }
}

class MainModel {
  String? name;
  String? color;

  MainModel({this.name, this.color});

  MainModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['color'] = color;
    return data;
  }
}

class InnerToothResponse {
  MainModel? right;
  MainModel? left;
  MainModel? top;
  MainModel? bottom;
  MainModel? centerRight;
  MainModel? centerLeft;

  InnerToothResponse({
    this.right,
    this.left,
    this.top,
    this.bottom,
    this.centerRight,
    this.centerLeft,
  });

  InnerToothResponse.fromJson(Map<String, dynamic> json) {
    right = json['right'] != null ? MainModel.fromJson(json['right']) : null;
    left = json['left'] != null ? MainModel.fromJson(json['left']) : null;
    top = json['top'] != null ? MainModel.fromJson(json['top']) : null;
    bottom = json['bottom'] != null ? MainModel.fromJson(json['bottom']) : null;
    centerRight =
        json['centerRight'] != null
            ? MainModel.fromJson(json['centerRight'])
            : null;
    centerLeft =
        json['centerLeft'] != null
            ? MainModel.fromJson(json['centerLeft'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (right != null) {
      data['right'] = right!.toJson();
    }
    if (left != null) {
      data['left'] = left!.toJson();
    }
    if (top != null) {
      data['top'] = top!.toJson();
    }
    if (bottom != null) {
      data['bottom'] = bottom!.toJson();
    }
    if (centerRight != null) {
      data['centerRight'] = centerRight!.toJson();
    }
    if (centerLeft != null) {
      data['centerLeft'] = centerLeft!.toJson();
    }
    return data;
  }
}
