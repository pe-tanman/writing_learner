// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writing_learner/provider/is_answered_privider.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:writing_learner/themes/app_color.dart';
import 'package:writing_learner/utilities/generative_content.dart';
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
  final List<GrammarError> _errors = [];
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
                      suggestion: error.suggestedStr,
                      reason: error.reason,
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

  List<InlineSpan> spans(
      String answerSentence, String modifiedSentence, bool suggestionReason) {
    List<String> words1 = answerSentence.split(' ');
    List<String> words2 = modifiedSentence.split(' ');
    List<InlineSpan> spans = [];

    int i = 0, j = 0;
    while (i < words1.length || j < words2.length) {
      if (i < words1.length && j < words2.length && words1[i] == words2[j]) {
        //matching
        spans.add(TextSpan(
            text: '${words2[j]} ',
            style: const TextStyle(
                fontSize: 15,
                decoration: TextDecoration.none,
                color: Colors.black)));
        i++;
        j++;
      } else {
        // Find the next matching word
        int nextMatch = _findNextMatch(words1, words2, i, j);

        if (nextMatch == -1 || words1.indexOf(words2[nextMatch], i) == -1) {
          // No more matches, add all remaining words with underline
          GrammarError error = GrammarError(
              start: j,
              end: words2.length - 1,
              original: words1.sublist(i, words1.length),
              suggestion: words2.sublist(j, words2.length));
          _errors.add(error);

          while (j < words2.length) {
            spans.add(TextSpan(
              text: '${words2[j]} ',
              style: TextStyle(
                  color: AppColors.accentTextColor,
                  fontSize: 15,
                  decoration:
                      suggestionReason ? TextDecoration.underline : null),
              recognizer: TapGestureRecognizer()
                ..onTap = suggestionReason
                    ? () {
                        _showSuggestionCard(error);
                      }
                    : null,
            ));
            j++;
          }

          break;
        } else {
          GrammarError error = GrammarError(
              start: j,
              end: nextMatch,
              original: words1.sublist(i, words1.indexOf(words2[nextMatch], i)),
              suggestion: words2.sublist(j, nextMatch));
          _errors.add(error);

          while (j < nextMatch) {
            spans.add(TextSpan(
              text: '${words2[j]} ',
              style: TextStyle(
                  color: AppColors.accentTextColor,
                  fontSize: 15,
                  decoration:
                      suggestionReason ? TextDecoration.underline : null),
              recognizer: TapGestureRecognizer()
                ..onTap = suggestionReason
                    ? () {
                        _showSuggestionCard(error);
                      }
                    : null,
            ));
            j++;
          }
          i = words1.indexOf(words2[nextMatch], i);
        }
      }
    }
    if (ref.read(questionDataProvider)[page].wrongWordsCount > 0) {
      addReasonToErrors();
    }

    return spans;
  }

  Future<void> addReasonToErrors() async {
    String questionSentence = ref.watch(questionDataProvider)[page].question;
    String answerSentence = ref.watch(questionDataProvider)[page].answer;
    String modifiedSentence = ref.watch(questionDataProvider)[page].modified;

    var reasons = await GenerativeService().generateReasonMaps(
        _errors, questionSentence, answerSentence, modifiedSentence);
        
    for (int i = 0; i <=reasons.length-1; i++) {
      _errors[i].reason = reasons[i]['reason'];
    }
  }

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
                  children:
                      spans(questionData.modified, questionData.answer, false),
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
                  children:
                      spans(questionData.answer, questionData.modified, true),
                ),
              ),
            ],
          );
  }
}
