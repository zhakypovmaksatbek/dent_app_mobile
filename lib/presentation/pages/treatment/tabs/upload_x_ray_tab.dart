import 'package:dent_app_mobile/core/bloc/upload/upload_image_cubit.dart';
import 'package:dent_app_mobile/core/utils/image_type.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/image/cashed_images.dart';
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class UploadXRayTab extends StatefulWidget {
  const UploadXRayTab({super.key});

  @override
  State<UploadXRayTab> createState() => _UploadXRayTabState();
}

class _UploadXRayTabState extends State<UploadXRayTab>
    with AutomaticKeepAliveClientMixin {
  final ImagePicker _picker = ImagePicker();
  String? _uploadedImage;
  String? _imageId; // Track image ID for professional deletion

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<UploadImageCubit, UploadImageState>(
      listener: (context, state) {
        if (state is UploadImageSuccess) {
          if (state.image.link != null) {
            setState(() {
              _uploadedImage = state.image.link!;
              _imageId = state.image.imageId?.toString(); // Store image ID
            });
            AppSnackBar.showSuccessSnackBar(
              context,
              LocaleKeys.alerts_operation_successful.tr(),
            );
          }
        } else if (state is UploadImageDeleted) {
          setState(() {
            _uploadedImage = null;
            _imageId = null;
          });
          AppSnackBar.showSuccessSnackBar(context, "X-Ray başarıyla silindi");
        } else if (state is UploadImageError) {
          AppSnackBar.showErrorSnackBar(context, state.message);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simple header
            AppText(title: "X-Ray Yükle", textType: TextType.title),
            const SizedBox(height: 16),

            // Upload area or uploaded image
            _uploadedImage != null ? _buildUploadedImage() : _buildUploadArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return BlocBuilder<UploadImageCubit, UploadImageState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!, width: 2),
          ),
          child: Column(
            children: [
              if (state is UploadImageLoading)
                const CircularProgressIndicator()
              else ...[
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 48,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 12),
                AppText(title: "X-Ray resmi yükleyin", textType: TextType.body),
                const SizedBox(height: 8),
                AppText(
                  title: "JPG, PNG formatları desteklenir",
                  textType: TextType.subtitle,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: const Text("Kamera"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConstants.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library, size: 18),
                        label: const Text("Galeri"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ColorConstants.primary,
                          side: BorderSide(color: ColorConstants.primary),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadedImage() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: CashedImages(imageUrl: _uploadedImage!, fit: BoxFit.cover),
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: AppText(
                    title: "X-Ray yüklendi",
                    textType: TextType.body,
                  ),
                ),
                IconButton(
                  onPressed: () => _showImagePreview(_uploadedImage!),
                  icon: const Icon(Icons.visibility, size: 20),
                  tooltip: "Görüntüle",
                ),
                IconButton(
                  onPressed: _showChangeDialog,
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: "Değiştir",
                ),
                IconButton(
                  onPressed: _removeImage,
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  tooltip: "Sil",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              AppText(title: "Resmi Değiştir", textType: TextType.title),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Kamera"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Galeri"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorConstants.primary,
                        side: BorderSide(color: ColorConstants.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        if (!mounted) return;
        context.read<UploadImageCubit>().uploadImage(
          pickedFile,
          ImageType.snapshots,
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showErrorSnackBar(
        context,
        LocaleKeys.errors_something_went_wrong.tr(),
      );
    }
  }

  void _removeImage() {
    if (_imageId != null) {
      // Professional deletion via API when image ID is available
      context.read<UploadImageCubit>().deleteImage(_imageId!);
    } else {
      // Fallback to simple state removal for local-only changes
      setState(() {
        _uploadedImage = null;
        _imageId = null;
      });
    }
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CashedImages(imageUrl: imageUrl, fit: BoxFit.contain),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
