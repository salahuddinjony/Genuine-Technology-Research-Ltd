import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/customer_model.dart';
import '../services/api_service.dart';
import 'package:shimmer/shimmer.dart';

class CustomerDetailsScreen extends StatelessWidget {
  const CustomerDetailsScreen({Key? key}) : super(key: key);

  void _launchPhone(BuildContext context, String? phone) async {
    if (phone != null && phone.isNotEmpty) {
      final uri = Uri(scheme: 'tel', path: phone);
      print('Trying to launch phone URI: $uri');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This feature is not available on the emulator. Please test on a real device.')),
        );
      }
    }
  }

  void _launchMail(BuildContext context, String? email) async {
    if (email != null && email.isNotEmpty) {
      final uri = Uri.parse('mailto:$email');
      print('Trying to launch mail URI: $uri');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This feature is not available on the emulator. Please test on a real device.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final CustomerModel customer = Get.arguments as CustomerModel;
    // Simulate loading state for demonstration. Replace with real loading logic if needed.
    final bool isLoading = false; // Set to true to see shimmer effect
    return Scaffold(
      appBar: AppBar(title: Text(customer.name)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cover image with overlay
            isLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity,
                      height: 260,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: 260,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Stack(
                      children: [
                        // Image as cover
                        Positioned.fill(
                          child: customer.imagePath != null && customer.imagePath!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: ApiService.getEncodedImageUrl(customer.imagePath),
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[200],
                                    child: const Center(child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.error, size: 80),
                                  ),
                                )
                              : Center(
                                  child: CircleAvatar(
                                    radius: 48,
                                    backgroundColor: Colors.grey[400],
                                    child: Text(
                                      customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                                      style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                        ),
                        // Overlay info at bottom
                      ],
                    ),
                  ),
            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (customer.phone != null && customer.phone!.isNotEmpty)
                    _ActionButton(
                      icon: Icons.phone,
                      label: 'Call',
                      onTap: () => _launchPhone(context, customer.phone),
                      color: Colors.green,
                    ),
                  if (customer.email != null && customer.email!.isNotEmpty)
                    _ActionButton(
                      icon: Icons.email,
                      label: 'Mail',
                      onTap: () => _launchMail(context, customer.email),
                      color: Colors.blue,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Details card
            isLoading
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (customer.email != null && customer.email!.isNotEmpty)
                              _DetailRow(icon: Icons.email, label: 'Email', value: customer.email!),
                            if (customer.phone != null && customer.phone!.isNotEmpty)
                              _DetailRow(icon: Icons.phone, label: 'Phone', value: customer.phone!),
                            if (customer.primaryAddress != null && customer.primaryAddress!.isNotEmpty)
                              _DetailRow(icon: Icons.home, label: 'Address', value: customer.primaryAddress!),
                            if (customer.secoundaryAddress != null && customer.secoundaryAddress!.isNotEmpty)
                              _DetailRow(icon: Icons.location_on, label: 'Secondary Address', value: customer.secoundaryAddress!),
                            if (customer.notes != null && customer.notes!.isNotEmpty)
                              _DetailRow(icon: Icons.note, label: 'Notes', value: customer.notes!),
                            if (customer.totalDue != null)
                              _DetailRow(icon: Icons.attach_money, label: 'Total Due', value: customer.totalDue!.toStringAsFixed(2)),
                            if (customer.lastTransactionDate != null && customer.lastTransactionDate!.isNotEmpty)
                              _DetailRow(icon: Icons.calendar_today, label: 'Last Transaction', value: customer.lastTransactionDate!),
                          ],
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _ActionButton({required this.icon, required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueGrey, size: 22),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
} 