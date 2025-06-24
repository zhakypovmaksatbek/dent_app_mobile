import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/tooth/tooth_state_model.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/data/teeth_data.dart';
import 'package:dent_app_mobile/presentation/widgets/buttons/def_elevated_button.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

part 'tooth_diagnosis_details_modal.dart';

/// A professional modal bottom sheet widget for displaying tooth diagnosis options
class ToothDiagnosisModal extends StatefulWidget {
  final ValueChanged<ToothStateModel> onDiagnosisSelected;
  final ToothStateModel? selectedDiagnosis;

  const ToothDiagnosisModal({
    super.key,
    required this.onDiagnosisSelected,
    this.selectedDiagnosis,
  });

  @override
  State<ToothDiagnosisModal> createState() => _ToothDiagnosisModalState();
}

class _ToothDiagnosisModalState extends State<ToothDiagnosisModal> {
  late ScrollController _scrollController;
  ToothStateModel? _selectedDiagnosis;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _selectedDiagnosis = widget.selectedDiagnosis;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          _HandleBar(theme: theme),
          _Header(theme: theme, onClose: () => Navigator.pop(context)),
          Expanded(
            child: _DiagnosisContent(
              theme: theme,
              scrollController: _scrollController,
              selectedDiagnosis: _selectedDiagnosis,
              onDiagnosisSelected: (diagnosis) {
                setState(() {
                  _selectedDiagnosis = diagnosis;
                });
                widget.onDiagnosisSelected(diagnosis);
              },
            ),
          ),
          if (_selectedDiagnosis != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: DefElevatedButton(
                title: LocaleKeys.buttons_continue.tr(),
                onPressed: () {},
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HandleBar extends StatelessWidget {
  final ThemeData theme;

  const _HandleBar({required this.theme});

  @override
  Widget build(BuildContext context) {
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
}

class _Header extends StatelessWidget {
  final ThemeData theme;
  final VoidCallback onClose;

  const _Header({required this.theme, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildIconContainer(),
          const SizedBox(width: 12),
          Expanded(child: _buildTitleSection()),
          _buildCloseButton(),
        ],
      ),
    );
  }

  Widget _buildIconContainer() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withValues(alpha: 0.12),
            theme.primaryColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.medical_services_outlined,
        color: theme.primaryColor,
        size: 20,
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.routes_diagnosis.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.textTheme.titleLarge?.color,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Seçim yapın ve devam edin',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildCloseButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onClose,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.close_rounded,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _DiagnosisContent extends StatelessWidget {
  final ThemeData theme;
  final ScrollController scrollController;
  final ToothStateModel? selectedDiagnosis;
  final ValueChanged<ToothStateModel> onDiagnosisSelected;

  const _DiagnosisContent({
    required this.theme,
    required this.scrollController,
    required this.selectedDiagnosis,
    required this.onDiagnosisSelected,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(child: _buildSectionTitle()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _DiagnosisCard(
                category: TeethDiagnosisData.categories[index],
                selectedDiagnosis: selectedDiagnosis,
                onTap:
                    (category) => _handleDiagnosisSelection(
                      context,
                      category,
                      onDiagnosisSelected,
                    ),
              ),
              childCount: TeethDiagnosisData.categories.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      children: [
        Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          LocaleKeys.diagnosis_select_type.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _handleDiagnosisSelection(
    BuildContext context,
    ToothDiagnosisCategory category,
    ValueChanged<ToothStateModel> onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _DiagnosisDetailsModal(
            category: category,
            onSelect: (diagnosis) {
              onSelect(diagnosis);
            },
          ),
    );
  }
}

class _DiagnosisCard extends StatelessWidget {
  final ToothDiagnosisCategory category;
  final ToothStateModel? selectedDiagnosis;
  final ValueChanged<ToothDiagnosisCategory> onTap;

  const _DiagnosisCard({
    required this.category,
    required this.onTap,
    this.selectedDiagnosis,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected =
        selectedDiagnosis != null &&
        category.diagnoses.contains(selectedDiagnosis);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(category),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Colors.green.withValues(alpha: 0.15)
                    : category.color.withValues(alpha: 0.08),
            border: Border.all(
              color:
                  isSelected
                      ? Colors.green
                      : category.color.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderRow(theme, isSelected),
              const SizedBox(height: 8),
              Expanded(child: _buildContentSection(theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(ThemeData theme, bool isSelected) {
    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green : category.color,
              borderRadius: BorderRadius.circular(5),
            ),
            child: AppText(
              title: category.title,
              textType: TextType.subtitle,
              color: _getContrastColor(
                isSelected ? Colors.green : category.color,
              ),

              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (category.diagnoses.length > 1) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: AppText(
              title: category.diagnoses.length.toString(),
              textType: TextType.subtitle,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
        if (isSelected) ...[
          const Spacer(),
          Icon(Icons.check_circle, color: Colors.green, size: 14),
        ],
      ],
    );
  }

  Widget _buildContentSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            category.diagnoses.first.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'ICD: ${category.diagnoses.first.icdCode}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            fontSize: 10,
            height: 1.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;
  }
}
