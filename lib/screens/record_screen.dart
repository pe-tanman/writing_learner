import 'package:flutter/material.dart';
import 'package:writing_learner/provider/database_helper.dart';
import 'package:writing_learner/provider/emoji_converter.dart';
import 'package:writing_learner/themes/app_color.dart';
import 'package:writing_learner/themes/app_theme.dart';

class ProgressRecordScreen extends StatefulWidget {
  @override
  _ProgressRecordScreenState createState() => _ProgressRecordScreenState();
}

class _ProgressRecordScreenState extends State<ProgressRecordScreen> {
  DailyChallengeDatabaseHelper dailyChallengeDatabaseHelper =
      DailyChallengeDatabaseHelper();
  late var streakCount;
  var isLoading = true;
  var isInit = true;
  Future<void> getStreakCount() async {
    streakCount = await dailyChallengeDatabaseHelper.getStreakCount();
    if (null == streakCount) {
      streakCount = 0;
      setState(() {
        isLoading = false;
        isInit = false;
      });
    } else {
      print(streakCount);
      streakCount -= 1;
      setState(() {
        isLoading = false;
        isInit = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      getStreakCount();
    }
    return Scaffold(
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'デイリーチャレンジ連続記録',
                      style: appTheme().textTheme.headlineMedium,
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: 14,
                        itemBuilder: (context, index) {
                          return ProgressStep(
                            step: index,
                            isCompleted:
                                index < streakCount, // Assume steps 1-3 are completed
                            isActive: index ==
                                streakCount, // Assume step 4 is the active step
                          );
                        },
                      ),
                    ),
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
  var isLoading = true;

  DailyChallengeDatabaseHelper dailyChallengeDatabaseHelper =
      DailyChallengeDatabaseHelper();

  final steps = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
    '13',
    '14'
  ];

  Future<void> accuracyRates() async {
    var streakCount = await dailyChallengeDatabaseHelper.getStreakCount();
    var allData = await dailyChallengeDatabaseHelper.getAllData();
    var result = [];
    if (streakCount != null) {
      for (var i = 0; i < streakCount; i++) {
        result.add(allData[i]['accuracy_rate']);
      }
      result = result.reversed.toList();
      for (var i = streakCount; i < 14; i++) {
        result.add(-1);
      }

      
    }
    else{
      for (var i = 0; i < 14; i++) {
        result.add(-1);
      }
    }
    setState(() {
      accuracyList = result;
      isLoading = false;
      isInit = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      accuracyRates();

      
    }
    return isLoading
        ? CircularProgressIndicator()
        : Row(
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
                      steps[widget.step],
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
                    "Day ${steps[widget.step]}",
                    style: TextStyle(
                      fontWeight:
                          widget.isActive ? FontWeight.bold : FontWeight.normal,
                      color: widget.isActive
                          ? AppColors.accentColor
                          : Colors.black,
                    ),
                  ),
                  isLoading
                      ? CircularProgressIndicator()
                      : Text(
                          EmojiConverter.convertAccuracyToEmoji(
                              accuracyList[widget.step]),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 30),
                        ),
                ],
              ),
            ],
          );
  }
}
