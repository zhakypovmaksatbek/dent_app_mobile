/// Servis tipleri için model sınıfı
class ServiceTypeModel {
  final List<String>? serviceTypes;

  ServiceTypeModel({this.serviceTypes});

  /// API'den gelen JSON listesinden model oluşturur
  factory ServiceTypeModel.fromJson(List<dynamic> json) {
    final serviceTypes = json.map((item) => item.toString()).toList();
    return ServiceTypeModel(serviceTypes: serviceTypes);
  }
}
