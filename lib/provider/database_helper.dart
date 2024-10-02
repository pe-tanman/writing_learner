import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:fast_csv/fast_csv.dart' as fast_csv;
import 'dart:math' as math;

class QuestionDatabaseHelper {
  static final QuestionDatabaseHelper _instance =
      QuestionDatabaseHelper._internal();

  factory QuestionDatabaseHelper() {
    return _instance;
  }

  QuestionDatabaseHelper._internal();

  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDatabase();

    return _database;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), "question_database.db");
    var db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE question_table(
          material_id INTEGER,
            question_number INTEGER,
            question_sentence TEXT,
            accuracy_rate INTEGER,
            error_tag TEXT,
            primary key(material_id, question_number)
          )
        ''');
        await setAllQuestions();
      },
    );
    return db;
  }

  Future<List<List<String>>> loadCSVFromAssets(path) async {
    String assetPath = path;
    final String csvString = await rootBundle.loadString(assetPath);
    List<List<String>> csvData = fast_csv.parse(csvString);
    return csvData;
  }

  Future<void> setQuestion(materialId, csvPath) async {
    List<List<String>> csvData = await loadCSVFromAssets(csvPath);
    for (int i = 0; i < csvData.length; i++) {
      insertData(materialId, i, csvData[i][0], null, null);
    }
  }

  Future<void> setAllQuestions() async {
    setQuestion(2, 'lib/assets/write_to_the_point.csv');
    setQuestion(4, 'lib/assets/japanese_proverbs.csv');
  }

  Future<List<Map<String, dynamic>>> getSelectedData(
      materialId, questionNum) async {
    final Database? db = await database;
    return await db!.query('question_table',
        where: 'material_id = ? and question_number = ?',
        whereArgs: [materialId, questionNum]);
  }

  Future<List<Map<String, dynamic>>> getAllData() async {
    final Database? db = await database;
    return await db!.query('question_table');
  }

  Future<List<Map<String, dynamic>>> getReviewData() async {
    final Database? db = await database;
    return await db!.query('question_table',
        where: 'accuracy_rate IS NOT NULL', orderBy: 'accuracy_rate ASC');
  }

  Future<List<Map<String, dynamic>>> getQuestionData(materialId) async {
    final Database? db = await database;
    return await db!.query('question_table',
        where: 'material_id = ? ', whereArgs: [materialId]);
  }

  Future<List<Map<String, dynamic>>> getRandomData() async {
    final Database? db = await database;
    var random = math.Random();
    MaterialDatabaseHelper materialDatabaseHelper = MaterialDatabaseHelper();
    
    print('Fetching all materials...');
    var materialMaps = await materialDatabaseHelper.getAllData();
    print('Materials fetched: $materialMaps');
    
    var materialId = random.nextInt(2)+1;
    print('Selected material ID: $materialId');
    
    var questionId = materialMaps[materialId]['next_number'];
    print('Selected question number: $questionId');
    
    print('Updating next number for material ID: $materialId');
    await materialDatabaseHelper.updateNextNumber(materialId, questionId + 1);
    
    print('Fetching question data for material ID: $materialId and question number: $questionId');
    var result = await db!.query('question_table',
        where: 'material_id = ? and question_number = ?',
        whereArgs: [materialId, questionId]);
    print('Question data fetched: $result');
    
    return result;
  }

  Future<void> insertData(materialId, questionNumber, questionSentence,
      int? accuracyRate, List<int>? tags) async {
    final Database? db = await database;
    tags ??= [];
    var tagString = tags.join(',');
    Map<String, dynamic> data = {
      'material_id': materialId,
      'question_number': questionNumber,
      'question_sentence': questionSentence,
      'accuracy_rate': accuracyRate,
      'error_tag': tagString,
    };
    await db!.insert('question_table', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateAccuracyRateAndError(int materialId, int questionNumber,
      int accuracyRate, List<int> errorTags) async {
    final Database? db = await database;
    Map<String, dynamic> data = {
      'accuracy_rate': accuracyRate,
      'error_tag': errorTags.join(','),
    };
    await db!.update('question_table', data,
        where: 'material_id = ? and question_number = ?',
        whereArgs: [materialId, questionNumber]);
  }

  Future<int> deleteData(int id) async {
    final Database? db = await database;
    return await db!.delete('question_table', where: 'id = ?', whereArgs: [id]);
  }
}

class MaterialDatabaseHelper {
  static final MaterialDatabaseHelper _instance =
      MaterialDatabaseHelper._internal();

  factory MaterialDatabaseHelper() {
    return _instance;
  }

  MaterialDatabaseHelper._internal();

  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDatabase();

    return _database;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), "material_database.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE material_table(
           id INT PRIMARY KEY,
           name TEXT,
           next_number INTEGER
          )
        ''');
        await setMaterial();
      },
    );
  }

  Future<void> setMaterial() async {
    insertNewMaterial(0, 'AI最難関英訳');
    insertNewMaterial(1, 'AI難関英訳');
    insertNewMaterial(2, 'Write to the point');
    insertNewMaterial(3, 'AI最難関穴埋め');
    insertNewMaterial(4, 'ことわざ');
    insertNewMaterial(5, '構文150');
  }

  Future<List<Map<String, dynamic>>> getAllData() async {
    final Database? db = await database;
    return await db!.query('material_table');
  }

  Future<int> getNextNum(materialId) async {
    final Database? db = await database;
    var result = await db!
        .query('material_table', where: 'id = ?', whereArgs: [materialId]);

    int nextNum = result[0]['next_number'] as int;
    return nextNum;
  }

  Future<void> insertNewMaterial(id, name) async {
    final Database? db = await database;
    Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'next_number': 0,
    };
    await db!.insert('material_table', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateNextNumber(int materialId, int questionNumber) async {
    final Database? db = await database;
    Map<String, dynamic> data = {
      'next_number': questionNumber,
    };
    await db!.update('material_table', data,
        where: 'id = ?', whereArgs: [materialId]);
  }

  Future<int> deleteData(int id) async {
    final Database? db = await database;
    return await db!.delete('material_table', where: 'id = ?', whereArgs: [id]);
  }
}

class DailyChallengeDatabaseHelper {
  static final DailyChallengeDatabaseHelper _instance =
      DailyChallengeDatabaseHelper._internal();

  factory DailyChallengeDatabaseHelper() {
    return _instance;
  }

  DailyChallengeDatabaseHelper._internal();

  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDatabase();

    return _database;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), "daily_challenge4.db");
    print('init');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE daily_challenge_table4(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
           date INTEGER UNIQUE,
           streak_count INTEGER,
           accuracy_rate INTEGER
          )
        ''');
      },
    );
  }

  Future<void> insertData(int accuracyRate) async {
    var streakCount;
    final Database? db = await database;
    DateTime today = DateTime.now();
// 前日を求める
    DateTime yesterday = today.subtract(Duration(days: 1));

// データベースに保存する形式に変換 (YYYYMMDD形式)
    int todayAsInt = today.year * 10000 + today.month * 100 + today.day;
    int yesterdayAsInt =
        yesterday.year * 10000 + yesterday.month * 100 + yesterday.day;
    int? previousDayAsInt = await getPreviousDate();

    if (yesterdayAsInt != previousDayAsInt) {
      streakCount = 1;
    } else {
      streakCount++;
    }
    Map<String, dynamic> data = {
      'date': todayAsInt,
      'streak_count': streakCount,
      'accuracy_rate': accuracyRate,
    };
    await db!.insert('daily_challenge_table4', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int?> getPreviousDate() async {
    final Database? db = await database;
    List<Map<String, dynamic>> result = await db!.query(
        'daily_challenge_table4',
        where: 'accuracy_rate IS NOT NULL',
        orderBy: 'id DESC',
        limit: 1);
    if (result.isNotEmpty) {
      return result.first['date'] as int?;
    } else {
      return null; // レコードがない場合
    }
  }

  Future<List<Map>> getAllData() async {
    final Database? db = await database;
    return await db!.query('daily_challenge_table4', orderBy: 'id DESC');
  }

  Future<int?> getStreakCount() async {
    final Database? db = await database;
    List<Map<String, dynamic>> result = await db!.query(
        'daily_challenge_table4',
        where: 'accuracy_rate IS NOT NULL',
        orderBy: 'id DESC',);
    if (result.isNotEmpty) {
     
      return result.first['streak_count'] as int?;
    } else {
      return null; // レコードがない場合
    }
  }

  int getTodayAsInt() {
    DateTime today = DateTime.now();
    return today.year * 10000 + today.month * 100 + today.day;
  }

  Future<int> deleteData(int id) async {
    final Database? db = await database;
    return await db!.delete('material_table', where: 'id = ?', whereArgs: [id]);
  }
}
