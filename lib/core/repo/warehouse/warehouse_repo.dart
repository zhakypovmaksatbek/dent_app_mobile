import 'package:dent_app_mobile/core/service/dio_settings.dart';
import 'package:dent_app_mobile/models/warehouse/create_document_model.dart';
import 'package:dent_app_mobile/models/warehouse/document_model.dart';
import 'package:dent_app_mobile/models/warehouse/product_model.dart';

abstract class IWarehouseRepo {
  Future<ProductDataModel> getProducts({String? search});
  Future<void> createProduct(ProductModel product);
  Future<void> updateProduct(int id, ProductModel product);
  Future<void> deleteProduct(int id);
  Future<void> createDocument(CreateDocumentModel document);
  Future<void> updateDocument(int id, CreateDocumentModel document);
  Future<void> deleteDocument(int id);
  Future<List<DocumentModel>> getDocuments({String? search});
}

class WarehouseRepo extends IWarehouseRepo {
  final dio = DioService();
  @override
  Future<ProductDataModel> getProducts({String? search}) async {
    final response = await dio.get(
      'api/items',
      queryParameters:
          search != null && search.isNotEmpty ? {'search': search} : null,
    );
    return ProductDataModel.fromJson(response.data);
  }

  @override
  Future<void> createProduct(ProductModel product) async {
    await dio.post('api/items', data: product.toJson());
  }

  @override
  Future<void> deleteProduct(int id) async {
    await dio.delete('api/items/$id');
  }

  @override
  Future<void> updateProduct(int id, ProductModel product) async {
    await dio.put('api/items/$id', data: product.toJson());
  }

  @override
  Future<void> createDocument(CreateDocumentModel document) async {
    await dio.post('api/documents', data: document.toJson());
  }

  @override
  Future<void> deleteDocument(int id) async {
    await dio.delete('api/documents/$id');
  }

  @override
  Future<List<DocumentModel>> getDocuments({String? search}) async {
    final response = await dio.get(
      'api/documents',
      queryParameters:
          search != null && search.isNotEmpty ? {'search': search} : null,
    );
    if (response.data is List) {
      return (response.data as List)
          .map((e) => DocumentModel.fromJson(e))
          .toList();
    }
    return [];
  }

  @override
  Future<void> updateDocument(int id, CreateDocumentModel document) async {
    await dio.put('api/documents/$id', data: document.toJson());
  }
}
