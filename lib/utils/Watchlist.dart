import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'media.dart';
class Watchlist {
  int? id;
  final int userId;
  final String name;


  Watchlist({required this.id, required this.userId, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userid': userId,
      'name': name,
    };
  }

  factory Watchlist.fromMap(Map<String, dynamic> map) {
    return Watchlist(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],

    );
  }
}





class WatchlistModel {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('watchlists.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE watchlists(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userid INTEGER NOT NULL FOREIGN KEY REFERENCES users(id),
            name TEXT NOT NULL,

          )
        ''');
      },
    );
  }

  Future<List<Watchlist>> getAllWatchlist() async {
    final db = await database;
    final result = await db.query('watchlists');
    return result.map((map) => Watchlist.fromMap(map)).toList();
  }

  Future<int> insertWatchlist(Watchlist watchlist) async {
    final db = await database;
    return await db.insert('watchlists', watchlist.toMap());
  }

  Future<int> updateWatchlist(Watchlist watchlist) async {
    final db = await database;
    return await db.update(
      'watchlists',
      watchlist.toMap(),
      where: 'id = ?',
      whereArgs: [watchlist.id],
    );
  }

  Future<int> deleteWatchlistById(int id) async {
    final db = await database;
    return await db.delete('watchlists', where: 'id = ?', whereArgs: [id]);
  }



}
