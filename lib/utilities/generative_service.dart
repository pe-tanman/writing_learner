import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

class GenerativeService {
  Future<String> generateText(String prompt, bool json, var temperature,
      [Map? jsonScheme]) async {
    //gemini
    /*
     const int maxRetries = 4;
    int retryCount = 0;
    bool success = false;
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
*/
//gpt
    await dotenv.load(fileName: '.env');
    String apiKey = dotenv.get('OPENAI_API_KEY');
    const domain = 'api.openai.com';
    const path = 'v1/chat/completions';
    http.Response response;
    var output;

    if (json && jsonScheme != null) {
      response = await http.post(
        Uri.https(domain, path),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a helpful and kind English Tutor for Japanese Student. Appropriately use Japanese and English following instructions."
            },
            {"role": "user", "content": prompt}
          ],
          "temperature": temperature,
          "response_format": {"type": "json_schema", "json_schema": jsonScheme}
        }),
      );
    } else {
      response = await http.post(
        Uri.https(domain, path),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a helpful English Tutor for Japanese Student. Appropriately use Japanese and English following instructions."
            },
            {"role": "user", "content": prompt}
          ],
          "temperature": temperature,
        }),
      );
    }
    if (response.statusCode == 200) {
      String responseData = utf8.decode(response.bodyBytes).toString();
      var data = convert.jsonDecode(responseData);
      output = data['choices'][0]['message']['content'];
    } else {
      output = 'Error: ${response.statusCode}';
    }

    return output;
  }

  Future<Map<String, dynamic>> generateFillingQuestion() async {
    var jsonScheme = {
      "name": "query",
      "description": "Output the filling_question",
      "strict": true,
      "schema": {
        "type": "object",
        "properties": {
          "filling_question": {
            "type": "object",
            "properties": {
              "Japanese_sentence": {
                "type": "string",
                "description":
                    "A Japanese sentence that can be used for difficult university entrance exams in Japan."
              },
              "English_sentence": {
                "type": "string",
                "description": "The translation of the Japanese sentence."
              },
              "filling_question": {
                "type": "string",
                "description":
                    "Replace the important words or phrases with a blank space ___"
              }
            },
            "required": [
              "Japanese_sentence",
              "English_sentence",
              "filling_question"
            ],
            "additionalProperties": false
          }
        },
        "required": ['filling_question'],
        "additionalProperties": false
      }
    };

    var prompt = """
    Task: Generate Japanse sentence for a difficult Japanese university entrance exam, its English translation, and the same English translation with a blank space ___ in important expressions for English learners. The sentence should be a random output of a sentence that can be used for university entrance exams. Output Japanse sentence, its English translation, and the same translation with a blank space ___ in important expressions for English learners.
  Using this JSON schema

  For example:  "schema":{"Japanese_sentence":"調理は、事実上、噛んで消化するという作業の一部を引き受け、外部のエネルギー源を用いて、われわれの身体の外部で、それを遂行してくれたのである。","English_sentence":"Cooking, in effect, took part of the work of chewing and digesting and carried it out outside our bodies, using an external energy source.","Filling_question":"Cooking, in effect, took ___ of the work of ___ and ___ and ___ it ___ outside our bodies, using an ___ energy source."}
  """;

    final output = await generateText(prompt, true, 0.5, jsonScheme);
    var output_Map = convert.jsonDecode(output)['filling_question'];
    return output_Map;
  }

  Future<Map<String, dynamic>> generateFillingPatternQuestion(
      var patternData) async {
    Map scheme = {
      "Japanese Sentence": {"type": "String"},
      "English Sentence": {"type": "String"},
      "Filling Question": {"type": "String"}
    };
    var jsonScheme = {
      "type": "function",
      "function": {
        "name": "query",
        "description": "output the question objet",
        "strict": true,
        "error_array": {"type": "object", "properties": scheme},
        "required": ["original", "suggestion", "reason"],
        "additionalProperties": false
      }
    };
    var prompt = """
  Task: Generate Japanse sentence for a difficult Japanese university entrance exam, its English translation, and the same translation replacing each important expression for English learners with a blank space ___. The sentence should be a random output of a sentence that can be used for university entrance exams. 
  Note: Use expression: $patternData
  """;

    final output = await generateText(prompt, true, 0.5, jsonScheme);

    Map<String, dynamic> result = convert.jsonDecode(output);
    return result;
  }

  Future<String> generateTranslationQuestion(var levelStr) async {
    var example = '';
    if (levelStr == "Tokyo") {
      example =
          "調理は、事実上、噛んで消化するという作業の一部を引き受け、外部のエネルギー源を用いて、われわれの身体の外部で、それを遂行してくれたのである。";
    } else if (levelStr == 'Nagoya') {
      example = '趣味に専念することによって、より深い人生観が生まれるのです';
    }
    var prompt =
        'Task: Generate Japanse sentence for a translation(Japanese to English) task in $levelStr University entrance exam. Example:$example  Note: You must output only the Japanese question sentence without any reaction.';
    var response = await generateText(prompt, false, 1.0);
    return response;
  }

  Future<Map<String, dynamic>> generateReasonMaps(
      String questionSentence, String answeredSentence) async {
    String output = '';
    Map<String, dynamic> reasonMaps = {};
/*
    for (var error in errors) {
      scheme.add({
        'original:': error.oritinalStr,
        'suggestion': error.suggestedStr,
        'reason': {"type": "string"}
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
  */
    var prompt = """
  Question: $questionSentence
Answer:  $answeredSentence

Task: Modify the answer to be appropriate as a translation of the Question. Then list the original parts, the suggested parts, and the reason as a form of an array. 
Note: the suggested_phrase mut be in English, and the reason must be in Japanese.

For example:  "error_array": [
    {
      "original_phrase": "is",
      "suggested_phrase": "has",
      "reason": "現在完了形の方が文脈に即す。"
    },
 {
      "original_phrase": "",
      "suggested_phrase": "for",
      "reason": "for breakfastが正しい表現"
    }
  ],
  "modified_sentence": "He has not decided what to eat for breakfast yet."  """;
    /*
    for (var error in errors) {
      scheme.add({
        "type": "object",
        "properties": {
          "original": {"type": "string"},
          "suggestion": {"type": "string"},
          "reason": {"type": "string"}
        }
      });
    }*/
    var jsonScheme = {
      "name": "query",
      "description": "Output the array 'error_phrases'",
      "strict": true,
      "schema": {
        "type": "object",
        "properties": {
          "error_array": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "original_phrase": {
                  "type": "string",
                  "description":
                      "A original English word or phrase that is suggested to be replaced."
                },
                "suggested_phrase": {
                  "type": "string",
                  "description":
                      "A suggested English word or phrase to replace the original."
                },
                "reason": {
                  "type": "string",
                  "description":
                      "The reason for the suggested replacement in Japanese."
                }
              },
              "required": ["original_phrase", "suggested_phrase", "reason"],
              "additionalProperties": false
            }
          },
          "modified_sentence": {
            "type": "string",
            "description":
                "The sentence after all modifications have been applied."
          }
        },
        "required": ["error_array", "modified_sentence"],
        "additionalProperties": false
      }
    };

    output = await generateText(prompt, true, 0.0, jsonScheme);
    print(output);
    reasonMaps = jsonDecode(output);

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
