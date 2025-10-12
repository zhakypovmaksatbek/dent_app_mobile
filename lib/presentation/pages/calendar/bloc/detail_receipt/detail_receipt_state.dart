part of 'detail_receipt_cubit.dart';

sealed class DetailReceiptState extends Equatable {
  const DetailReceiptState();

  @override
  List<Object> get props => [];
}

final class DetailReceiptInitial extends DetailReceiptState {}

final class DetailReceiptLoading extends DetailReceiptState {}

final class DetailReceiptSuccess extends DetailReceiptState {
  final DetailReceiptModel detailReceipt;

  const DetailReceiptSuccess({required this.detailReceipt});

  @override
  List<Object> get props => [detailReceipt];
}

final class DetailReceiptError extends DetailReceiptState {
  final String message;

  const DetailReceiptError({required this.message});

  @override
  List<Object> get props => [message];
}
