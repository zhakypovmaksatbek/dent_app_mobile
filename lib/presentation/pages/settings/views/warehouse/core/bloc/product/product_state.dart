part of 'product_cubit.dart';

/// Base state class for product operations
sealed class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

/// Initial state
final class ProductInitial extends ProductState {}

/// Loading state during operations
final class ProductLoading extends ProductState {}

/// State when products are successfully loaded
final class ProductLoaded extends ProductState {
  final List<ProductModel> products;

  const ProductLoaded({required this.products});

  @override
  List<Object> get props => [products];
}

/// State when an error occurs
final class ProductError extends ProductState {
  final String message;

  const ProductError({required this.message});

  @override
  List<Object> get props => [message];
}

/// State when a product is successfully created
final class ProductCreated extends ProductState {}

/// State when a product is successfully updated
final class ProductUpdated extends ProductState {}

/// State when a product is successfully deleted
final class ProductDeleted extends ProductState {}
