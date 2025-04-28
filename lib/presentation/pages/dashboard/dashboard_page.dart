import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/core/repo/hear_beats/heart_beats_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/heartbeats/heart_beats_model.dart';
import 'package:dent_app_mobile/presentation/constants/asset_constants.dart';
import 'package:dent_app_mobile/presentation/pages/dashboard/core/heartbeats/heartbeats_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/dashboard/widgets/bar_chart.dart';
import 'package:dent_app_mobile/presentation/pages/dashboard/widgets/date_type_dropdown.dart';
import 'package:dent_app_mobile/presentation/pages/dashboard/widgets/info_card.dart';
import 'package:dent_app_mobile/presentation/pages/dashboard/widgets/monthly_chart.dart';
import 'package:dent_app_mobile/presentation/pages/dashboard/widgets/pie_chart.dart';
import 'package:dent_app_mobile/presentation/widgets/image/custom_asset_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(name: 'DashboardRoute')
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DateType _dateType;

  @override
  void initState() {
    _dateType = DateType.week;
    getData(_dateType);
    super.initState();
  }

  void getData(DateType dateType) {
    // setState(() {
    _dateType = dateType;
    // });
    context.read<HeartbeatsCubit>().getHeartBeats(dateType);
  }

  HeartbeatsModel? heartbeats;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            surfaceTintColor: Colors.white,
            title: Text(LocaleKeys.routes_dashboard.tr()),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomAssetImage(
                      path: AssetConstants.logo.png,
                      width: 40,
                      height: 40,
                    ),
                    DateTypeDropdown(
                      onChanged: getData,
                      width: 180,
                      initialValue: _dateType,
                    ),
                  ],
                ),
              ),
            ),
          ),
          BlocConsumer<HeartbeatsCubit, HeartbeatsState>(
            listener: (context, state) {
              if (state is HeartbeatsLoaded) {
                heartbeats = state.heartbeats;
              }
            },
            builder: (context, state) {
              if (state is HeartbeatsLoading && heartbeats == null) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is HeartbeatsError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text(state.message)),
                );
              } else {
                if (heartbeats == null) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Text('Error')),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        InfoCard(
                          serviceMade: ServiceMade(
                            current:
                                heartbeats!.countPatients?.toString() ?? "0",
                            difference: "0",
                            exceeds: true,
                          ),
                          title: LocaleKeys.general_count_patients.tr(),
                          subtitle: LocaleKeys.general_for_all_period.tr(),
                          icon: Icons.people,
                          frontColor: const Color(0xFFA5D6A7),
                          backColor: const Color(0xFF81C784),
                          iconColor: const Color(0xFF2E7D32),
                          textColor: const Color(0xFF1B5E20),
                        ),
                        InfoCard(
                          serviceMade: ServiceMade(
                            current: heartbeats!.serviceMade?.current ?? "0",
                            difference:
                                heartbeats!.serviceMade?.difference ?? "0",
                            exceeds: true,
                          ),
                          title: LocaleKeys.general_services_made.tr(),
                          subtitle: LocaleKeys.general_for_all_period.tr(),
                          icon: Icons.app_registration_rounded,
                          frontColor: const Color(0xFF90CAF9),
                          backColor: const Color(0xFF64B5F6),
                          iconColor: const Color(0xFF1565C0),
                          textColor: const Color(0xFF0D47A1),
                          isInfographic: true,
                        ),
                        InfoCard(
                          serviceMade: ServiceMade(
                            current:
                                heartbeats!.appointmentMade?.current ?? "0",
                            difference:
                                heartbeats!.appointmentMade?.difference ?? "0",
                            exceeds: false,
                          ),
                          title: LocaleKeys.general_visits_made.tr(),
                          subtitle: LocaleKeys.general_for_all_period.tr(),
                          icon: Icons.medical_services_outlined,
                          frontColor: const Color(0xFFCE93D8),
                          backColor: const Color(0xFFBA68C8),
                          iconColor: const Color(0xFF7B1FA2),
                          textColor: const Color(0xFF4A148C),
                          isInfographic: true,
                        ),
                        InfoCard(
                          serviceMade: ServiceMade(
                            current: DurationFormatter.formatIsoDuration(
                              heartbeats!.workingHours?.current ?? "0",
                            ),
                            difference: DurationFormatter.formatIsoDuration(
                              heartbeats!.workingHours?.difference ?? "0",
                            ),
                            exceeds: false,
                          ),
                          title: LocaleKeys.general_hours_worked.tr(),
                          subtitle: LocaleKeys.general_for_all_period.tr(),
                          icon: Icons.watch_later_outlined,
                          frontColor: const Color(0xFFFFCC80),
                          backColor: const Color(0xFFFFB74D),
                          iconColor: const Color(0xFFE65100),
                          textColor: const Color(0xFFBF360C),
                          isWorkingHours: true,
                        ),
                        MonthlyStatisticsChart(
                          data: heartbeats!.infographicResponses ?? [],
                        ),
                        ServicesPieChart(
                          data: heartbeats!.quantityByServiceResponses ?? [],
                        ),
                        ServicesBarChart(
                          data:
                              heartbeats!.quantityServiceByUserResponses ?? [],
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
