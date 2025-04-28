part of 'get_service_item_cubit.dart';

sealed class GetServiceItemState extends Equatable {
  const GetServiceItemState();

  @override
  List<Object> get props => [];
}

final class GetServiceItemInitial extends GetServiceItemState {}

final class GetServiceItemLoading extends GetServiceItemState {}

final class GetServiceItemLoaded extends GetServiceItemState {
  final List<ServiceItem> serviceItems;
  const GetServiceItemLoaded({required this.serviceItems});
}

final class GetServiceItemError extends GetServiceItemState {
  final String message;
  const GetServiceItemError({required this.message});
}
