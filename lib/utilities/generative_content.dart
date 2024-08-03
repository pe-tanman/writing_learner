import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final strProvider = Provider((ref) {
  return 'Hello Riverpod';
});

class GenerativeService {
  Future<String> invokeAPI(String prompt) async {
    await dotenv.load(fileName: '.env');
    String apiKey = dotenv.get('GEMINI_API_KEY');

    final model =
        GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    return response.text!;
  }

  Future<String> generateText(String prompt) async {
    const int maxRetries = 4;
    int retryCount = 0;
    bool success = false;
    String output = '';

    while (retryCount < maxRetries && !success) {
      try {
        // Replace with your actual request logic
        output = await invokeAPI(prompt);
        success = true;
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          output = 'Failed after $maxRetries attempts: $e';
          rethrow;
        } else {
          await Future.delayed(Duration(seconds: 2)); // Wait before retrying
        }
      }
    }
    return output;
  }

  Future<void> makeRequest() async {
    // Simulate a request to an overloaded service
    throw Exception('The model is overloaded. Please try again later.');
  }
}
