import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert' as convert;
import 'package:writing_learner/provider/question_provider.dart';

final strProvider = Provider((ref) {
  return 'Hello Riverpod';
});

class GenerativeService {
  Future<String> generateText(String prompt, bool json, var temperature) async {
    const int maxRetries = 4;
    int retryCount = 0;
    bool success = false;
    var output;

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
    while (retryCount < maxRetries && !success) {
      try {
        // Replace with your actual request logic
        final response = await model.generateContent(content);
        success = true;
        output = response.text!;
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

  Future<Map<String, dynamic>> generateFillingQuestion() async {
    var scheme = """
{Japanese Sentence: "", English Sentence: "", Filling Question: ""}
    """;
    var prompt = """
    Task: Generate Japanse sentence for a difficult Japanese university entrance exam, its English translation, and the same translation with a blank space ___ in important expressions for English learners. The sentence should be a random output of a sentence that can be used for university entrance exams. Output Japanse sentence, its English translation, and the same translation with a blank space ___ in important expressions for English learners.
  Using this JSON schema:
    Map<String, dynamic> scheme = ${scheme.toString()}
  Return scheme
  """;

    final output = await generateText(prompt, true, 0.5);

    return convert.jsonDecode(output);
  }

  Future<Map<String, dynamic>> generateFillingPatternQuestion(
      var patternData) async {
    var scheme = """
{Japanese Sentence: "", English Sentence: "", Filling Question: ""}
    """;
    var prompt = """
  Task: Generate Japanse sentence for a difficult Japanese university entrance exam, its English translation, and the same translation replacing each important expression for English learners with a blank space ___. The sentence should be a random output of a sentence that can be used for university entrance exams. 
  Note: Use expression: $patternData
  Using this JSON schema:
    Map<String, dynamic> scheme = ${scheme.toString()}
  Return scheme
  """;

    final output = await generateText(prompt, true, 0.5);

    Map<String, dynamic> result = convert.jsonDecode(output);
    return result;
  }

  Future<String> generateTranslationQuestion(var levelStr) async {
    var prompt = '$levelStr大学入試対策になるような英訳問題の和文をランダムに出力して。ただし問題の和文のみ一文を出力すること。';
    var response = await generateText(prompt, false, 1.0);
    return response;
  }

//TODO:ここの精度と応答速度を出すか：小さいモデルでファインチューニングするか、グチャグチャな文章でどう出すか、問題生成
//TODO:
  Future<List<Map<String, dynamic>>> generateReasonMaps(
      List<GrammarError> errors,
      String questionSentence,
      String answeredSentence,
      String modifiedSentence) async {
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

    output = await generateText(prompt, true, 0.0);

    reasonMaps = jsonDecode(output).cast<Map<String, dynamic>>();

    return reasonMaps;
  }


  Future<String> generateModifiedSentence(
      var questionSentence, var answerSentence) async {
    var prompt =
        '以下の文章(1)は大学入試の英訳問題(2)の回答である。問題の回答として適切になるように文法と自然な言語使用の観点から修正を加えて。ただし入力が正しい場合は文章(1)を、間違っている場合は修正後の一文のみ答えること。： (1)$answerSentence (2)$questionSentence';
    final output = await generateText(prompt, false, 0.0);
    return output;
  }
}
