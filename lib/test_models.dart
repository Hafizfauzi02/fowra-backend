import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  final apiKey = dotenv.env['GEMINI_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    print("No API key found");
    return;
  }

  print("Fetching models for key starting with: ${apiKey.substring(0, 5)}...");

  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey',
  );

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final models = data['models'] as List;

      print("\nAVAILABLE MODELS:");
      for (var model in models) {
        final name = model['name'];
        final methods = model['supportedGenerationMethods'];
        if (methods != null && methods.contains('generateContent')) {
          print("- $name (Supports generateContent)");
        } else {
          print("- $name (Does NOT support generateContent)");
        }
      }
    } else {
      print("Error fetching models: ${response.statusCode}");
      print(response.body);
    }
  } catch (e) {
    print("Exception: $e");
  }
}
