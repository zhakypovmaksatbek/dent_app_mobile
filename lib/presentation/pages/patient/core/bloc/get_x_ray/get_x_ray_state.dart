part of 'get_x_ray_cubit.dart';

sealed class GetXRayState extends Equatable {
  const GetXRayState();

  @override
  List<Object> get props => [];
}

final class GetXRayInitial extends GetXRayState {}

final class GetXRayLoading extends GetXRayState {}

final class GetXRayLoaded extends GetXRayState {
  final List<XRayModel> xRay;

  const GetXRayLoaded({required this.xRay});
}

final class GetXRayError extends GetXRayState {
  final String message;

  const GetXRayError({required this.message});
}
