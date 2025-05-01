// ignore_for_file: public_member_api_docs, sort_constructors_first
class PaginationModel<T> {
  int? size;
  int? totalPages;
  int? totalElements;
  bool? last;
  bool? first;
  List<T>? content;
  PaginationModel({
    this.size,
    this.totalPages,
    this.totalElements,
    this.last,
    this.first,
    this.content,
  });
  PaginationModel.fromJson(Map<String, dynamic> json, Function fromJsonModel) {
    size = json['size'];
    totalPages = json['totalPages'];
    totalElements = json['totalElements'];
    last = json['last'];
    first = json['first'];
    if (json['content'] != null) {
      content = <T>[];
      json['content'].forEach((v) {
        content!.add(fromJsonModel(v));
      });
    }
  }
}
