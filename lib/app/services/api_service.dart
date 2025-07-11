import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/customer_model.dart';

class ApiService {
  static const String baseLink = "https://www.pqstec.com/InvoiceApps/Values/";
  static const String imageBaseLink = "https://www.pqstec.com/InvoiceApps/";

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Future<UserModel?> login({
    required String userName,
    required String password,
    int comId = 1,
  }) async {
    final url = Uri.parse(
      "${baseLink}LogIn?UserName=$userName&Password=$password&ComId=$comId",
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Adjust parsing as per actual API response
      return UserModel.fromJson(data);
    } else {
      throw Exception('Login failed: ${response.reasonPhrase}');
    }
  }

  Future<List<CustomerModel>> getCustomerList({
    String searchQuery = '',
    int pageNo = 1,
    int pageSize = 20,
    String sortBy = 'Balance',
  }) async {
    final url = Uri.parse(
      "${baseLink}GetCustomerList?searchquery=$searchQuery&pageNo=$pageNo&pageSize=$pageSize&SortyBy=$sortBy",
    );
    print('getCustomerList called. _token: $_token');
    final headers = <String, String>{};
    if (_token != null) {
      print('Using token: $_token');
      headers['Authorization'] = 'Bearer $_token'; // or just _token! if your API expects that
    }
    print('Request headers: $headers');
    final response = await http.get(url, headers: headers);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map && data.containsKey('CustomerList')) {
        final list = data['CustomerList'] as List;
        return list.map((e) => CustomerModel.fromJson(e)).toList();
      } else {
        throw Exception('Unexpected customer list format');
      }
    } else {
      throw Exception('Failed to load customers: ${response.reasonPhrase}');
    }
  }

  static String getEncodedImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    final lastSlash = imagePath.lastIndexOf('/');
    if (lastSlash == -1) return imageBaseLink + Uri.encodeComponent(imagePath);
    final path = imagePath.substring(0, lastSlash + 1);
    final file = imagePath.substring(lastSlash + 1);
    return imageBaseLink + path + Uri.encodeComponent(file);
  }
} 