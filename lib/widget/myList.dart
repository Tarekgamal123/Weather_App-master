// lib/widgets/myList.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/controller/HomeController.dart';
import '../constants/images.dart';

class MyList extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: GetBuilder<HomeController>(
        builder: (c) => c.dataList.isEmpty
            ? Center(child: Text("No cities", style: TextStyle(color: Colors.grey)))
            : ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                separatorBuilder: (_, __) => SizedBox(width: 12),
                itemCount: c.dataList.length,
                itemBuilder: (_, i) {
                  final d = c.dataList[i];
                  final temp = d.main?.temp?.round() ?? 0;
                  final desc = d.weather?[0].description?.capitalize ?? '';

                  return GestureDetector(
                    onTap: () { c.city = d.name!; c.updateWeather(); },
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: Container(
                        width: 130,
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(d.name ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                overflow: TextOverflow.ellipsis),
                            SizedBox(height: 6),
                            Obx(() => Text('$temp°${c.currentUnit.value}',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                                    color: c.currentUnit.value == 'F' ? Colors.orange[700] : Colors.blue[700]))),
                            SizedBox(height: 6),
                            SizedBox(width: 40, height: 40, child: Lottie.asset(Images.cloudyAnim)),
                            SizedBox(height: 4),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text(desc,
                                  style: TextStyle(fontSize: 10, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}