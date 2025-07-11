import 'package:get/get.dart';
import '../services/api_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/customer_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiService());
    Get.put(AuthController(Get.find<ApiService>()));
    Get.put(CustomerController(Get.find<ApiService>()));
  }
} 