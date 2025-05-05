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
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
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
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    _dateType = DateType.week;
    _pageController = PageController(initialPage: 0);
    getData(_dateType);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void getData(DateType dateType) {
    _dateType = dateType;
    context.read<HeartbeatsCubit>().getHeartBeats(dateType);
  }

  HeartbeatsModel? heartbeats;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        surfaceTintColor: Theme.of(context).primaryColor,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomAssetImage(path: AssetConstants.logo.png),
        ),
        centerTitle: false,
        title: Text(
          LocaleKeys.routes_dashboard.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 40),
          child: Container(
            height: 48,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tab indicators
                Row(
                  children: [
                    for (int i = 0; i < 4; i++) _buildPageIndicator(i),
                  ],
                ),

                // Date selector
                DateTypeDropdown(
                  onChanged: getData,
                  width: 156,
                  initialValue: _dateType,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<HeartbeatsCubit, HeartbeatsState>(
              listener: (context, state) {
                if (state is HeartbeatsLoaded) {
                  setState(() {
                    heartbeats = state.heartbeats;
                  });
                }
              },
              builder: (context, state) {
                if (state is HeartbeatsLoading && heartbeats == null) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is HeartbeatsError) {
                  return Center(child: Text(state.message));
                } else {
                  if (heartbeats == null) {
                    return const Center(child: Text('Error'));
                  }
                  return _buildPageView();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int page) {
    final isSelected = _currentPage == page;

    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: isSelected ? 24 : 8,
        height: 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: .4),
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildInfoCardsPage(),
              _buildMonthlyStatsPage(),
              _buildPieChartPage(),
              _buildBarChartPage(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCardsPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            // Hasta Sayısı Kartı - Trend göstergesi olmadan
            StatCard(
              title: LocaleKeys.general_count_patients.tr(),
              value: heartbeats!.countPatients?.toString() ?? "0",
              subtitle: LocaleKeys.general_for_all_period.tr(),
              trend: TrendDirection.neutral, // Trend göstergesini kaldır
              trendPercentage: 0,
              icon: Icons.people,
              color: const Color(0xFF2E7D32),
              showMiniChart: false,
            ),

            // Çalışma Saatleri Kartı - Saat farkı göstergesi ile
            StatCard(
              title: LocaleKeys.general_hours_worked.tr(),
              value: DurationFormatter.formatIsoDuration(
                heartbeats!.workingHours?.current ?? "0",
              ),
              subtitle: LocaleKeys.general_for_all_period.tr(),
              trend:
                  heartbeats!.workingHours?.exceeds == true
                      ? TrendDirection.up
                      : TrendDirection.down,
              trendPercentage: 0.0, // Yüzde kullanmıyoruz
              trendText: _formatHoursDifference(heartbeats!.workingHours),
              icon: Icons.watch_later_outlined,
              color: const Color(0xFFE65100),
              showMiniChart: false,
            ),

            // Yapılan Servisler Kartı
            StatCard(
              title: LocaleKeys.general_services_made.tr(),
              value: heartbeats!.serviceMade?.current ?? "0",
              subtitle: LocaleKeys.general_for_all_period.tr(),
              trend:
                  heartbeats!.serviceMade?.exceeds == true
                      ? TrendDirection.up
                      : TrendDirection.down,
              trendPercentage: _calculatePercentage(
                heartbeats!.serviceMade?.current ?? "0",
                heartbeats!.serviceMade?.difference ?? "0",
              ),
              icon: Icons.app_registration_rounded,
              color: const Color(0xFF1565C0),
              showMiniChart: true,
              miniChartData: _generateDemoData(
                heartbeats!.serviceMade?.current ?? "0",
                heartbeats!.serviceMade?.exceeds == true
                    ? TrendDirection.up
                    : TrendDirection.down,
              ),
            ),

            // Yapılan Ziyaretler Kartı
            StatCard(
              title: LocaleKeys.general_visits_made.tr(),
              value: heartbeats!.appointmentMade?.current ?? "0",
              subtitle: LocaleKeys.general_for_all_period.tr(),
              trend:
                  heartbeats!.appointmentMade?.exceeds == true
                      ? TrendDirection.up
                      : TrendDirection.down,
              trendPercentage: _calculatePercentage(
                heartbeats!.appointmentMade?.current ?? "0",
                heartbeats!.appointmentMade?.difference ?? "0",
              ),
              icon: Icons.medical_services_outlined,
              color: const Color(0xFF7B1FA2),
              showMiniChart: true,
              miniChartData: _generateDemoData(
                heartbeats!.appointmentMade?.current ?? "0",
                heartbeats!.appointmentMade?.exceeds == true
                    ? TrendDirection.up
                    : TrendDirection.down,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculatePercentage(String current, String difference) {
    try {
      final currentValue = int.parse(current);
      final differenceValue = int.parse(difference);

      if (currentValue == 0) return 0.0;

      final previous = currentValue - differenceValue;
      if (previous == 0) return 100.0; // Avoid division by zero

      return (differenceValue / previous) * 100;
    } catch (e) {
      return 0.0;
    }
  }

  List<double> _generateDemoData(String baseValueStr, TrendDirection trend) {
    try {
      final baseValue = double.parse(baseValueStr);
      final data = <double>[];

      // Generate 7 data points for chart
      for (int i = 0; i < 7; i++) {
        if (trend == TrendDirection.up) {
          data.add(baseValue * (0.7 + 0.05 * i));
        } else {
          data.add(baseValue * (1.3 - 0.05 * i));
        }
      }

      return data;
    } catch (e) {
      return List.generate(7, (index) => 100.0 + index * 10);
    }
  }

  Widget _buildMonthlyStatsPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: .2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.insert_chart_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Aylık İstatistikler",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: MonthlyStatisticsChart(
                  data: heartbeats!.infographicResponses ?? [],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChartPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: .2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.pie_chart_outline,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Hizmet Dağılımı",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: ServicesPieChart(
                  data: heartbeats!.quantityByServiceResponses ?? [],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChartPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: .2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bar_chart, color: Colors.purple),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Kullanıcılara Göre Hizmetler",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: ServicesBarChart(
                  data: heartbeats!.quantityServiceByUserResponses ?? [],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Saat farkını formatlayan yardımcı fonksiyon
  String _formatHoursDifference(WorkingHours? workingHours) {
    if (workingHours == null || workingHours.difference == null) {
      return "";
    }

    final formattedDifference = DurationFormatter.formatIsoDuration(
      workingHours.difference!,
    );

    final prefix = workingHours.exceeds == true ? "+" : "-";
    return "$prefix$formattedDifference";
  }
}
