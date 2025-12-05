// home_binding.dart   ← ملف منفصل أو داخل bindings/

import 'package:get/get.dart';
import 'package:weather_app/controller/HomeController.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}