import 'package:get/get.dart';
import '../models/customer_model.dart';
import '../services/api_service.dart';

class CustomerController extends GetxController {
  final ApiService apiService;
  CustomerController(this.apiService);

  var customers = <CustomerModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var pageNo = 1.obs;
  var hasMore = true.obs;

  Future<void> fetchCustomers({bool isRefresh = false}) async {
    if (isLoading.value) return;
    if (isRefresh) {
      pageNo.value = 1;
      customers.clear();
      hasMore.value = true;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await apiService.getCustomerList(pageNo: pageNo.value);
      if (result.isEmpty) {
        hasMore.value = false;
      } else {
        if (isRefresh) {
          customers.assignAll(result);
        } else {
          customers.addAll(result);
        }
        pageNo.value++;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
} 