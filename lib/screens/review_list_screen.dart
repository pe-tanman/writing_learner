import 'package:flutter/material.dart';
import 'package:writing_learner/provider/database_helper.dart';
import 'package:writing_learner/provider/question_provider.dart';
import 'package:writing_learner/screens/review_question_view.dart';
import 'package:writing_learner/themes/app_color.dart';
import 'package:writing_learner/themes/app_theme.dart';

class ReviewListScreen extends StatefulWidget {
  static const routeName = 'review-list-screen';
  @override
  _ReviewListScreenState createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  QuestionDatabaseHelper dbHelper = QuestionDatabaseHelper();

  var reviewList = [];
  var isLoading = true;
  var isInit = true;

  Future<void> reviews() async {
    var questionMaps = await dbHelper.getReviewData();
    List<Map<String, dynamic>> result = [];
    print('revieing');
    if(questionMaps.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    questionMaps.forEach((element) {
      print(element);
      if(element['error_tag'] == null||element['error_tag'] == '') {
         setState(() {
          isLoading = false;
        });
        return;
      }
      var error_tags = element['error_tag'].split(',');
      var error_types = [];
      error_tags.forEach((tag) {
        print(tag);
        tag = GrammarError.toErrorType(int.parse(tag));
        error_types.add(tag);
      });
      var error_types_str = error_types.join(',');
      result.add({
        'sentence': element['question_sentence'],
        'accuracy_rate': element['accuracy_rate'].toString(),
        'error_tag': error_types_str,
      });
    });
    reviewList = result;
    setState(() {
      isLoading = false;
      print(reviewList);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      reviews();
      isInit = false;
    }
    
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: isLoading
            ?  CircularProgressIndicator()
            : (reviewList.isEmpty)?Center(child:Text('復習する問題がありません')):Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.themeColor),
                      onPressed: () => Navigator.of(context)
                          .pushNamed(ReviewQuestionView.routeName),
                      child: SizedBox( child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 60),
                        child:  Text('復習を始める', style: TextStyle(color:Colors.white, fontSize: 20),),
                      ))),
                      SizedBox(height: 20,),
                  Expanded(
                    child: ListView.separated(
                      itemCount: reviewList.length,
                      separatorBuilder: (context, index) => Divider(color: Colors.grey,),
                      itemBuilder: (context, index) {
                        final review = reviewList[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(backgroundColor: AppColors.themeColor, radius:25,  child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text('${reviewList[index]['accuracy_rate']}%',style: TextStyle(color: Colors.white, fontSize: 16)),
                            )),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(reviewList[index]['sentence']!),
                                SizedBox(height: 10),
                                Text('#${reviewList[index]['error_tag']!}', style: TextStyle(color:Colors.grey)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
