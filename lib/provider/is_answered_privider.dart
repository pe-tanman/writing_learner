import 'package:flutter_riverpod/flutter_riverpod.dart';
//TODO削除してQuestionData().answerのあるなしで判定すべき
final isAnsweredProvider = StateProvider<bool>((ref)=>false);