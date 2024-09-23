import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:writing_learner/provider/database_helper.dart';
import 'package:writing_learner/provider/emoji_converter.dart';
import 'package:writing_learner/screens/w2p_question_view.dart';
import 'package:writing_learner/themes/app_color.dart';
import 'package:writing_learner/themes/app_theme.dart';

class W2pRecordScreen extends StatefulWidget {
  static const routeName = 'w2p-record-screen';
  @override
  _W2pRecordScreenState createState() => _W2pRecordScreenState();
}

class _W2pRecordScreenState extends State<W2pRecordScreen> {
  MaterialDatabaseHelper materialDatabaseHelper = MaterialDatabaseHelper();
  late var currentSection;
  var isLoading = true;
  var isInit = true;
  int materialId = 2;
  Future<void> getCurrentSection() async {
    int nextNum = await materialDatabaseHelper.getNextNum(materialId);
      currentSection = nextNum ~/ 3 - 1;
      setState(() {
        isLoading = false;
        isInit = false;
      });

  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      getCurrentSection();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Write to the Point'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return ProgressStep(
                            step: index,
                            isCompleted: index <
                                currentSection, // Assume steps 1-3 are completed
                            isActive: index ==
                                currentSection, // Assume step 4 is the active step
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    primaryButton('続きから', () {
                      Navigator.of(context)
                          .pushNamed(W2pQuestionView.routeName);
                    }),
                    SizedBox(height: 20),
                    secondaryButton('始めから', () {
                      materialDatabaseHelper.updateNextNumber(0, materialId);
                      Navigator.of(context)
                          .pushNamed(W2pQuestionView.routeName);
                    }),
                    SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}

class ProgressStep extends StatefulWidget {
  final int step;
  final bool isCompleted;
  final bool isActive;

  ProgressStep({
    required this.step,
    required this.isCompleted,
    required this.isActive,
  });

  @override
  _ProgressStepState createState() => _ProgressStepState();
}

class _ProgressStepState extends State<ProgressStep> {
  var accuracyList = [];
  var isInit = true;

  DailyChallengeDatabaseHelper dailyChallengeDatabaseHelper =
      DailyChallengeDatabaseHelper();

  final steps = [
'01 原因の表現',
'02 原因の表現',
'03 原因の表現~時制',
'04 理由',
'05 完了形',
'06 原因の表現',
    '07 原因の表現',
    '08 原因の表現~時制',
    '09 理由',
    '10 完了形',
  ];

  @override
  Widget build(BuildContext context) {
    if (isInit) {
    }
    return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // The circle and vertical line
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top connecting line (except for the first item)
                  if (widget.step > 1)
                    Container(
                      width: 2,
                      height: 30,
                      color: widget.isCompleted || widget.isActive
                          ? AppColors.themeColor
                          : Colors.grey,
                    ),
                  // Circle to represent the step
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isCompleted || widget.isActive
                          ? AppColors.themeColor
                          : Colors.grey,
                    ),
                    child: Text(
                      widget.step.toString(),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Bottom connecting line (except for the last item)
                  if (widget.step < 10)
                    Container(
                      width: 2,
                      height: 30,
                      color: widget.isCompleted || widget.isActive
                          ? AppColors.themeColor
                          : Colors.grey,
                    ),
                ],
              ),
              // Spacing between circle and text
              SizedBox(width: 20),
              // Label or additional information for the step
              Row(
                children: [
                  Text(
                    "${steps[widget.step]}",
                    style: TextStyle(
                      fontWeight:
                          widget.isActive ? FontWeight.bold : FontWeight.normal,
                      color: widget.isActive
                          ? AppColors.accentColor
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          );
  }
}
