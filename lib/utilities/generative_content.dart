import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translator/translator.dart';
import 'dart:convert' as convert;

final strProvider = Provider((ref) {
  return 'Hello Riverpod';
});

class GenerativeService {
  Future<String> invokeAPI(String prompt, bool json, var temperature) async {
    await dotenv.load(fileName: '.env');
    String apiKey = dotenv.get('GEMINI_API_KEY');
    if (json) {}
    GenerationConfig config = GenerationConfig(
        temperature: temperature,
        topP: 1.0,
        responseMimeType: json ? 'application/json' : 'text/plain',
        stopSequences: ['\n']);

    final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
        generationConfig: config);
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
        output = await invokeAPI(prompt, false, 1.0);
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

  Future <Map<String, dynamic>>  generateFillingQuestion() async{
    var scheme = """
{Japanese Sentence: "", English Sentence: "", Filling Question: ""}
    """;
    var prompt = """
    Task: Generate Japanse sentence for a difficult Japanese university entrance exam, its English translation, and the same translation with a blank space ___ in important expressions for English learners. The sentence should be a random output of a sentence that can be used for university entrance exams. Output Japanse sentence, its English translation, and the same translation with a blank space ___ in important expressions for English learners.
  Using this JSON schema:
    Map<String, dynamic> scheme = ${scheme.toString()}
  Return scheme
  """;
    var output = await invokeAPI(prompt, true, 0.0);
    return convert.jsonDecode(output);
  }

  Future <Map<String, dynamic>>  generateFillingPatternQuestion(var patternData) async{
    var scheme = """
{Japanese Sentence: "", English Sentence: "", Filling Question: ""}
    """;
    var prompt = """
  Task: Generate Japanse sentence for a difficult Japanese university entrance exam, its English translation, and the same translation with a blank space ___ each word in important expressions for English learners. The sentence should be a random output of a sentence that can be used for university entrance exams. 
  Note: Use expression: $patternData
  Using this JSON schema:
    Map<String, dynamic> scheme = ${scheme.toString()}
  Return scheme
  """;
var output = await invokeAPI(prompt, true, 0.0);
Map<String, dynamic> result = convert.jsonDecode(output);
    return result;
  }

  Future<List<Map<String, dynamic>>> generateReasonMaps (
      List<GrammarError> errors,
      String questionSentence,
      String answeredSentence,
      String modifiedSentence) async {
    const int maxRetries = 4;
    int retryCount = 0;
    bool success = false;
    String output = '';
    List<Map> scheme = [{}];
    List<Map<String, dynamic>> reasonMaps = [{}];

    for (var error in errors) {
      scheme.add({
        'original:': error.oritinalStr,
        'suggestion': error.suggestedStr,
        'reason': 'reason'
      });
    }

    var prompt = """
  Question: $questionSentence
  Answer: $answeredSentence
  Modified Answer: $modifiedSentence

Task: Replace 'reason' with brief reason in Japanese why 'original was modified to suggestion in the Answer to the translation Japanese to English Question.

  Using this JSON schema:
    List<Map> error = ${scheme.toString()}
  Return error
  """;

    while (retryCount < maxRetries && !success) {
      try {
        // call json api
        output = await invokeAPI(prompt, true, 0.0);

        reasonMaps =
            jsonDecode(output).cast<Map<String, dynamic>>();
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

    return reasonMaps;
  }

  Future<String> translate(String input) async {
    var translator = GoogleTranslator();
    var translation = await translator.translate(input, from: 'ja', to: 'en');
    return translation.text;
  }

  Future<void> makeRequest() async {
    // Simulate a request to an overloaded service
    throw Exception('The model is overloaded. Please try again later.');
  }
}

class GrammarError {
  final int start;
  final int end;
  final List<String> original;
  final List<String> suggestion;
  String oritinalStr;
  String suggestedStr;
  String reason = '';

  GrammarError(
      {required this.start,
      required this.end,
      required this.original,
      required this.suggestion})
      : oritinalStr = original.join(' '),
        suggestedStr = suggestion.join(' ');
}
