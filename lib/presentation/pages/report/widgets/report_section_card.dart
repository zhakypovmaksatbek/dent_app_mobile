import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:flutter/material.dart';

class ReportSectionCard extends StatelessWidget {
  final String title;
  final Map<String, String> data;
  final Color cardColor;

  const ReportSectionCard({
    super.key,
    required this.title,
    required this.data,
    this.cardColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...data.entries.map(
              (entry) => _buildDataRow(context, entry.key, entry.value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: ColorConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
