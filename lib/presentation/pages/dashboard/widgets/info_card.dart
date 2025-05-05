// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/heartbeats/heart_beats_model.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.trend,
    required this.trendPercentage,
    this.trendText,
    this.icon,
    this.color = Colors.blue,
    this.showMiniChart = true,
    this.miniChartData = const [],
    this.onTap,
  });

  final String title;
  final String value;
  final String subtitle;
  final TrendDirection trend;
  final double trendPercentage;
  final String? trendText;
  final IconData? icon;
  final Color color;
  final bool showMiniChart;
  final List<double> miniChartData;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: CustomCardDecoration(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: subTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Main value and trend
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            value,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildTrendIndicator(context),
                        ],
                      ),
                    ],
                  ),
                  if (icon != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 26),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Subtitle text
              Text(
                subtitle,
                style: TextStyle(color: subTextColor, fontSize: 13),
              ),

              if (showMiniChart && miniChartData.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(height: 40, child: _buildMiniChart()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(BuildContext context) {
    // TrendDirection.neutral ise gösterme
    if (trend == TrendDirection.neutral) {
      return const SizedBox.shrink();
    }

    final isPositive = trend == TrendDirection.up;
    final color = isPositive ? Colors.green : Colors.redAccent;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
          color: color,
          size: 14,
        ),
        const SizedBox(width: 2),
        Text(
          trendText ?? '${trendPercentage.toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniChart() {
    final isPositive = trend == TrendDirection.up;

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: _generateSpots(),
            isCurved: true,
            color: isPositive ? Colors.green : Colors.redAccent,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color:
                  isPositive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.redAccent.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(enabled: false),
        minX: 0,
        maxX: miniChartData.length.toDouble() - 1,
        minY: _getMinValue() * 0.9,
        maxY: _getMaxValue() * 1.1,
      ),
    );
  }

  List<FlSpot> _generateSpots() {
    return List.generate(
      miniChartData.length,
      (index) => FlSpot(index.toDouble(), miniChartData[index]),
    );
  }

  double _getMinValue() {
    if (miniChartData.isEmpty) return 0;
    return miniChartData.reduce((a, b) => a < b ? a : b);
  }

  double _getMaxValue() {
    if (miniChartData.isEmpty) return 0;
    return miniChartData.reduce((a, b) => a > b ? a : b);
  }
}

enum TrendDirection { up, down, neutral }

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.frontServiceMade,
    required this.frontTitle,
    required this.frontSubtitle,
    this.frontIcon = Icons.star,
    this.frontColor = ColorConstants.primary,
    this.frontIconColor = Colors.white,
    this.frontTextColor = Colors.black,
    this.frontIsInfographic = false,
    this.frontIsWorkingHours = false,
    required this.backServiceMade,
    required this.backTitle,
    required this.backSubtitle,
    this.backColor = ColorConstants.grey,
    this.backIcon = Icons.star,
    this.backIconColor = Colors.white,
    this.backTextColor = Colors.black,
    this.backIsInfographic = false,
    this.backIsWorkingHours = false,
  });

  // Front side properties
  final ServiceMade frontServiceMade;
  final String frontTitle;
  final String frontSubtitle;
  final IconData frontIcon;
  final Color frontColor;
  final Color frontIconColor;
  final Color frontTextColor;
  final bool frontIsInfographic;
  final bool frontIsWorkingHours;

  // Back side properties
  final ServiceMade backServiceMade;
  final String backTitle;
  final String backSubtitle;
  final Color backColor;
  final IconData backIcon;
  final Color backIconColor;
  final Color backTextColor;
  final bool backIsInfographic;
  final bool backIsWorkingHours;

  @override
  Widget build(BuildContext context) {
    // Front card
    final frontTrend =
        frontServiceMade.exceeds == true
            ? TrendDirection.up
            : TrendDirection.down;
    final frontPercentage = _calculatePercentage(frontServiceMade);

    // Back card
    final backTrend =
        backServiceMade.exceeds == true
            ? TrendDirection.up
            : TrendDirection.down;
    final backPercentage = _calculatePercentage(backServiceMade);

    // Random chart data based on current values for demonstration
    final frontChartData = _generateDemoData(frontServiceMade, frontTrend);
    final backChartData = _generateDemoData(backServiceMade, backTrend);

    return PageView(
      children: [
        StatCard(
          title: frontTitle,
          value: frontServiceMade.current?.toString() ?? "0",
          subtitle: frontSubtitle,
          trend: frontTrend,
          trendPercentage: frontPercentage,
          icon: frontIcon,
          color: frontColor,
          miniChartData: frontChartData,
          showMiniChart: frontIsInfographic,
        ),
        StatCard(
          title: backTitle,
          value: backServiceMade.current?.toString() ?? "0",
          subtitle: backSubtitle,
          trend: backTrend,
          trendPercentage: backPercentage,
          icon: backIcon,
          color: backColor,
          miniChartData: backChartData,
          showMiniChart: backIsInfographic,
        ),
      ],
    );
  }

  double _calculatePercentage(ServiceMade serviceMade) {
    if (serviceMade.current == null || serviceMade.difference == null) {
      return 0.0;
    }

    try {
      final current = int.parse(serviceMade.current!);
      final difference = int.parse(serviceMade.difference!);

      if (current == 0) return 0.0;

      final previous = current - difference;
      if (previous == 0) return 100.0; // Avoid division by zero

      return (difference / previous) * 100;
    } catch (e) {
      return 0.0;
    }
  }

  List<double> _generateDemoData(
    ServiceMade serviceMade,
    TrendDirection trend,
  ) {
    try {
      final baseValue = double.parse(serviceMade.current ?? "0");
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
}

class DurationFormatter {
  static String formatIsoDuration(String isoDuration) {
    final RegExp regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?');
    final Match? match = regex.firstMatch(isoDuration);

    if (match == null) return '0 ${LocaleKeys.general_hours.tr()}';

    final hours = match.group(1);
    final minutes = match.group(2);

    final StringBuffer buffer = StringBuffer();

    if (hours != null && hours != '0') {
      buffer.write('$hours ${LocaleKeys.general_hours.tr()}');
    }

    if (minutes != null && minutes != '0') {
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write('$minutes ${LocaleKeys.general_minutes.tr()}');
    }

    return buffer.toString();
  }

  static String formatDifference(String current, String difference) {
    final currentFormatted = formatIsoDuration(current);
    final differenceFormatted = formatIsoDuration(difference);

    return '$currentFormatted (${_getChangeSymbol(difference)}$differenceFormatted)';
  }

  static String _getChangeSymbol(String difference) {
    // Eğer negatif değer kontrolü yapmak isterseniz burada yapabilirsiniz
    return '+';
  }
}
