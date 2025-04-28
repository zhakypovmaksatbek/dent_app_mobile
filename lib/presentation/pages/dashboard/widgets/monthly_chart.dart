import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/heartbeats/heart_beats_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MonthlyStatisticsChart extends StatefulWidget {
  final List<InfographicResponses> data;

  const MonthlyStatisticsChart({super.key, required this.data});

  @override
  State<MonthlyStatisticsChart> createState() => _MonthlyStatisticsChartState();
}

class _MonthlyStatisticsChartState extends State<MonthlyStatisticsChart> {
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    _initializeChartBehaviors();
  }

  void _initializeChartBehaviors() {
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      format: '${LocaleKeys.general_quantity}: point.y',
      textStyle: const TextStyle(fontSize: 14),
      duration: 3000,
      color: Colors.black87,
    );

    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enableDoubleTapZooming: true,
      enableSelectionZooming: true,
      selectionRectBorderColor: Colors.blue,
      selectionRectBorderWidth: 1,
      selectionRectColor: Colors.blue.withOpacity(0.1),
      enablePanning: true,
      zoomMode: ZoomMode.x,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: SfCartesianChart(
        title: ChartTitle(
          text: LocaleKeys.general_monthly_statistics.tr(),
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          alignment: ChartAlignment.center,
        ),
        legend: Legend(
          isVisible: false,
          position: LegendPosition.bottom,
          overflowMode: LegendItemOverflowMode.wrap,
          textStyle: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface,
          ),
        ),
        tooltipBehavior: _tooltipBehavior,
        zoomPanBehavior: _zoomPanBehavior,
        primaryXAxis: CategoryAxis(
          labelStyle: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 12,
          ),
          labelRotation: 45,
          majorGridLines: const MajorGridLines(width: 0),
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
          axisLine: const AxisLine(width: 1),
          title: AxisTitle(
            text: LocaleKeys.general_month.tr(),
            textStyle: const TextStyle(fontSize: 14),
          ),
        ),
        primaryYAxis: NumericAxis(
          labelStyle: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 12,
          ),
          axisLine: const AxisLine(width: 1),
          majorTickLines: const MajorTickLines(size: 0),
          title: AxisTitle(
            text: LocaleKeys.general_quantity.tr(),
            textStyle: const TextStyle(fontSize: 14),
          ),
          minimum: 0,
          interval: 5,
        ),
        series: <CartesianSeries<dynamic, dynamic>>[
          ColumnSeries<dynamic, dynamic>(
            dataSource: widget.data,
            xValueMapper: (data, _) => (data as InfographicResponses).day,
            yValueMapper: (data, _) => (data as InfographicResponses).quantity,
            name: LocaleKeys.general_monthly_statistics.tr(),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.6),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              labelAlignment: ChartDataLabelAlignment.top,
              offset: const Offset(0, -10),
            ),
            width: 0.7,
            spacing: 0.2,
            enableTooltip: true,
            animationDuration: 1200,
            animationDelay: 100,
          ),
        ],
        plotAreaBorderWidth: 0,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
