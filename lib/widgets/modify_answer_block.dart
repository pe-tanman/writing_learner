// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/provider/is_answered_privider.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:writing_learner/themes/app_color.dart';
import 'package:writing_learner/utilities/generative_service.dart';
import 'package:writing_learner/widgets/suggestion_card.dart';

class ModifiedAnswerRichText extends ConsumerStatefulWidget {
  final int page;
  ModifiedAnswerRichText({super.key, required this.page});

  @override
  ConsumerState<ModifiedAnswerRichText> createState() =>
      ModifiedAnswerRichTextState(page);
}

class ModifiedAnswerRichTextState
    extends ConsumerState<ModifiedAnswerRichText> {
  ModifiedAnswerRichTextState(this.page);

  final int page;
  final List<GrammarError> _errors = []; //間違いの箇所や理由を記録する
  bool isLoading = true;
  String answeredSentence = '';
  OverlayEntry? _overlayEntry;
  bool isInit = true;

  void _showSuggestionCard(GrammarError error) {
    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _overlayEntry!.remove();
    }
    _overlayEntry = _createOverlayEntry(error);
    Overlay.of(context)?.insert(_overlayEntry!);
  }

//理由を表示するカード
  OverlayEntry _createOverlayEntry(GrammarError error) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          if (_overlayEntry != null) {
            _overlayEntry?.remove();
          }
        },
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: offset.dy + size.height + 5.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: SuggestionCard(
                      suggestion: error.suggestion,
                      errorTag: GrammarError.toErrorType(error.type),
                      reason: error.detailedReason,
                      onApply: () {
                        _overlayEntry?.remove();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _findNextMatch(
      List<String> words1, List<String> words2, int start1, int start2) {
    for (int k = start2; k < words2.length; k++) {
      if (words1.contains(words2[k])) {
        return k;
      }
    }
    return -1;
  }

//答え合わせの時のRichTextを生成する。ついでにaddReasonToErrorsも呼び出す
  List<InlineSpan> answerSpans(String answerSentence, String modifiedSentence) {
    List<InlineSpan> answerSpans = [];

    // Define the error array
    List<GrammarError> errorArray = ref.read(questionDataProvider)[page].errors;

    // Process the answer sentence
    int currentIndex = 0;
    for (var error in errorArray) {
      String originalPhrase = error.original;
      int originalStartIndex =
          answerSentence.indexOf(originalPhrase, currentIndex);

      if (originalStartIndex != -1) {
        // Add text before the original phrase
        if (originalStartIndex > currentIndex) {
          answerSpans.add(TextSpan(
            text: answerSentence.substring(currentIndex, originalStartIndex),
            style: const TextStyle(
              fontSize: 15,
              decoration: TextDecoration.none,
              color: Colors.black,
            ),
          ));
        }

        // Add the original phrase with underline
        answerSpans.add(TextSpan(
          text: originalPhrase,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.accentTextColor,
          ),
        ));

        currentIndex = originalStartIndex + originalPhrase.length;
      }
    }

    // Add remaining text in answer sentence
    if (currentIndex < answerSentence.length) {
      answerSpans.add(TextSpan(
        text: answerSentence.substring(currentIndex),
        style: const TextStyle(
          fontSize: 15,
          decoration: TextDecoration.none,
          color: Colors.black,
        ),
      ));
    }

    // Process the modified sentence

    return answerSpans;
  }

  List<InlineSpan> modifiedSpans(
      String answerSentence, String modifiedSentence) {
    var errorArray = ref.read(questionDataProvider)[page].errors;
    var modifiedSpans = <InlineSpan>[];
    var currentIndex = 0;
    for (var error in errorArray) {
      String suggestedPhrase = error.suggestion;
      int suggestedStartIndex =
          modifiedSentence.indexOf(suggestedPhrase, currentIndex);

      if (suggestedStartIndex != -1) {
        // Add text before the suggested phrase
        if (suggestedStartIndex > currentIndex) {
          modifiedSpans.add(TextSpan(
            text: modifiedSentence.substring(currentIndex, suggestedStartIndex),
            style: const TextStyle(
              fontSize: 15,
              decoration: TextDecoration.none,
              color: Colors.black,
            ),
          ));
        }

        // Add the suggested phrase with underline
        modifiedSpans.add(TextSpan(
          text: suggestedPhrase,
          style: TextStyle(
            fontSize: 15,
            decoration: TextDecoration.underline,
            color: AppColors.accentTextColor,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _showSuggestionCard(error);
            },
        ));

        currentIndex = suggestedStartIndex + suggestedPhrase.length;
      }
    }

    // Add remaining text in modified sentence
    if (currentIndex < modifiedSentence.length) {
      modifiedSpans.add(TextSpan(
        text: modifiedSentence.substring(currentIndex),
        style: const TextStyle(
          fontSize: 15,
          decoration: TextDecoration.none,
          color: Colors.black,
        ),
      ));
    }

    return modifiedSpans;
  }

//questionDataが正確に呼び出せなかった時に再実行する
  Future<void> laterReadQuestionData() async {
    Future.delayed(Duration(seconds: 2), () {
      var isAnswered = ref.watch(isAnsweredProvider);
      if (isAnswered) {
        setState(() {
          isLoading = (ref.watch(questionDataProvider)[page].modified == '');
        });
        print(ref.watch(questionDataProvider));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var questionData = ref.watch(questionDataProvider)[page];
    setState(() {
      isLoading = (ref.watch(questionDataProvider)[page].modified == '');
    });
    if (isLoading) {
      laterReadQuestionData();
    }
    return isLoading
        ? const CircularProgressIndicator()
        : Column(
            children: [
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: answerSpans(questionData.answer, questionData.modified),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Icon(Icons.keyboard_double_arrow_down_rounded,
                    size: 50, color: AppColors.themeColor),
              ),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: modifiedSpans(questionData.answer, questionData.modified)
                ),
              ),
            ],
          );
  }
}
