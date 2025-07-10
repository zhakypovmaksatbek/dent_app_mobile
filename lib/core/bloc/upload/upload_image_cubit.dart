import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/repo/appointment/i_appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/core/utils/image_type.dart';
import 'package:dent_app_mobile/models/work/image_response_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

part 'upload_image_state.dart';

/// Cubit for handling image upload and delete operations
///
/// This cubit manages the state of image operations including:
/// - Uploading images from camera or gallery
/// - Deleting uploaded images
/// - Handling loading states and error scenarios
class UploadImageCubit extends Cubit<UploadImageState> {
  final IAppointmentRepo _appointmentRepo;

  /// Creates an [UploadImageCubit] with optional repository injection
  ///
  /// If no repository is provided, defaults to [AppointmentRepo]
  UploadImageCubit({IAppointmentRepo? appointmentRepo})
    : _appointmentRepo = appointmentRepo ?? AppointmentRepo(),
      super(UploadImageInitial());

  /// Uploads an image with the specified type
  ///
  /// [image] - The image file to upload
  /// [type] - The type/category of the image (e.g., snapshots, avatar, etc.)
  ///
  /// Emits:
  /// - [UploadImageLoading] while uploading
  /// - [UploadImageSuccess] on successful upload
  /// - [UploadImageError] on failure
  Future<void> uploadImage(XFile image, ImageType type) async {
    try {
      emit(UploadImageLoading());
      final imageResponse = await _appointmentRepo.saveImage(image, type);
      emit(UploadImageSuccess(image: imageResponse));
    } on DioException catch (e) {
      emit(UploadImageError(message: FormatUtils.formatErrorMessage(e)));
    } catch (e) {
      emit(UploadImageError(message: e.toString()));
    }
  }

  /// Deletes an image by its ID
  ///
  /// [imageId] - The unique identifier of the image to delete
  ///
  /// Emits:
  /// - [UploadImageLoading] while deleting
  /// - [UploadImageDeleted] on successful deletion
  /// - [UploadImageError] on failure
  Future<void> deleteImage(String imageId) async {
    try {
      emit(UploadImageLoading());
      await _appointmentRepo.deleteImage(imageId);
      emit(UploadImageDeleted(imageId: imageId));
    } on DioException catch (e) {
      emit(UploadImageError(message: FormatUtils.formatErrorMessage(e)));
    } catch (e) {
      emit(UploadImageError(message: e.toString()));
    }
  }

  /// Resets the cubit to its initial state
  ///
  /// Useful for clearing any previous operations or errors
  void reset() {
    emit(UploadImageInitial());
  }

  /// Clears any error state and returns to initial state
  void clearError() {
    if (state is UploadImageError) {
      emit(UploadImageInitial());
    }
  }
}
