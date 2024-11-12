// TODO Implement this library.
import 'dart:convert';
import 'package:http/http.dart' as http;

class SerperService {
  final String apiKey = 'e043c6cc37a639ec8c7b42724d06134d381814c1'; // Replace with your actual API key
  final String baseUrl = 'https://api.serper.dev';

  Future<Map<String, dynamic>> search(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search?q=$query'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load search results');
    }
  }
}
