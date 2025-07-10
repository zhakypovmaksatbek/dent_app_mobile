part of 'upload_image_cubit.dart';

sealed class UploadImageState extends Equatable {
  const UploadImageState();

  @override
  List<Object> get props => [];
}

final class UploadImageInitial extends UploadImageState {}

final class UploadImageLoading extends UploadImageState {}

final class UploadImageSuccess extends UploadImageState {
  final ImageResponseModel image;

  const UploadImageSuccess({required this.image});

  @override
  List<Object> get props => [image];
}

final class UploadImageDeleted extends UploadImageState {
  final String imageId;

  const UploadImageDeleted({required this.imageId});

  @override
  List<Object> get props => [imageId];
}

final class UploadImageError extends UploadImageState {
  final String message;

  const UploadImageError({required this.message});

  @override
  List<Object> get props => [message];
}
