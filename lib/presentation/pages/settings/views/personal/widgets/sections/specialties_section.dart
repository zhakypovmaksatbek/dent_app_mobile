import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/users/specialty_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_specialty/personal_specialty_cubit.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpecialtiesSection extends StatefulWidget {
  const SpecialtiesSection({super.key, required this.userId});

  final int userId;

  @override
  State<SpecialtiesSection> createState() => _SpecialtiesSectionState();
}

class _SpecialtiesSectionState extends State<SpecialtiesSection> {
  List<SpecialtyModel> userSpecialist = [];
  List<SpecialtyModel> anotherSpecialist = [];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PersonalSpecialtyCubit, PersonalSpecialtyState>(
      listener: (context, state) {
        if (state is PersonalSpecialtyLoaded) {
          userSpecialist = state.userSpecialties;
          anotherSpecialist = state.specialties;
        }
      },
      builder: (context, state) {
        if (state is PersonalSpecialtyError) {
          return _buildErrorSection(state.message);
        } else {
          return _buildSpecialtiesContent();
        }
      },
    );
  }

  Widget _buildErrorSection(String message) {
    final theme = Theme.of(context);

    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  LocaleKeys.general_specialties.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Error loading specialties: $message",
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<PersonalSpecialtyCubit>().getSpecialties(
                        userId: widget.userId,
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(LocaleKeys.buttons_retry.tr()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtiesContent() {
    final theme = Theme.of(context);

    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.medical_services_outlined,
                        color: Colors.teal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      LocaleKeys.general_specialties.tr(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (_userCanEditSpecialties())
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {
                      _showEditSpecialtiesDialog(
                        widget.userId,
                        userSpecialist,
                        anotherSpecialist,
                      );
                    },
                    tooltip: LocaleKeys.general_edit_specialties.tr(),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (userSpecialist.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        LocaleKeys.notifications_no_specialties_assigned.tr(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    userSpecialist
                        .map((specialty) => _buildSpecialtyChip(specialty))
                        .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtyChip(SpecialtyModel specialty) {
    final theme = Theme.of(context);

    return Tooltip(
      message: specialty.name ?? '',
      showDuration: const Duration(seconds: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_hospital,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              specialty.name ?? '',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_userCanEditSpecialties()) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _confirmDeleteSpecialty(specialty),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.red.shade600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _userCanEditSpecialties() {
    return true;
  }

  void _confirmDeleteSpecialty(SpecialtyModel specialty) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.alerts_delete_specialty.tr()),
            content: Text(
              LocaleKeys.notifications_delete_specialty_confirmation.tr(
                namedArgs: {'name': specialty.name ?? ''},
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(LocaleKeys.buttons_cancel.tr()),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<PersonalSpecialtyCubit>().deleteSpecialty(
                    userId: widget.userId,
                    specialtyId: specialty.id ?? 0,
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(LocaleKeys.buttons_delete.tr()),
              ),
            ],
          ),
    );
  }

  void _showEditSpecialtiesDialog(
    int userId,
    List<SpecialtyModel> userSpecialties,
    List<SpecialtyModel> anotherSpecialist,
  ) {
    final userSpecialtiesIds = userSpecialist.map((e) => e.id).toSet();
    final availableSpecialties =
        anotherSpecialist
            .where((specialty) => !userSpecialtiesIds.contains(specialty.id))
            .toList();

    if (availableSpecialties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocaleKeys.notifications_no_more_specialties_available.tr(),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final selectedSpecialties = <SpecialtyModel>[];

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(LocaleKeys.forms_add_specialty.tr()),
              content: SizedBox(
                width: double.maxFinite,
                child:
                    availableSpecialties.isEmpty
                        ? const Text('No specialties available')
                        : SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children:
                                availableSpecialties.map((specialty) {
                                  final isSelected = selectedSpecialties
                                      .contains(specialty);
                                  return CheckboxListTile(
                                    title: Text(specialty.name ?? ''),
                                    value: isSelected,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          selectedSpecialties.add(specialty);
                                        } else {
                                          selectedSpecialties.remove(specialty);
                                        }
                                      });
                                    },
                                    dense: true,
                                  );
                                }).toList(),
                          ),
                        ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(LocaleKeys.buttons_cancel.tr()),
                ),
                TextButton(
                  onPressed:
                      selectedSpecialties.isEmpty
                          ? null
                          : () {
                            Navigator.pop(context);
                            final selectedIds =
                                selectedSpecialties
                                    .map((e) => e.id)
                                    .whereType<int>()
                                    .toList();
                            context.read<PersonalSpecialtyCubit>().addSpecialty(
                              userId: userId,
                              specialtyIds: selectedIds,
                            );
                          },
                  child: Text(LocaleKeys.buttons_add.tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
