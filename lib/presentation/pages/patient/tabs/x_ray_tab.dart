import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/diagnosis/x_ray_model.dart';
import 'package:dent_app_mobile/presentation/constants/asset_constants.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/get_x_ray/get_x_ray_cubit.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:dent_app_mobile/presentation/widgets/empty/empty_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/image/cashed_images.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';

class _XRayConstants {
  static const double imageSize = 80.0;
  static const double imageRadius = 12.0;
  static const double cardRadius = 16.0;
  static const double contentSpacing = 12.0;

  static const EdgeInsets listPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardContentPadding = EdgeInsets.all(16.0);
}

extension DateFormatting on String? {
  String get formattedDate {
    if (this == null || this!.isEmpty) return '';
    try {
      final date = DateTime.parse(this!);
      return DateFormat('dd.MM.yyyy HH:mm').format(date);
    } catch (_) {
      return this ?? '';
    }
  }
}

class XRayTab extends StatefulWidget {
  final int patientId;

  const XRayTab({super.key, required this.patientId});

  @override
  State<XRayTab> createState() => _XRayTabState();
}

class _XRayTabState extends State<XRayTab> with AutomaticKeepAliveClientMixin {
  late final GetXRayCubit _cubit = GetXRayCubit();

  @override
  void initState() {
    super.initState();
    _loadXRayImages();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _loadXRayImages() => _cubit.getPatientXRay(widget.patientId);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<GetXRayCubit, GetXRayState>(
      bloc: _cubit,
      builder:
          (context, state) => switch (state) {
            GetXRayLoading() => const _LoadingView(),
            GetXRayError() => _ErrorView(onRetry: _loadXRayImages),
            GetXRayLoaded(:final xRay) =>
              xRay.isEmpty
                  ? const _EmptyView()
                  : _XRayListView(items: xRay, onRefresh: _loadXRayImages),
            _ => const SizedBox.shrink(),
          },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: LoadingWidget());
  }
}

// Error State Widget
class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: _XRayConstants.listPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            AppText(
              title: LocaleKeys.notifications_error.tr(),
              textType: TextType.title,
              color: theme.colorScheme.error,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

// Empty State Widget
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const EmptyWidget(
      icon: Icons.image_not_supported_outlined,
      title: 'Рентген снимки не найдены',
    );
  }
}

// Main List View
class _XRayListView extends StatelessWidget {
  final List<XRayModel> items;
  final VoidCallback onRefresh;

  const _XRayListView({required this.items, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: _XRayConstants.listPadding,
        itemCount: items.length,
        separatorBuilder:
            (_, __) => const SizedBox(height: _XRayConstants.contentSpacing),
        itemBuilder:
            (context, index) => _XRayListItem(
              item: items[index],
              index: index,
              allItems: items,
            ),
      ),
    );
  }
}

// Individual X-Ray Item
class _XRayListItem extends StatefulWidget {
  final XRayModel item;
  final int index;
  final List<XRayModel> allItems;

  const _XRayListItem({
    required this.item,
    required this.index,
    required this.allItems,
  });

  @override
  State<_XRayListItem> createState() => _XRayListItemState();
}

class _XRayListItemState extends State<_XRayListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + (widget.index * 100)),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _XRayCard(
          item: widget.item,
          index: widget.index,
          allItems: widget.allItems,
        ),
      ),
    );
  }
}

// Main Card Widget
class _XRayCard extends StatelessWidget {
  final XRayModel item;
  final int index;
  final List<XRayModel> allItems;

  const _XRayCard({
    required this.item,
    required this.index,
    required this.allItems,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCardDecoration(
      child: InkWell(
        onTap: () => _showFullScreenDialog(context),
        borderRadius: BorderRadius.circular(_XRayConstants.cardRadius),
        child: Padding(
          padding: _XRayConstants.cardContentPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImageSection(item: item),
              const SizedBox(width: _XRayConstants.contentSpacing),
              Expanded(child: _ContentSection(item: item)),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => _FullScreenImageDialog(items: allItems, initialIndex: index),
    );
  }
}

// Image Section
class _ImageSection extends StatelessWidget {
  final XRayModel item;

  const _ImageSection({required this.item});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _ImageContainer(imageUrl: item.imageLink),
        if (item.toothToShow?.isNotEmpty == true)
          Positioned(
            bottom: 4,
            right: 4,
            child: _ToothBadge(toothNumber: item.toothToShow!),
          ),
      ],
    );
  }
}

// Image Container
class _ImageContainer extends StatelessWidget {
  final String? imageUrl;

  const _ImageContainer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: _XRayConstants.imageSize,
      height: _XRayConstants.imageSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_XRayConstants.imageRadius),
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_XRayConstants.imageRadius),
        child: CashedImages(imageUrl: imageUrl ?? '', fit: BoxFit.cover),
      ),
    );
  }
}

// Tooth Badge
class _ToothBadge extends StatelessWidget {
  final String toothNumber;

  const _ToothBadge({required this.toothNumber});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AssetConstants.toothLogo.png,
            width: 12,
            height: 12,
            color: AppColors.white,
          ),
          const SizedBox(width: 2),
          AppText(
            title: toothNumber,
            textType: TextType.subtitle,
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

// Content Section
class _ContentSection extends StatelessWidget {
  final XRayModel item;

  const _ContentSection({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DateInfo(date: item.imageCreateAt),
        if (item.appointmentCreateAt != null) ...[
          const SizedBox(height: 8),
          _AppointmentInfo(date: item.appointmentCreateAt),
        ],
        const SizedBox(height: 8),
        _DescriptionInfo(description: item.imageDescription),
      ],
    );
  }
}

// Date Information
class _DateInfo extends StatelessWidget {
  final String? date;

  const _DateInfo({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: AppText(
            title: date.formattedDate,
            textType: TextType.description,
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Appointment Information
class _AppointmentInfo extends StatelessWidget {
  final String? date;

  const _AppointmentInfo({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.event_note_outlined,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: AppText(
            title:
                '${LocaleKeys.report_appointment.tr()}: ${date.formattedDate}',
            textType: TextType.description,
            color: theme.colorScheme.onSurfaceVariant,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Description Information
class _DescriptionInfo extends StatelessWidget {
  final String? description;

  const _DescriptionInfo({required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDescription = description?.isNotEmpty == true;

    if (hasDescription) {
      return AppText(
        title: description!,
        textType: TextType.body,
        color: theme.colorScheme.onSurface,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    return AppText(
      title: 'Нет описания',
      textType: TextType.description,
      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
    );
  }
}

// Full Screen Image Dialog with PageView Navigation
class _FullScreenImageDialog extends StatefulWidget {
  final List<XRayModel> items;
  final int initialIndex;

  const _FullScreenImageDialog({
    required this.items,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageDialog> createState() => _FullScreenImageDialogState();
}

class _FullScreenImageDialogState extends State<_FullScreenImageDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          // PageView for swiping between images
          PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return _FullScreenImage(imageUrl: item.imageLink);
            },
          ),
          // Header with close button and page indicator
          _HeaderSection(
            currentIndex: _currentIndex,
            totalItems: widget.items.length,
            currentItem: widget.items[_currentIndex],
          ),
          // Bottom description if available
          if (widget.items[_currentIndex].imageDescription?.isNotEmpty == true)
            _BottomDescription(
              description: widget.items[_currentIndex].imageDescription!,
            ),
        ],
      ),
    );
  }
}

// Full Screen Image
class _FullScreenImage extends StatelessWidget {
  final String? imageUrl;

  const _FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return PhotoView(
      imageProvider: NetworkImage(imageUrl ?? ''),
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      loadingBuilder:
          (_, __) => const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
      errorBuilder:
          (_, __, ___) => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.white70,
                ),
                SizedBox(height: 16),
                Text(
                  'Ошибка загрузки изображения',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
    );
  }
}

// Header Section with Close Button and Page Indicator
class _HeaderSection extends StatelessWidget {
  final int currentIndex;
  final int totalItems;
  final XRayModel currentItem;

  const _HeaderSection({
    required this.currentIndex,
    required this.totalItems,
    required this.currentItem,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            // Close Button
            Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 16),
            // Image Info and Counter
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page indicator
                  Text(
                    '${currentIndex + 1} / $totalItems',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Image title
                  Text(
                    'Рентген снимок${currentItem.toothToShow?.isNotEmpty == true ? ' - Зуб ${currentItem.toothToShow}' : ''}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  // Date
                  Text(
                    currentItem.imageCreateAt.formattedDate,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bottom Description
class _BottomDescription extends StatelessWidget {
  final String description;

  const _BottomDescription({required this.description});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AppText(
          title: description,
          textType: TextType.body,
          color: Colors.white,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
