import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:task_of_genuine_technology/app/screens/profile_screen.dart';
import '../controllers/customer_controller.dart';
import '../services/api_service.dart';
import '../controllers/auth_controller.dart'; // Added import for AuthController
import '../routes/app_routes.dart'; // Added import for AppRoutes
import 'package:shimmer/shimmer.dart';

class CustomerListScreen extends StatelessWidget {
  CustomerListScreen({Key? key}) : super(key: key);

  final ScrollController _scrollController = ScrollController();
  final RxString selectedFilter = 'All'.obs;

  List<String> filterOptions = ['All', 'Active', 'Due'];

  List<dynamic> getFilteredCustomers(CustomerController controller) {
    if (selectedFilter.value == 'All') return controller.customers;
    if (selectedFilter.value == 'Active') {
      // Example: filter by some 'active' property, adjust as needed
      return controller.customers.where((c) => c.totalDue == 0).toList();
    }
    if (selectedFilter.value == 'Due') {
      return controller.customers.where((c) => c.totalDue != null && c.totalDue! > 0).toList();
    }
    return controller.customers;
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final user = authController.user.value;

    if (user == null) {
      // Optionally, redirect to login or show a message
      Future.microtask(() => Get.offAllNamed(AppRoutes.login));
      return const SizedBox.shrink();
    }

    final CustomerController customerController = Get.find<CustomerController>();
    final apiService = Get.find<ApiService>();

    // Fetch customers on first build
    if (customerController.customers.isEmpty && !customerController.isLoading.value) {
      customerController.fetchCustomers(isRefresh: true);
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !customerController.isLoading.value &&
          customerController.hasMore.value) {
        customerController.fetchCustomers();
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Customers', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedFilter.value,
                    items: filterOptions
                        .map((option) => DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) selectedFilter.value = value;
                    },
                    borderRadius: BorderRadius.circular(12),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    icon: const Icon(Icons.filter_list, color: Colors.black),
                    dropdownColor: Colors.white,
                  ),
                ),
              )),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black),
            tooltip: 'Profile',
            onPressed: () {
              print('Profile icon tapped');
              Get.to(ProfileScreen());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (customerController.isLoading.value && customerController.customers.isEmpty) {
            return ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            );
          }
          if (customerController.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                customerController.errorMessage.value,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }
          if (customerController.customers.isEmpty) {
            return const Center(child: Text('No customers found.'));
          }
          final filteredCustomers = getFilteredCustomers(customerController);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _DashboardCard(icon: Icons.people, label: 'Customers', value: filteredCustomers.length.toString(), color: Colors.blue),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DashboardCard(icon: Icons.check_circle, label: 'Active', value: customerController.customers.where((c) => c.totalDue == 0).length.toString(), color: Colors.green),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DashboardCard(icon: Icons.warning, label: 'Due', value: customerController.customers.where((c) => c.totalDue != null && c.totalDue! > 0).length.toString(), color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: filteredCustomers.length + (customerController.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < filteredCustomers.length) {
                      final customer = filteredCustomers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Get.toNamed('/customer_details', arguments: customer);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                customer.imagePath != null && customer.imagePath!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: ApiService.getEncodedImageUrl(customer.imagePath),
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) => const Icon(Icons.error),
                                        ),
                                      )
                                    : Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.person, size: 40, color: Colors.grey),
                                      ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customer.name,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      if (customer.email != null && customer.email!.isNotEmpty)
                                        Text('Email: ${customer.email}', style: const TextStyle(fontSize: 14)),
                                      if (customer.phone != null && customer.phone!.isNotEmpty)
                                        Text('Phone: ${customer.phone}', style: const TextStyle(fontSize: 14)),
                                      if (customer.primaryAddress != null && customer.primaryAddress!.isNotEmpty)
                                        Text('Address: ${customer.primaryAddress}', style: const TextStyle(fontSize: 14)),
                                      if (customer.totalDue != null)
                                        Text('Total Due: ${customer.totalDue!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, color: Colors.deepPurple)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DashboardCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 80),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
          ],
        ),
      ),
    );
  }
} 