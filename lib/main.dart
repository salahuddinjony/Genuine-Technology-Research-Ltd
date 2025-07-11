import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/bindings/initial_binding.dart';
import 'app/routes/app_routes.dart';
import 'app/screens/login_screen.dart';
import 'app/screens/customer_list_screen.dart';
import 'app/screens/customer_details_screen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'app/controllers/auth_controller.dart';
import 'app/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = Get.put(ApiService()); // Register ApiService as a singleton
  final authController = Get.put(AuthController(apiService));
  await authController.tryAutoLogin();

  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Customer App',
    initialBinding: InitialBinding(),
    initialRoute: authController.user.value != null ? AppRoutes.customers : AppRoutes.login,
    getPages: [
      GetPage(
        name: AppRoutes.login,
        page: () => LoginScreen(),
      ),
      GetPage(
        name: AppRoutes.customers,
        page: () => CustomerListScreen(),
        // Optionally add binding if needed
      ),
      GetPage(
        name: AppRoutes.customerDetails,
        page: () => const CustomerDetailsScreen(),
      ),
    ],
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    ),
    builder: EasyLoading.init(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Customer App',
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.login,
      getPages: [
        GetPage(
          name: AppRoutes.login,
          page: () => LoginScreen(),
        ),
        GetPage(
          name: AppRoutes.customers,
          page: () => CustomerListScreen(),
          // Optionally add binding if needed
        ),
        GetPage(
          name: AppRoutes.customerDetails,
          page: () => const CustomerDetailsScreen(),
        ),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}
