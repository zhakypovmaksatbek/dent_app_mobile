import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/tooth/tooth_state_model.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/data/teeth_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// A professional modal bottom sheet widget for displaying tooth diagnosis options
class ToothDiagnosisModal extends StatelessWidget {
  final List<String> selectedTeeth;
  final Function(ToothStateModel)? onDiagnosisSelected;

  const ToothDiagnosisModal({
    super.key,
    required this.selectedTeeth,
    this.onDiagnosisSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.7,
        maxChildSize: 0.95,
        snap: true,
        expand: false,
        snapSizes: const [0.7, 0.95],
        builder: (context, scrollController) {
          return NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              // Handle scroll conflicts
              return false;
            },
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: Column(
                children: [
                  // Professional Handle Bar Area
                  _buildHandleBar(theme),

                  // Enhanced Header
                  _buildProfessionalHeader(theme, context),

                  // Main Content with better scroll handling
                  Expanded(
                    child:
                        selectedTeeth.isEmpty
                            ? _buildEmptyState(theme)
                            : _buildScrollableContent(theme, scrollController),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds a professional handle bar
  Widget _buildHandleBar(ThemeData theme) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the professional header section
  Widget _buildProfessionalHeader(ThemeData theme, BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withValues(alpha: 0.03),
            theme.primaryColor.withValues(alpha: 0.06),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Professional Icon Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withValues(alpha: 0.1),
                  theme.primaryColor.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.medical_services_rounded,
              color: theme.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 20),

          // Header Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.routes_diagnosis.tr(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                if (selectedTeeth.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.primaryColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.straighten_rounded,
                          size: 16,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${LocaleKeys.general_tooth.tr()}: ${selectedTeeth.join(", ")}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Close Button
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () => Navigator.pop(context),
              splashColor: theme.primaryColor.withValues(alpha: 0.1),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.close_rounded,
                  color: theme.textTheme.bodyLarge?.color?.withValues(
                    alpha: 0.7,
                  ),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the scrollable content with better scroll handling
  Widget _buildScrollableContent(
    ThemeData theme,
    ScrollController scrollController,
  ) {
    return CustomScrollView(
      controller: scrollController,
      physics: const ClampingScrollPhysics(),
      slivers: [
        // Section Title
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Diagnosis Type',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Enhanced Grid
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final tooth = TeethData.teeth[index];
              return _buildEnhancedDiagnosisCard(theme, tooth);
            }, childCount: TeethData.teeth.length),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisExtent: 95,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
          ),
        ),

        // Bottom padding for better UX
        const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
      ],
    );
  }

  /// Builds an enhanced diagnosis card
  Widget _buildEnhancedDiagnosisCard(ThemeData theme, ToothStateModel tooth) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      shadowColor: tooth.color.withValues(alpha: 0.2),
      child: InkWell(
        onTap: () {
          // Add haptic feedback
          // HapticFeedback.lightImpact();
          onDiagnosisSelected?.call(tooth);
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: tooth.color.withValues(alpha: 0.1),
        highlightColor: tooth.color.withValues(alpha: 0.05),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tooth.color.withValues(alpha: 0.05),
                tooth.color.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: tooth.color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Enhanced Color Indicator
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: tooth.color,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: tooth.color.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    tooth.title,
                    style: TextStyle(
                      color: _getContrastColor(tooth.color),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Enhanced Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tooth.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tooth.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.8,
                        ),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the empty state when no teeth are selected
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                Icons.info_outline_rounded,
                size: 80,
                color: theme.primaryColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Teeth Selected',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.headlineSmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Please select teeth from the diagram\nto view available diagnosis options',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Gets contrasting color for text on colored background
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}
