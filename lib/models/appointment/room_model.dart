import 'package:equatable/equatable.dart';

class RoomModel extends Equatable {
  int? id;
  String? name;

  RoomModel({this.id, this.name});

  RoomModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomModel && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'RoomModel(id: $id, name: $name)';

  @override
  List<Object?> get props => [id, name];
}
