// ignore_for_file: public_member_api_docs, sort_constructors_first
class PaginationModel<T> {
  int? size;
  int? totalPages;
  bool? last;
  bool? first;
  List<T>? content;
  PaginationModel({
    this.size,
    this.totalPages,
    this.last,
    this.first,
    this.content,
  });
  PaginationModel.fromJson(Map<String, dynamic> json, Function fromJsonModel) {
    size = json['size'];
    totalPages = json['totalPages'];
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
