import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

class ChatService {
  /// Send a message to the AI chat backend (Express proxy → n8n)
  ///
  /// Payload matches the web app format:
  /// ```json
  /// { "user": "name", "message": "text", "role": "student",
  ///   "timestamp": "ISO string", "date": "M/D/YYYY" }
  /// ```
  Future<String> sendMessage({
    required String userName,
    required String message,
    required String userRole,
  }) async {
    if (!EnvConfig.isChatConfigured) {
      return 'Chat API is not configured. Please set the chatApiUrl in lib/config/env_config.dart';
    }

    final now = DateTime.now();
    final payload = {
      'user': userName,
      'message': message,
      'role': userRole,
      'timestamp': now.toIso8601String(),
      'date': '${now.month}/${now.day}/${now.year}',
    };

    try {
      final response = await http
          .post(
            Uri.parse(EnvConfig.chatApiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 504) {
        return 'The AI is taking longer than expected. The server timed out while processing your request. Please try again in a moment.\n\nالذكاء الاصطناعي يستغرق وقتًا أطول من المتوقع. انتهت مهلة الخادم أثناء معالجة طلبك. يرجى المحاولة مرة أخرى بعد قليل.';
      }

      if (response.statusCode != 200) {
        return 'Sorry, something went wrong (Error ${response.statusCode}). Please try again.\n\nعذرًا، حدث خطأ ما. يرجى المحاولة مرة أخرى.';
      }

      return _parseResponse(response.body);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return 'The AI is taking longer than expected. The server timed out while processing your request. Please try again in a moment.\n\nالذكاء الاصطناعي يستغرق وقتًا أطول من المتوقع. يرجى المحاولة مرة أخرى بعد قليل.';
      }
      return 'Sorry, I couldn\'t connect to the server. Please check your internet connection and try again.\n\nعذرًا، لم أتمكن من الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';
    }
  }

  /// Parse n8n response — handles multiple formats
  String _parseResponse(String body) {
    try {
      final decoded = jsonDecode(body);

      // Plain string
      if (decoded is String) return decoded;

      // Array — take first element
      if (decoded is List && decoded.isNotEmpty) {
        return _extractFromObject(decoded[0]);
      }

      // Object with known fields
      if (decoded is Map<String, dynamic>) {
        return _extractFromObject(decoded);
      }

      return jsonEncode(decoded);
    } catch (_) {
      // If it's not JSON, return as-is
      return body;
    }
  }

  String _extractFromObject(dynamic obj) {
    if (obj is String) return obj;
    if (obj is Map<String, dynamic>) {
      for (final key in [
        'output',
        'message',
        'text',
        'response',
        'answer',
        'content',
      ]) {
        if (obj.containsKey(key) && obj[key] != null) {
          return obj[key].toString();
        }
      }
      return jsonEncode(obj);
    }
    return obj.toString();
  }
}
