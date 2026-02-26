import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  static late final GenerativeModel _model;
  static ChatSession? _chatSession;

  static void initialize() {
    if (_apiKey.isEmpty) {
      debugPrint('Warning: No GEMINI_API_KEY found in .env file.');
      return;
    }

    _chatSession = null;

    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);

    // Create a new chat session to maintain conversation history
    _chatSession = _model.startChat();
  }

  static Future<String> sendMessage(String message) async {
    if (_apiKey.isEmpty) {
      return 'Error: API key is missing. Please check your .env configuration.';
    }

    if (_chatSession == null) {
      initialize();
    }

    try {
      final response = await _chatSession!.sendMessage(Content.text(message));
      return response.text ?? 'I apologize, but I received an empty response.';
    } catch (e) {
      debugPrint('Gemini API Error: $e');
      return 'Error encountered: $e';
    }
  }
}
