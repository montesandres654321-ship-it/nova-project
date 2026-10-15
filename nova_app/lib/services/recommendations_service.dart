import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class RecommendationsService {
  static Future<List<Map<String, dynamic>>> getByMunicipio(
    String municipio,
    String authToken,
  ) async {
    final response = await http.get(
      Uri.parse('${AppConstants.backendUrl}/recommendations/$municipio'),
      headers: {'Authorization': 'Bearer $authToken'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['places']);
    }
    throw Exception('Error ${response.statusCode}');
  }
}
