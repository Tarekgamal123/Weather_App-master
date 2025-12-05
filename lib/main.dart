import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_app/controller/HomeController.dart';
import 'package:weather_app/pages/home/home_screen.dart';
import 'package:weather_app/utils/env_loader.dart'; // ✅ ADDED

void main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Starting Weather App...');
  
  try {
    // ✅ Load environment variables
    await EnvLoader.load();
    
    // Initialize GetX controller
    Get.put(HomeController());
    
    print('✅ App initialized successfully');
    runApp(MyApp());
    
  } catch (e) {
    print('❌ Failed to initialize app: $e');
    // You could show an error screen here
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 64),
                SizedBox(height: 20),
                Text(
                  'App Configuration Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Please check your assets/.env file and make sure it contains your OpenWeatherMap API key.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => main(),
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Weather Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'flutterfonts',
      ),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
      // Optional: Add named routes
      // getPages: [
      //   GetPage(name: '/home', page: () => HomeScreen()),
      //   GetPage(name: '/favorites', page: () => FavoritesPage()),
      //   GetPage(name: '/settings', page: () => SettingsPage()),
      //   GetPage(name: '/details', page: () => WeatherDetailPage()),
      // ],
    );
  }
}