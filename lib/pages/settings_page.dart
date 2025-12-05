
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_app/controller/HomeController.dart';
import 'package:weather_app/service/local_storage_service.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final LocalStorageService _storageService = LocalStorageService();
  final HomeController _homeController = Get.find<HomeController>();

  String temperatureUnit = 'metric';
  String language = 'en';
  bool useGps = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _storageService.getSettings();
    setState(() {
      temperatureUnit = settings['temperatureUnit'] ?? 'metric';
      language = settings['language'] ?? 'en';
      useGps = settings['useGps'] ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final newSettings = {
      'temperatureUnit': temperatureUnit,
      'language': language,
      'useGps': useGps,
    };

    await _storageService.saveSettings(newSettings);

    // إعادة تحميل الطقس فورًا بالوحدة الجديدة
    _homeController.updateWeather();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings saved successfully! Weather updated.'),
        backgroundColor: Colors.green[700],
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _clearAllFavorites() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Clear All Favorites?'),
        content: Text('This will remove all saved cities permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.clearAllFavorites();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All favorites have been cleared'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [

          // Temperature Unit
          Card(
            child: ListTile(
              leading: Icon(Icons.thermostat, color: Colors.orange[700]),
              title: Text('Temperature Unit', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(temperatureUnit == 'metric' ? 'Celsius (°C)' : 'Fahrenheit (°F)'),
              trailing: DropdownButton<String>(
                value: temperatureUnit,
                items: [
                  DropdownMenuItem(value: 'metric', child: Text('Celsius (°C)')),
                  DropdownMenuItem(value: 'imperial', child: Text('Fahrenheit (°F)')),
                ],
                onChanged: (value) => setState(() => temperatureUnit = value!),
              ),
            ),
          ),

          SizedBox(height: 12),

          // Language
          Card(
            child: ListTile(
              leading: Icon(Icons.language, color: Colors.blue[700]),
              title: Text('Language', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(language == 'en' ? 'English' : 'العربية'),
              trailing: DropdownButton<String>(
                value: language,
                items: [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                ],
                onChanged: (value) => setState(() => language = value!),
              ),
            ),
          ),

          SizedBox(height: 12),

          // Use GPS
          Card(
            child: SwitchListTile(
              secondary: Icon(Icons.my_location, color: Colors.green[700]),
              title: Text('Use GPS Location', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Automatically detect your current location'),
              value: useGps,
              onChanged: (value) => setState(() => useGps = value),
            ),
          ),

          SizedBox(height: 24),

          // Clear All Favorites
          Card(
            color: Colors.red[50],
            child: ListTile(
              leading: Icon(Icons.delete_forever, color: Colors.red[700]),
              title: Text('Clear All Favorites', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
              subtitle: Text('Permanently delete all saved cities'),
              onTap: _clearAllFavorites,
            ),
          ),

          SizedBox(height: 32),

          // Save Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              child: Text(
                'Save Settings & Refresh Weather',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }
}