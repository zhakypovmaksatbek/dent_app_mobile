import 'package:dent_app_mobile/core/repo/warehouse/warehouse_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/warehouse/product_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'product_state.dart';

/// A Cubit for managing product-related operations and state
class ProductCubit extends Cubit<ProductState> {
  final IWarehouseRepo _warehouseRepo;

  /// Constructor with dependency injection for the repository
  ProductCubit({IWarehouseRepo? warehouseRepo})
    : _warehouseRepo = warehouseRepo ?? WarehouseRepo(),
      super(ProductInitial());

  /// Fetches all products from the repository
  Future<void> getProducts({String? search}) async {
    emit(ProductLoading());

    try {
      final products = await _warehouseRepo.getProducts(search: search);

      if (products.itemResponses == null || products.itemResponses!.isEmpty) {
        emit(const ProductLoaded(products: []));
      } else {
        emit(ProductLoaded(products: products.itemResponses!));
      }
    } on DioException catch (e) {
      emit(ProductError(message: _formatErrorMessage(e)));
    }
  }

  /// Creates a new product
  Future<void> createProduct(ProductModel product) async {
    emit(ProductLoading());

    try {
      await _warehouseRepo.createProduct(product);
      emit(ProductCreated());
      // Refresh products list after creation
      await getProducts();
    } on DioException catch (e) {
      emit(ProductError(message: _formatErrorMessage(e)));
    }
  }

  /// Updates an existing product
  Future<void> updateProduct(ProductModel product) async {
    emit(ProductLoading());

    try {
      if (product.id == null) {
        emit(const ProductError(message: 'Product ID is required for update'));
        return;
      }

      await _warehouseRepo.updateProduct(product.id!, product);
      emit(ProductUpdated());
      // Refresh products list after update
      await getProducts();
    } on DioException catch (e) {
      emit(ProductError(message: _formatErrorMessage(e)));
    }
  }

  /// Deletes a product by ID
  Future<void> deleteProduct(int id) async {
    emit(ProductLoading());

    try {
      await _warehouseRepo.deleteProduct(id);
      emit(ProductDeleted());
      // Refresh products list after deletion
      await getProducts();
    } on DioException catch (e) {
      emit(ProductError(message: _formatErrorMessage(e)));
    }
  }

  /// Helper method to format error messages
  String _formatErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return FormatUtils.formatErrorMessage(error);
  }
}
