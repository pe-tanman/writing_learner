import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final strProvider = Provider((ref) {
  return 'Hello Riverpod';
});
class GenerativeService {
  Future<String> generateText(String prompt) async {
    await dotenv.load(fileName: '.env');
    String apiKey = dotenv.get('GEMINI_API_KEY');

    final model =
        GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    return response.text!;
  }
  }
