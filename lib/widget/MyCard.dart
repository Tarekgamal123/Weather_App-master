// lib/widgets/myCard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/controller/HomeController.dart';
import '../constants/images.dart';

class MyCard extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/cloud-in-blue-sky.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 40, 16, 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.menu, color: Colors.white, size: 28),
                Icon(Icons.favorite_border, color: Colors.white, size: 28),
              ],
            ),
            SizedBox(height: 20),

            TextField(
              onChanged: (v) => controller.city = v,
              onSubmitted: (_) => controller.updateWeather(),
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search city...',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),

            SizedBox(height: 30),

            Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white.withOpacity(0.95),
                ),
                child: Column(
                  children: [
                    Text(controller.currentWeatherData?.name ?? 'Loading...', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    Text(DateFormat('EEEE, MMMM d').format(DateTime.now()), style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(controller.currentWeatherData?.weather?[0].description?.capitalize ?? '',
                                style: TextStyle(fontSize: 20)),
                            SizedBox(height: 10),

                            // درجة الحرارة الرئيسية مع F/C
                            Obx(() => Text(
                              '${controller.currentWeatherData?.main?.temp?.round() ?? '--'}°${controller.currentUnit.value}',
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: controller.currentUnit.value == 'F' ? Colors.orange[800] : Colors.blue[800],
                              ),
                            )),

                            SizedBox(height: 8),

                            // Min / Max مع F/C
                            Obx(() => Text(
                              'min: ${controller.currentWeatherData?.main?.tempMin?.round() ?? '--'}°${controller.currentUnit.value} | max: ${controller.currentWeatherData?.main?.tempMax?.round() ?? '--'}°${controller.currentUnit.value}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            )),
                          ],
                        ),
                        Column(
                          children: [
                            Lottie.asset(Images.cloudyAnim, width: 120, height: 120),
                            Text('Wind ${controller.currentWeatherData?.wind?.speed?.toStringAsFixed(1) ?? '0'} m/s',
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}