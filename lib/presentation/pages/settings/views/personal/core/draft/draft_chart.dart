// import 'package:dent_app_mobile/generated/locale_keys.g.dart';
// import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/chart_constants.dart';
// import 'package:dent_app_mobile/presentation/pages/settings/views/personal/views/personal_detail_page.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class DraftChart {
//   final ChartConstants chartConstants = ChartConstants();

//   late TabController _tabController;
//   final _tabController = TabController(length: 3, vsync: this);

//   Widget _buildTabSection(BuildContext context) {
//     return Column(
//       children: [
//         TabBar(
//           controller: _tabController,
//           labelColor: Theme.of(context).colorScheme.primary,
//           unselectedLabelColor: Colors.grey,
//           indicatorColor: Theme.of(context).colorScheme.primary,
//           tabs: [
//             Tab(text: LocaleKeys.general_week.tr()),
//             Tab(text: LocaleKeys.general_month.tr()),
//             Tab(text: LocaleKeys.general_year.tr()),
//           ],
//         ),
//         const SizedBox(height: 16),
//         SizedBox(
//           height: 200,
//           child: TabBarView(
//             controller: _tabController,
//             children: [
//               _buildWeeklyStatsChart(),
//               _buildMonthlyStatsChart(),
//               _buildYearlyStatsChart(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildWeeklyStatsChart(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//       child: SfCartesianChart(
//         primaryXAxis: CategoryAxis(),
//         tooltipBehavior: TooltipBehavior(enable: true),
//         series: <CartesianSeries>[
//           SplineSeries<ChartData, String>(
//             dataSource: chartConstants.weeklyData,
//             xValueMapper: (ChartData data, _) => data.x,
//             yValueMapper: (ChartData data, _) => data.y,
//             color: Theme.of(context).colorScheme.primary,
//             markerSettings: const MarkerSettings(isVisible: true),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMonthlyStatsChart() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: SfCartesianChart(
//         primaryXAxis: CategoryAxis(),
//         legend: Legend(isVisible: true, position: LegendPosition.bottom),
//         tooltipBehavior: TooltipBehavior(enable: true),
//         series: <CartesianSeries>[
//           ColumnSeries<ChartData, String>(
//             dataSource: chartConstants.monthlyAppointments,
//             xValueMapper: (ChartData data, _) => data.x,
//             yValueMapper: (ChartData data, _) => data.y,
//             name: 'Appointments',
//             color: Colors.blue,
//             width: 0.4,
//             spacing: 0.2,
//           ),
//           ColumnSeries<ChartData, String>(
//             dataSource: chartConstants.monthlyPatients,
//             xValueMapper: (ChartData data, _) => data.x,
//             yValueMapper: (ChartData data, _) => data.y,
//             name: 'Patients',
//             color: Colors.red,
//             width: 0.4,
//             spacing: 0.2,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildYearlyStatsChart() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: SfCartesianChart(
//         primaryXAxis: CategoryAxis(),
//         tooltipBehavior: TooltipBehavior(enable: true),
//         series: <CartesianSeries>[
//           LineSeries<ChartData, String>(
//             dataSource: chartConstants.quarterlyData,
//             xValueMapper: (ChartData data, _) => data.x,
//             yValueMapper: (ChartData data, _) => data.y,
//             color: Colors.green,
//             markerSettings: const MarkerSettings(isVisible: true),
//             width: 3,
//           ),
//         ],
//       ),
//     );
//   }
// }
