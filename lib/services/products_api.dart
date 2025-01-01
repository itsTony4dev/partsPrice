import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pcparts/services/login_api.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  final String category;

  Product(this.id, this.name, this.price, this.image, this.category);

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      json['_id'] as String,
      json['name'] as String,
      (json['price'] as num).toDouble(),
      json['image'] as String,
      json['category'] as String,
    );
  }

  @override
  String toString() => name;
}

class ProductsApi {
  static Future<List<Product>> getProducts() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/products/'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        if (jsonData.containsKey('products') && jsonData['products'] is List) {
          final productsList = (jsonData['products'] as List)
              .map((productJson) =>
                  Product.fromJson(productJson as Map<String, dynamic>))
              .toList();
          return productsList;
        } else {
          debugPrint(
              'Invalid response format: missing or invalid products array');
          throw FormatException('Invalid response format');
        }
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      debugPrint('Error loading products: ${e.toString()}');
      rethrow;
    }
  }

  static Future<int> build(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/build/'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': LoginApi.cookies.entries
              .map((e) => '${e.key}=${e.value}')
              .join('; '),
        },
        body: jsonEncode(data),
      );

      return response.statusCode;
    } catch (e) {
      debugPrint('Error creating build: ${e.toString()}');
      rethrow;
    }
  }


  static Future<List<Map<String, dynamic>>> getBuilds() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/build'),
        headers: {
          'Cookie': LoginApi.cookies.entries
              .map((e) => '${e.key}=${e.value}')
              .join('; '),
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        List<dynamic> buildsData = jsonResponse['builds'];

        List<Map<String, dynamic>> builds =
            buildsData.map((build) => build as Map<String, dynamic>).toList();

        return builds;
      } else {
        throw Exception('Failed to load builds');
      }
    } catch (e) {
      debugPrint('Error loading builds: ${e.toString()}');
      rethrow;
    }
  }


  static Future<bool> deleteBuild(String buildId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/build/$buildId'),
        headers: {
          'Cookie': LoginApi.cookies.entries
              .map((e) => '${e.key}=${e.value}')
              .join('; '),
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Build not found');
      } else {
        throw Exception('Failed to delete build');
      }
    } catch (e) {
      debugPrint('Error deleting build: ${e.toString()}');
      rethrow;
    }
  }
}
