import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class ExamApi {
  static const String _apiUrl = "http://74.248.232.4:5000/generate-from-file";

  static Future<List<Question>> generateExamFromFile(File file) async {
    try {
      print("Sending file to API: ${file.path}");
      var request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        final List<dynamic> examData = data['exam'];
        if (examData.isEmpty) {
          throw Exception(
              "The server returned an empty exam. Please check the file content.");
        }
        return examData.map((jsonData) => Question.fromJson(jsonData)).toList();
      } else {
        final errorBody = await response.stream.bytesToString();
        final errorMessage =
            json.decode(errorBody)['error'] ?? 'Unknown server error';
        throw Exception('Failed to generate exam: $errorMessage');
      }
    } catch (e) {
      // Catch network errors or other exceptions
      throw Exception(
          'Could not connect to the server. Please check your network connection and try again.');
    }
  }
}
