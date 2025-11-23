import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_tooth/patient_tooth_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/bloc/appointment_works/appointment_works_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/bloc/condition/condition_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/data/condition_type.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/service/condition_service.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/view/select_condition.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/view/select_diagnosis.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/view/select_tooth_type_step.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

@RoutePage(name: 'TeethConditionActionRoute')
class TeethConditionAction extends StatefulWidget {
  const TeethConditionAction({
    super.key,
    required this.appointmentId,
    required this.patientToothCubit,
    required this.patientId,
    required this.appointmentWorksCubit,
  });
  final int appointmentId;
  final PatientToothCubit patientToothCubit;
  final int patientId;
  final AppointmentWorksCubit appointmentWorksCubit;

  @override
  State<TeethConditionAction> createState() => _TeethConditionActionState();
}

class _TeethConditionActionState extends State<TeethConditionAction>
    with TickerProviderStateMixin {
  late final ConditionCubit _conditionCubit;
  late final AnimationController _progressAnimationController;
  late final Animation<double> _progressAnimation;

  int _currentStep = 0;
  final int _totalSteps = _stepInfos.length;
  bool _isCompleting = false;

  static final List<StepInfo> _stepInfos = [
    StepInfo(
      title: 'Состояние',
      subtitle: 'Выберите состояние зуба',
      icon: Icons.medical_services,
    ),
    StepInfo(
      title: 'Область зуба',
      subtitle: 'Укажите область лечения',
      icon: Icons.location_on,
    ),
    StepInfo(
      title: 'Диагноз',
      subtitle: 'Выберите диагноз',
      icon: Icons.assignment_outlined,
    ),
    // StepInfo(
    //   title: 'Услуга',
    //   subtitle: 'Выберите услугу',
    //   icon: Icons.build_outlined,
    // ),
  ];

  @override
  void initState() {
    super.initState();
    _conditionCubit = ConditionCubit();
    _getConditionList();

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _updateProgress();
  }

  Future<void> _getConditionList() async {
    final conditionType =
        context.read<ConditionService>().toothId == "29" ||
            context.read<ConditionService>().toothId == "39"
        ? ConditionType.jows
        : ConditionType.mains;
    await _conditionCubit.getConditionList(conditionType);
  }

  @override
  void dispose() {
    _conditionCubit.close();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    final progress = (_currentStep + 1) / _totalSteps;
    _progressAnimationController.animateTo(progress);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [BlocProvider.value(value: _conditionCubit)],
      child: Consumer<ConditionService>(
        builder: (context, conditionService, child) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: _buildAppBar(context, conditionService),
            bottomNavigationBar: _buildBottomControls(
              context,
              conditionService,
            ),
            body: Consumer<ConditionService>(
              builder: (context, conditionService, child) {
                return Column(
                  children: [
                    _buildProgressHeader(context),
                    Expanded(child: _buildStepContent(conditionService)),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ConditionService conditionService,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Лечение зуба ${conditionService.toothId}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'Шаг ${_currentStep + 1} из $_totalSteps',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _showHelpDialog(context),
          icon: const Icon(Icons.help_outline),
          tooltip: 'Помощь',
        ),
      ],
    );
  }

  Widget _buildProgressHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress Bar
          Row(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                      minHeight: 6,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${((_currentStep + 1) / _totalSteps * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Current Step Info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _stepInfos[_currentStep].icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _stepInfos[_currentStep].title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _stepInfos[_currentStep].subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(ConditionService conditionService) {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: _getCurrentStepWidget(),
      ),
    );
  }

  Widget _getCurrentStepWidget() {
    switch (_currentStep) {
      case 0:
        return const SelectConditionStep(key: ValueKey('condition'));
      case 1:
        return const SelectToothTypeStep(key: ValueKey('tooth_type'));
      case 2:
        return const SelectDiagnosisStep(key: ValueKey('diagnosis'));
      // case 3:
      //   return const SelectServiceStep(key: ValueKey('service'));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomControls(
    BuildContext context,
    ConditionService conditionService,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Previous Button
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _onStepCancel,
                  icon: const Icon(Icons.arrow_back),
                  label: Text(
                    MaterialLocalizations.of(context).backButtonTooltip,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            if (_currentStep > 0) const SizedBox(width: 16),

            // Next/Complete Button
            Expanded(
              flex: _currentStep == 0 ? 1 : 1,
              child: ElevatedButton.icon(
                onPressed:
                    _canProceedToNextStep(conditionService) && !_isCompleting
                    ? () {
                        _onStepContinue(context);
                      }
                    : null,
                icon: _isCompleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _currentStep >= _totalSteps - 1
                            ? Icons.check
                            : Icons.arrow_forward,
                      ),
                label: Text(
                  _isCompleting
                      ? LocaleKeys.buttons_saving.tr()
                      : _currentStep >= _totalSteps - 1
                      ? LocaleKeys.buttons_save.tr()
                      : LocaleKeys.buttons_next.tr(),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceedToNextStep(ConditionService conditionService) {
    switch (_currentStep) {
      case 0:
        return conditionService.condition != null;
      case 1:
        return conditionService.toothType != null;
      case 2:
        return conditionService.selectedDiagnosis.isNotEmpty;
      // case 3:
      //   return conditionService.selectedServices.isNotEmpty;
      default:
        return false;
    }
  }

  void _onStepContinue(BuildContext context) {
    final toothId = context.read<ConditionService>().toothId;
    final bool stepJump = (toothId == "29" || toothId == "39");

    HapticFeedback.lightImpact();
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep == 0 && stepJump ? _currentStep += 2 : _currentStep += 1;
      });
      _updateProgress();
    } else {
      _completeProcess(context);
    }
  }

  void _onStepCancel() {
    final toothId = context.read<ConditionService>().toothId;
    final bool stepJump = (toothId == "29" || toothId == "39");

    if (_currentStep >= 1) {
      setState(() {
        _currentStep == 2 && stepJump ? _currentStep -= 2 : _currentStep -= 1;
      });
      _updateProgress();
    }
  }

  Future<void> _completeProcess(BuildContext context) async {
    setState(() {
      _isCompleting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
    if (context.mounted) {
      context.read<ConditionService>().addJob();
    }

    if (mounted) {
      setState(() {
        _isCompleting = false;
      });
      // Show success dialog
      router.replace(
        WorkItemsRoute(
          appointmentId: widget.appointmentId,
          patientToothCubit: widget.patientToothCubit,
          patientId: widget.patientId,
          appointmentWorksCubit: widget.appointmentWorksCubit,
        ),
      );
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(LocaleKeys.buttons_help.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.diagnosis_treatment_setup_process.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ..._stepInfos.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            step.subtitle,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocaleKeys.buttons_ok.tr()),
          ),
        ],
      ),
    );
  }
}

class StepInfo {
  final String title;
  final String subtitle;
  final IconData icon;

  StepInfo({required this.title, required this.subtitle, required this.icon});
}
