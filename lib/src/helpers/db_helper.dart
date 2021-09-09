// import 'dart:async';

// import 'package:briefcase/src/models/transaction.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// class DatabaseHelper {
//   Database database;

//   Future initDB() async {
//     if (database != null) {
//       return database;
//     }

//     String databasesPath = await getDatabasesPath();

//     database = await openDatabase(
//       join(databasesPath, 'briefcasedb.db'),
//       onCreate: (db, version) {
//         return db.execute(
//           "CREATE TABLE trans(id INTEGER PRIMARY KEY, date TEXT, name TEXT, type TEXT, amount INTEGER)",
//         );
//       },
//       version: 1,
//     );

//     return database;
//   }

//   Future<TransactionModel> insertTrans(TransactionModel trans) async {
//     final Database db = database;

//     await db.insert(
//       'trans',
//       trans.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<List<TransactionModel>> trans() async {
//     final Database db = database;

//     final List<Map<String, dynamic>> maps = await db.query('trans');

//     return List.generate(maps.length, (i) {
//       return TransactionModel(
//         id: maps[i]['id'],
//         dateTransaction: maps[i]['date'],
//         titleTransaction: maps[i]['name'],
//         typeTransaction: maps[i]['type'],
//         amountTransaction: maps[i]['amount'],
//       );
//     });
//   }

//   Future<int> countTotal() async {
//     final Database db = database;
//     final int sumEarning = Sqflite.firstIntValue(await db
//         .rawQuery('SELECT SUM(amount) FROM trans WHERE type = "earning"'));
//     final int sumExpense = Sqflite.firstIntValue(await db
//         .rawQuery('SELECT SUM(amount) FROM trans WHERE type = "expense"'));
//     return ((sumEarning == null ? 0 : sumEarning) -
//         (sumExpense == null ? 0 : sumExpense));
//   }

//   Future<void> updateTrans(TransactionModel trans) async {
//     final db = database;

//     await db.update(
//       'trans',
//       trans.toMap(),
//       where: "id = ?",
//       whereArgs: [trans.id],
//     );
//   }

//   Future<void> deleteTrans(int id) async {
//     final db = await database;

//     await db.delete(
//       'trans',
//       where: "id = ?",
//       whereArgs: [id],
//     );
//   }
// }

import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction.dart' as txn;

// database table and column names
final String tableTransactions = 'transactions';
final String columnId = 'id';
final String columnTitle = 'title';
final String columnAmount = 'amount';
final String columnDate = 'date';

// singleton class to manage the database
class DatabaseHelper {
  // Make this a singleton class.
  DatabaseHelper._privateConstructor();

  // actual database filename that is saved in the docs directory.
  static final _databaseName = "transactionsDB.db";

  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableTransactions (
            $columnId INTEGER PRIMARY KEY,
            $columnTitle TEXT NOT NULL,
            $columnAmount REAL NOT NULL,
            $columnDate TEXT NOT NULL
          )
          ''');
  }

  // Database helper methods:

  Future<int> insert(txn.TransactionModel element) async {
    Database db = await database;
    int id = await db.insert(tableTransactions, element.toMap());
    return id;
  }

  Future<txn.TransactionModel> getTransactionById(int id) async {
    Database db = await database;
    List<Map> res = await db.query(tableTransactions,
        columns: [columnId, columnTitle, columnAmount, columnDate],
        where: '$columnId = ?',
        whereArgs: [id]);

    if (res.isNotEmpty) {
      return txn.TransactionModel.fromMap(res.first);
    }
    return null;
  }

  Future<List<txn.TransactionModel>> getAllTransactions() async {
    Database db = await database;
    List<Map> res = await db.query(tableTransactions,
        columns: [columnId, columnTitle, columnAmount, columnDate]);

    List<txn.TransactionModel> list =
        res.map((e) => txn.TransactionModel.fromMap(e)).toList();

    return list;
  }

  Future<int> deleteTransactionById(int id) async {
    Database db = await database;
    int res =
        await db.delete(tableTransactions, where: "id = ?", whereArgs: [id]);
    return res;
  }

  Future<int> deleteAllTransactions() async {
    Database db = await database;
    int res = await db.delete(tableTransactions, where: '1');
    return res;
  }

  // TODO: update(txn.Transaction element)
}
