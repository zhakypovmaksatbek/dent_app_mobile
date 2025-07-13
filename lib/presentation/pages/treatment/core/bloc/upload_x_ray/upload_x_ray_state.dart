part of 'upload_x_ray_cubit.dart';

sealed class UploadXRayState extends Equatable {
  const UploadXRayState();

  @override
  List<Object> get props => [];
}

final class UploadXRayInitial extends UploadXRayState {}

final class UploadXRayLoading extends UploadXRayState {}

final class UploadXRaySuccess extends UploadXRayState {}

final class UploadXRayError extends UploadXRayState {
  final String message;

  const UploadXRayError({required this.message});
}
