// lib/widgets/my_chart.dart
// النسخة النهائية - يدعم عرض الوقت من dateTime الموجود ('day-hour') + F/C شغال + بدون خطأ

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_app/controller/HomeController.dart';

class MyChart extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      margin: EdgeInsets.all(16),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: GetBuilder<HomeController>(
          builder: (c) {
            if (c.fiveDaysData.isEmpty) {
              return Center(child: Text("No forecast data", style: TextStyle(color: Colors.grey[600])));
            }

            final data = c.fiveDaysData.take(8).toList();
            final temps = data.map((e) => (e.temp ?? 0).toDouble()).toList();  // toDouble to avoid num issues
            final maxT = temps.reduce((a, b) => a > b ? a : b);
            final minT = temps.reduce((a, b) => a < b ? a : b);
            final range = maxT - minT == 0 ? 1.0 : maxT - minT;

            return Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text("24-Hour Forecast", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),

                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(data.length, (i) {
                        final temp = temps[i].round();
                        final height = ((temp - minT) / range * 120).clamp(20.0, 150.0);

                        // عرض الوقت من dateTime الموجود ('day-hour')
                        String timeLabel = data[i].dateTime ?? '--:--';
                        if (timeLabel.contains('-')) {
                          final parts = timeLabel.split('-');
                          if (parts.length == 2) {
                            timeLabel = '${parts[1]}:00';  // تحويل '04-15' إلى '15:00'
                          }
                        }

                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Obx(() => Text(
                                "$temp°${c.currentUnit.value}",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              )),

                              SizedBox(height: 8),

                              Container(
                                height: height,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                  gradient: LinearGradient(
                                    colors: c.currentUnit.value == 'F'
                                        ? [Colors.orange[400]!, Colors.orange[700]!]
                                        : [Colors.blue[400]!, Colors.blue[700]!],
                                  ),
                                ),
                              ),

                              SizedBox(height: 8),

                              Text(
                                timeLabel,
                                style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),

                  SizedBox(height: 16),
                  Divider(height: 1),

                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(children: [
                        Icon(Icons.arrow_upward, color: Colors.red, size: 20),
                        SizedBox(width: 6),
                        Text("High: $maxT°${c.currentUnit.value}", style: TextStyle(fontWeight: FontWeight.w600)),
                      ]),
                      Row(children: [
                        Icon(Icons.arrow_downward, color: Colors.blue, size: 20),
                        SizedBox(width: 6),
                        Text("Low: $minT°${c.currentUnit.value}", style: TextStyle(fontWeight: FontWeight.w600)),
                      ]),
                    ],
                  )),
                  SizedBox(height: 10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}