// lib/pages/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/constants/images.dart';
import 'package:weather_app/controller/HomeController.dart';
import 'package:weather_app/widget/myList.dart';
import 'package:weather_app/widget/my_chart.dart';
import 'package:weather_app/pages/weather_detail_page.dart';
import 'package:weather_app/pages/favorites_page.dart';
import 'package:weather_app/pages/settings_page.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<HomeController>(
        builder: (controller) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top card with weather
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
                        image: AssetImage('assets/images/cloud-in-blue-sky.jpg'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.menu, color: Colors.white),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: Icon(Icons.favorite_border, color: Colors.white),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => FavoritesPage()),
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          TextField(
                            onChanged: (value) => controller.city = value,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (value) => controller.updateWeather(),
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              suffixIcon: Icon(Icons.search, color: Colors.white),
                              hintText: 'SEARCH',
                              hintStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              if (controller.currentWeatherData?.name != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WeatherDetailPage(
                                      cityName: controller.currentWeatherData!.name!,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Card(
                              color: Colors.white.withOpacity(0.90),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 8,
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            controller.currentWeatherData?.name ?? 'Search a city',
                                            style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[600]),
                                      ],
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      DateFormat().add_MMMMEEEEd().format(DateTime.now()),
                                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              controller.currentWeatherData?.weather?[0].description?.capitalize ?? 'N/A',
                                              style: TextStyle(fontSize: 22, color: Colors.black54),
                                            ),
                                            SizedBox(height: 12),

                                            // درجة الحرارة الرئيسية مع F/C + لون
                                            Obx(() => Text(
                                              '${(controller.currentWeatherData?.main?.temp ?? 0).round()}°${controller.currentUnit.value}',
                                              style: TextStyle(
                                                fontSize: 48,
                                                fontWeight: FontWeight.bold,
                                                color: controller.currentUnit.value == 'F'
                                                    ? Colors.orange[800]
                                                    : Colors.blue[800],
                                              ),
                                            )),

                                            SizedBox(height: 8),

                                            // Min / Max مع F/C
                                            Obx(() => Text(
                                              'min: ${(controller.currentWeatherData?.main?.tempMin ?? 0).round()}°${controller.currentUnit.value} | '
                                              'max: ${(controller.currentWeatherData?.main?.tempMax ?? 0).round()}°${controller.currentUnit.value}',
                                              style: TextStyle(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.w500),
                                            )),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(
                                              width: 130,
                                              height: 130,
                                              child: Lottie.asset(Images.cloudyAnim),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Wind ${controller.currentWeatherData?.wind?.speed?.toStringAsFixed(1) ?? '0'} m/s',
                                              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Other cities + 24-hour forecast
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Other Cities'.toUpperCase(),
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                            IconButton(
                              icon: Icon(Icons.settings, color: Colors.black45),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SettingsPage()),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        MyList(),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Next 24 Hours'.toUpperCase(),
                              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            Icon(Icons.access_time_filled, color: Colors.blue[700], size: 28),
                          ],
                        ),
                        SizedBox(height: 12),
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: MyChart(),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue[700],
        onTap: (index) {
          _currentIndex = index;
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => FavoritesPage()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// Extension عشان capitalize
extension StringExtension on String? {
  String get capitalize {
    if (this == null || this!.isEmpty) return 'N/A';
    return this![0].toUpperCase() + this!.substring(1);
  }
}

Color getTempColor(double tempC) {
  if (tempC >= 35) return Colors.red[800]!;
  if (tempC >= 30) return Colors.orange[800]!;
  if (tempC >= 25) return Colors.orange[600]!;
  if (tempC >= 20) return Colors.yellow[700]!;
  if (tempC >= 15) return Colors.lightBlue[600]!;
  if (tempC >= 10) return Colors.blue[600]!;
  if (tempC >= 0)  return Colors.blue[800]!;
  return Colors.indigo[900]!;
}