import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import '../config/env_config.dart';

class ZiplineService {
  /// Uploads a file to Zipline and returns the URL.
  static Future<String?> uploadFile(PlatformFile file) async {
    try {
      final uri = Uri.parse('${EnvConfig.ziplineBaseUrl}/api/upload');
      final request = http.MultipartRequest('POST', uri)
        ..headers['authorization'] = EnvConfig.ziplineApiToken
        ..headers['Content-Type'] = 'multipart/form-data';

      if (file.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      } else if (file.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path!,
            filename: file.name,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      } else {
        throw Exception('No file data available in PlatformFile');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);

        // Standard Zipline response mapping: { "files": [ "url" ] }
        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse.containsKey('files')) {
          final filesList = jsonResponse['files'] as List;
          if (filesList.isNotEmpty) {
            final firstFile = filesList.first;
            if (firstFile is String) {
              return firstFile;
            } else if (firstFile is Map && firstFile.containsKey('url')) {
              return firstFile['url'] as String;
            }
          }
        }

        // Fallback for direct array response
        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          final first = jsonResponse.first;
          if (first is String) return first;
          if (first is Map && first.containsKey('url')) {
            return first['url'] as String;
          }
        }

        throw Exception(
          'Could not parse URL from Zipline response: ${response.body}',
        );
      } else {
        throw Exception(
          'Zipline upload failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to upload file to storage: $e');
    }
  }
}
