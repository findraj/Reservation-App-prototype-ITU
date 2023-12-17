import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vyperto/model/account.dart';

class AccountAPI {
  Future<Database> getAccountDB() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'account.db'),
      onCreate: (db, version) async {
        await db.execute(
          // 'DROP TABLE IF EXISTS accounts',
          'CREATE TABLE accounts(id INTEGER PRIMARY KEY, balance INTEGER, price INTEGER)',
        );
      },
      version: 1,
    );
  }

  Future<Account> getAccount(Account account) async {

    Database db = await getAccountDB();
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [account.id],
    );

    if (maps.isNotEmpty) {
      // Use the existing Account instance's id
      return Account(
        id: maps[0]['id'] as int,
        balance: maps[0]['balance'] as int,
        price: maps[0]['price'] as int,
      );
    } else {
      throw Exception('Account with id ${account.id} not found');
    }
  }

  Future<void> insertAccount(Account account) async {
    Database db = await getAccountDB();
    try {
      await db.insert(
        'accounts',
        account.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Account inserted successfully');
    } catch (e) {
      print('Error inserting account: $e');
      rethrow;
    }
  }

  Future<List<Account>> fetchAccounts() async {
    Database db = await getAccountDB();
    final List<Map<String, dynamic>> maps = await db.query('accounts');
    return List.generate(maps.length, (i) {
      return Account(
        id: maps[i]['id'] as int,
        balance: maps[i]['balance'] as int,
        price: maps[i]['price'] as int,
      );
    });
  }

  Future<void> deleteAccount(Account account) async {
    Database db = await getAccountDB();
    await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }
}