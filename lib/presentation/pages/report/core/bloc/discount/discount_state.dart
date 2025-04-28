part of 'discount_cubit.dart';

sealed class DiscountState extends Equatable {
  const DiscountState();

  @override
  List<Object> get props => [];
}

final class DiscountInitial extends DiscountState {}

final class DiscountLoading extends DiscountState {}

final class DiscountLoaded extends DiscountState {
  final PaymentReportDataModel discountReport;
  const DiscountLoaded({required this.discountReport});
}

final class DiscountError extends DiscountState {
  final String message;
  const DiscountError({required this.message});
}
