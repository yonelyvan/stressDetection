import 'package:stdetector/src/model/gsr_data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WidgetSignal extends StatelessWidget {
  final List<GSRData> data;
  final String label;

  const WidgetSignal({required this.data, required this.label});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
        height: 300,
        width: screenWidth,
        child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            title: ChartTitle(
                text: label,
                textStyle: TextStyle(fontSize: 14, color: Colors.black38)),
            legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                ),
            // Enable tooltip
            tooltipBehavior: TooltipBehavior(enable: false),
            enableAxisAnimation: true,
            series: <LineSeries<GSRData, String>>[
              LineSeries<GSRData, String>(
                dataSource: data,
                xValueMapper: (GSRData sales, _) => sales.time,
                yValueMapper: (GSRData sales, _) => sales.value,
                xAxisName: "Time",
                yAxisName: "Level",
                name: "Stress Level",
                // Enable data label
                //dataLabelSettings: DataLabelSettings(isVisible: true)
              )
            ]));
  }
}
