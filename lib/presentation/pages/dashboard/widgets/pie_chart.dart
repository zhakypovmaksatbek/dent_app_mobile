// ignore_for_file: library_private_types_in_public_api

import 'package:dent_app_mobile/models/heartbeats/heart_beats_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ServicesPieChart extends StatefulWidget {
  final List<QuantityServiceByUserResponses> data;

  const ServicesPieChart({super.key, required this.data});

  @override
  State<ServicesPieChart> createState() => _ServicesPieChartState();
}

class _ServicesPieChartState extends State<ServicesPieChart> {
  late List<QuantityServiceByUserResponses> chartData;
  late TooltipBehavior tooltipBehavior;

  @override
  void initState() {
    super.initState();
    chartData = widget.data;
    tooltipBehavior = TooltipBehavior(
      enable: true,
      format: 'point.x : point.y',
      textStyle: const TextStyle(fontSize: 14),
    );
  }

  @override
  void didUpdateWidget(ServicesPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      setState(() {
        chartData = widget.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 400, // Adjust based on your needs
      child: SfCircularChart(
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          orientation: LegendItemOrientation.vertical,
          overflowMode: LegendItemOverflowMode.wrap,
          textStyle: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface,
          ),
          backgroundColor: theme.colorScheme.surface,
          borderColor: theme.colorScheme.outline.withOpacity(0.5),
          borderWidth: 1,
        ),
        tooltipBehavior: tooltipBehavior,
        palette: const [
          Color(0xFF6B8E23), // Olive Green
          Color(0xFF4682B4), // Steel Blue
          Color(0xFFCD853F), // Peru
          Color(0xFF9370DB), // Medium Purple
          Color(0xFF20B2AA), // Light Sea Green
          Color(0xFFDA70D6), // Orchid
          Color(0xFF32CD32), // Lime Green
          Color(0xFF4169E1), // Royal Blue
        ],
        series: <PieSeries<QuantityServiceByUserResponses, String>>[
          PieSeries<QuantityServiceByUserResponses, String>(
            dataSource: chartData,
            xValueMapper: (data, _) => data.label,
            yValueMapper: (data, _) => data.value,
            dataLabelMapper: (data, _) => '${data.value}',
            radius: '80%',
            explode: true,
            explodeIndex: _getMaxValueIndex(),
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              connectorLineSettings: const ConnectorLineSettings(
                type: ConnectorType.curve,
                length: '15%',
              ),
              textStyle: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            enableTooltip: true,
          ),
        ],
      ),
    );
  }

  int _getMaxValueIndex() {
    if (chartData.isEmpty) return -1;

    int maxIndex = 0;
    double maxValue = chartData[0].value ?? 0;

    for (int i = 1; i < chartData.length; i++) {
      if (chartData[i].value != null && chartData[i].value! > maxValue) {
        maxValue = chartData[i].value!;
        maxIndex = i;
      }
    }

    return maxIndex;
  }
}
