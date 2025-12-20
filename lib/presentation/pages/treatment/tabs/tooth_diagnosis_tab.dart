import 'package:dent_app_mobile/core/locator/locator.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/diagnosis/tooth_model.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_tooth/patient_tooth_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/content/tooth_examination_dialod.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/bloc/appointment_works/appointment_works_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/bloc/manage_work/manage_work_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/model/job_model.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/service/condition_service.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/permanent_tab_widget.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/work_list_tile.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/teeth_selector/teeth_selector.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class ToothDiagnosisTab extends StatefulWidget {
  const ToothDiagnosisTab({
    super.key,
    required this.appointmentId,
    required this.patientId,
  });

  final int appointmentId;
  final int patientId;

  @override
  State<ToothDiagnosisTab> createState() => _ToothDiagnosisTabState();
}

class _ToothDiagnosisTabState extends State<ToothDiagnosisTab> {
  late PatientToothCubit _patientToothCubit;
  late final AppointmentWorksCubit _appointmentWorksCubit;
  late final ManageWorkCubit _manageWorksCubit;
  List<ToothModel> _teeth = [];
  final ValueNotifier<bool> showPermanent = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _patientToothCubit = PatientToothCubit();
    _appointmentWorksCubit = getIt<AppointmentWorksCubit>();
    _manageWorksCubit = getIt<ManageWorkCubit>();

    _appointmentWorksCubit.loadAppointmentWork(widget.appointmentId);
    _patientToothCubit.getToothList(widget.patientId);
  }

  @override
  void dispose() {
    _patientToothCubit.close();
    _appointmentWorksCubit.close();
    showPermanent.dispose();
    _manageWorksCubit.close();
    super.dispose();
  }

  static const double _verticalSpacing = 10.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _patientToothCubit.getToothList(widget.patientId);
          _appointmentWorksCubit.loadAppointmentWork(widget.appointmentId);
        },
        child: BlocListener<ManageWorkCubit, ManageWorkState>(
          bloc: _manageWorksCubit,
          listener: (context, state) {
            state.maybeWhen(
              orElse: () {},
              success: (message, isDelete, workId) {
                if (isDelete) {
                  _patientToothCubit.getToothList(widget.patientId);
                }
              },
            );
          },
          child: BlocConsumer<PatientToothCubit, PatientToothState>(
            bloc: _patientToothCubit,
            listener: (context, state) {
              if (state is PatientToothLoaded) {
                _teeth = state.teeth;
              }
            },
            builder: (context, state) {
              return Consumer<ConditionService>(
                builder: (context, conditionService, child) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: _verticalSpacing),
                        _buildTeethSelector(conditionService),
                        const SizedBox(height: _verticalSpacing),
                        if (conditionService.jobs.isNotEmpty)
                          WorkListTile(
                            navigateTo: () => _navigateToWorkItems(),
                            jobCount: conditionService.jobs.length,
                            title: LocaleKeys.general_work_items.tr(),
                            iconData: Icons.work_history_outlined,
                          ),
                        const SizedBox(height: _verticalSpacing),

                        BlocBuilder<
                          AppointmentWorksCubit,
                          AppointmentWorksState
                        >(
                          bloc: _appointmentWorksCubit,
                          builder: (context, state) {
                            return WorkListTile(
                              navigateTo: () => router.push(
                                AppointmentWorkHistoryRoute(
                                  appointmentId: widget.appointmentId,
                                  appointmentWorkHistory:
                                      _appointmentWorksCubit,
                                  manageWorkCubit: _manageWorksCubit,
                                ),
                              ),
                              jobCount: state.maybeWhen(
                                orElse: () => 0,
                                loaded: (works) => works.length,
                              ),
                              title: LocaleKeys.buttons_saved.tr(),
                              iconData: Icons.work_outlined,
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              router.push(
                                PaymentDetailRoute(
                                  appointmentId: widget.appointmentId,
                                ),
                              );
                            },
                            child: Center(
                              child: Text(LocaleKeys.buttons_pay.tr()),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Map<String, Color> _getTeethColorMap() {
    final map = <String, Color>{};

    for (final tooth in _teeth) {
      if (tooth.toothNumber != null) {
        final String toothId = tooth.toothNumber.toString();

        // Önce main.color'a bak
        if (tooth.main?.color != null && tooth.main!.color!.isNotEmpty) {
          map[toothId] = AppColors.red; //_hexToColor(tooth.main!.color!);
        } else {
          // main.color yoksa, innerToothResponse içindeki ilk rengi kullan
          final innerColor = AppColors.red; //_getFirstInnerToothColor(tooth);
          map[toothId] = innerColor;
        }
      }
    }

    return map;
  }

  /// innerToothResponse içindeki ilk bulunan rengi döndürür
  Color? _getFirstInnerToothColor(ToothModel tooth) {
    final inner = tooth.innerToothResponse;
    if (inner == null) return null;

    final parts = [
      inner.top,
      inner.bottom,
      inner.left,
      inner.right,
      inner.centerLeft,
      inner.centerRight,
    ];

    for (final part in parts) {
      if (part?.color != null && part!.color!.isNotEmpty) {
        return _hexToColor(part.color!);
      }
    }

    return null;
  }

  /// Converts a hex string to Color
  Color _hexToColor(String hexString) {
    try {
      final String colorStr = hexString.replaceAll('#', '');
      return Color(int.parse('FF$colorStr', radix: 16));
    } catch (e) {
      // Return default color on error
      return ColorConstants.primary;
    }
  }

  /// Builds the teeth selector widget with jaw overlay buttons
  Widget _buildTeethSelector(ConditionService conditionService) {
    final theme = Theme.of(context);

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // TeethSelector as base
          Column(
            spacing: 16,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: PermanentTabWidget(showPermanent: showPermanent),
              ),

              ValueListenableBuilder(
                valueListenable: showPermanent,
                builder: (context, value, child) {
                  return CustomTeethSelector(
                    showPrimary: !value,
                    StrokedColorized: _getTeethColorMap(),
                    multiSelect: false,
                    showPermanent: value,
                    colorized: _buildColorizedMap(conditionService, theme),
                    selectedColor: theme.colorScheme.primary,
                    rightString: LocaleKeys.general_right.tr(),
                    leftString: LocaleKeys.general_left.tr(),
                    initiallySelected: _getInitiallySelectedTeeth(
                      conditionService,
                    ),
                    onChange: (selected) =>
                        _handleTeethSelection(selected, conditionService),
                  );
                },
              ),
            ],
          ),

          // Overlay jaw buttons in the center
          Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: .center,
              spacing: 12,
              children: [
                // Upper jaw button
                _buildCompactJawButton(
                  context: context,
                  title: LocaleKeys.tooth_upper_jaw.tr(),
                  toothId: "29",
                  isUpper: true,
                  conditionService: conditionService,
                  theme: theme,
                ),
                // Lower jaw button
                _buildCompactJawButton(
                  context: context,
                  title: LocaleKeys.tooth_lower_jaw.tr(),
                  toothId: "39",
                  isUpper: false,
                  conditionService: conditionService,
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds compact jaw button for overlay
  Widget _buildCompactJawButton({
    required BuildContext context,
    required String title,
    required String toothId,
    required bool isUpper,
    required ConditionService conditionService,
    required ThemeData theme,
  }) {
    // Check if this jaw has existing jobs
    final hasJob = conditionService.jobs.any((job) => job.toothId == toothId);
    final jawJob = hasJob
        ? conditionService.jobs.firstWhere((job) => job.toothId == toothId)
        : null;

    return Material(
      elevation: hasJob ? 0 : 2,
      borderRadius: BorderRadius.circular(16),
      color: hasJob
          ? theme.colorScheme.primary.withValues(alpha: 0.1)
          : Colors.white.withValues(alpha: 0.95),
      child: InkWell(
        onTap: () {
          // EKLE: Jaw için de tooth history bul
          int? toothIdInt;
          try {
            toothIdInt = int.parse(toothId);
          } catch (e) {
            // Parse error
          }

          final toothInfo = toothIdInt != null
              ? _teeth.firstWhere(
                  (tooth) => tooth.toothNumber == toothIdInt,
                  orElse: () => ToothModel(toothNumber: toothIdInt),
                )
              : null;

          _showToothDialog(toothId, conditionService, teethHistory: toothInfo);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasJob
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: hasJob ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // SVG Icon
              Icon(
                isUpper ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: hasJob
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),

              // Title
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title: title,
                    textType: TextType.description,
                    fontWeight: FontWeight.w600,
                    color: hasJob
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                  if (hasJob && jawJob != null)
                    AppText(
                      title:
                          "${jawJob.servicesWithCount.values.fold(0, (sum, count) => sum + count)} услуг",
                      textType: TextType.subtitle,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates colorized map for teeth with smart color logic
  Map<String, Color> _buildColorizedMap(
    ConditionService conditionService,
    ThemeData theme,
  ) {
    return {
      for (final job in conditionService.jobs)
        job.toothId:
            AppColors.red, //_getToothColor(job.condition.color, theme),
    };
  }

  /// Determines the appropriate color for a tooth
  Color _getToothColor(Color? conditionColor, ThemeData theme) {
    if (conditionColor == Colors.white) {
      return Colors.green;
    }
    return conditionColor ?? theme.colorScheme.primary;
  }

  /// Gets initially selected teeth IDs
  List<String> _getInitiallySelectedTeeth(ConditionService conditionService) {
    return conditionService.jobs.map((job) => job.toothId).toList();
  }

  /// Handles teeth selection logic
  void _handleTeethSelection(
    List<String> selected,
    ConditionService conditionService,
  ) {
    int? toothId;
    try {
      toothId = int.parse(selected.last);
    } catch (e) {
      // Ignore parsing error
      return;
    }
    final toothInfo = _teeth.firstWhere(
      (tooth) => tooth.toothNumber == toothId,
      orElse: () => ToothModel(toothNumber: toothId),
    );
    if (selected.isNotEmpty) {
      _showToothDialog(
        selected.last,
        conditionService,
        teethHistory: toothInfo,
      );
    }
  }

  /// Shows tooth examination dialog
  /// Shows tooth examination dialog
  void _showToothDialog(
    String toothId,
    ConditionService conditionService, {
    ToothModel? teethHistory,
  }) {
    final existingJob = conditionService.jobs.cast<JobModel?>().firstWhere(
      (job) => job?.toothId == toothId,
      orElse: () => null,
    );

    // EKLE: toothId'yi int'e çevir ve tooth history'yi bul
    int? toothIdInt;
    try {
      toothIdInt = int.parse(toothId);
    } catch (e) {
      // Parse error
    }

    // Eğer teethHistory parametresi gelmemişse, _teeth listesinden bul
    final toothInfo =
        teethHistory ??
        (toothIdInt != null
            ? _teeth.firstWhere(
                (tooth) => tooth.toothNumber == toothIdInt,
                orElse: () => ToothModel(toothNumber: toothIdInt),
              )
            : null);

    showDialog(
      context: context,
      builder: (context) => ToothExaminationDialog(
        toothId: toothId,
        existingJob: existingJob,
        teethHistory: toothInfo,
        onExamine: () {
          router.pop();
          conditionService.setToothId(toothId);
          router.push(
            TeethConditionActionRoute(
              appointmentId: widget.appointmentId,
              patientToothCubit: _patientToothCubit,
              patientId: widget.patientId,
              appointmentWorksCubit: _appointmentWorksCubit,
            ),
          );
        },
      ),
    );
  }

  /// Navigates to work items page
  Future<void> _navigateToWorkItems() async {
    await router.push(
      WorkItemsRoute(
        appointmentId: widget.appointmentId,
        patientToothCubit: _patientToothCubit,
        patientId: widget.patientId,
        appointmentWorksCubit: _appointmentWorksCubit,
      ),
    );
  }
}
