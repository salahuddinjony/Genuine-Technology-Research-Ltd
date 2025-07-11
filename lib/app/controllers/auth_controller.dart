import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthController extends GetxController {
  final ApiService apiService;
  AuthController(this.apiService);

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var user = Rxn<UserModel>();

  Future<void> login(String userName, String password, {int comId = 1}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await apiService.login(userName: userName, password: password, comId: comId);
      if (result != null) {
        user.value = result;
        apiService.setToken(result.token);
        // Save token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', result.token ?? '');
        print('Login token: ${result.token}'); // Debug print
      } else {
        errorMessage.value = 'Invalid login response.';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      user.value = UserModel(token: token); // You may want to fetch more user info here
      apiService.setToken(token);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    user.value = null;
  }
} 