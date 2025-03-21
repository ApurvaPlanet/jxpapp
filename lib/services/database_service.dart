

import 'package:jxp_app/models/dailysteps_response.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor() ;

  DatabaseService._constructor();

  final String _stepsTableName = 'StepsPerDay';
  final String _IdColumn = 'id';
  final String _stepsColumn = 'steps_count';
  final String _dateColumn = 'date';


  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'master_db.db');

    final database = openDatabase(
        databasePath,
        version: 1,
        onCreate: (db, version) {
          db.execute('''
          Create Table $_stepsTableName(
            $_IdColumn INTEGER PRIMARY KEY,
            $_stepsColumn TEXT NOT NULL,
            $_dateColumn TEXT NOT NULL
          )
          ''');
        }
    );

    return database;
  }


  void addSteps(String stepsCount, String date) async {
    final db = await database;
    await db.insert(
        _stepsTableName,
        {
          _stepsColumn: stepsCount,
          _dateColumn: date
        }
    );
  }

  Future<List<DailyStepsDBModel>> getDailyStepsDB() async {
    final db = await database;
    final data = await db.query(_stepsTableName);
    List<DailyStepsDBModel> list = data.map((e) => DailyStepsDBModel(id: e['id']as int, date: e['date'] as String, steps: e['steps_count'] as String)).toList();
    return list;
  }

  void updateSteps(int id, String steps) async {
    final db = await database;
    await db.update(
        _stepsTableName,
    {
      _stepsColumn: steps
    },
    where: 'id = ?',
      whereArgs: [
        id,
      ]
    );
  }

  void deleteStep(int id) async {
    final db = await database;
    await db.delete(
        _stepsTableName,
      where: 'id = ?',
      whereArgs: [
        id,
      ]
    );
  }
}