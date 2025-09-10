import 'dart:convert';
import 'package:http/http.dart' as http;

class CarScraperService {
  // Base URL for the Flask API
  // Use 10.0.2.2 for Android emulator, 127.0.0.1 for other platforms
  static const String _baseUrl = 'http://127.0.0.1:5000';

  /// Gets list of supported car websites
  static Future<Map<String, String>> getSupportedSites() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/sites'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return Map<String, String>.from(jsonResponse['sites']);
        } else {
          throw Exception('API Error: ${jsonResponse['error']}');
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: Failed to get supported sites');
      }
    } catch (e) {
      print('❌ Error getting supported sites: $e');
      rethrow;
    }
  }

  /// Scrapes car data from any supported car website using the Flask API
  ///
  /// [url] - The car listing URL to scrape
  ///
  /// Returns a Map containing the scraped car data or throws an exception
  static Future<Map<String, dynamic>> scrapeCar(String url) async {
    try {
      // Validate URL
      if (url.isEmpty) {
        throw Exception('URL cannot be empty');
      }

      // Construct the API endpoint URL
      final apiUrl =
          Uri.parse('$_baseUrl/scrape?url=${Uri.encodeComponent(url)}');

      print('🚀 Sending request to: $apiUrl');

      // Make the HTTP GET request
      final response = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('📡 Response status: ${response.statusCode}');

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Check if the API call was successful
        if (jsonResponse['success'] == true) {
          print('✅ Car data scraped successfully');
          return jsonResponse['data'];
        } else {
          throw Exception('API Error: ${jsonResponse['error']}');
        }
      } else {
        // Handle HTTP error status codes
        final errorBody = json.decode(response.body);
        throw Exception(
            'HTTP ${response.statusCode}: ${errorBody['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('❌ Error scraping car data: $e');
      rethrow;
    }
  }

  /// Test the API connection
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('❌ API connection test failed: $e');
      return false;
    }
  }
}
