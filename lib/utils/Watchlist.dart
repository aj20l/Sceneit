import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:sceneit/app_database.dart';

class WatchlistItem {
  int? id;
  int? userId;
  final int mediaId;
  final String title;
  final String mediaType;
  final Map<String, dynamic> mediaData;
  final DateTime? notifyDate;

  WatchlistItem({
    this.id,
    this.userId,
    required this.mediaId,
    required this.title,
    required this.mediaType,
    required this.mediaData,
    this.notifyDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'mediaId': mediaId,
      'title': title,
      'mediaType': mediaType,
      'mediaData': jsonEncode(mediaData),
      'notifyDate': notifyDate?.toIso8601String(),
    };
  }

  factory WatchlistItem.fromMap(Map<String, dynamic> map) {
    return WatchlistItem(
      id: map['id'],
      userId: map['userId'],
      mediaId: map['mediaId'],
      title: map['title'],
      mediaType: map['mediaType'],
      mediaData: jsonDecode(map['mediaData']),
      notifyDate:
      map['notifyDate']!= null ? DateTime.parse(map['notifyDate']): null,
    );
  }
}

class WatchlistModel {
  Future<Database> get database async {
    return await AppDatabase.database;
  }

  Future<int> insertItem(WatchlistItem item) async {
    final db = await database;
    return await db.insert('watchlist', item.toMap());
  }

  Future<List<WatchlistItem>> getUserWatchlist(int? userId) async {
    final db = await database;

    final List<Map<String, dynamic>> result;
    //for guest user
    if(userId == null) {
      result = await db.query('watchlist',where: 'userId IS NULL');
    }
    else {
      result = await db.query(
        'watchlist',
        where: 'userId = ?',
        whereArgs: [userId],
      );
    }
    return result.map((map) => WatchlistItem.fromMap(map)).toList();
  }
  Future<List<WatchlistItem>> getWatchlistItem(int? userId, int mediaId) async {
    final db = await database;

    final List<Map<String, dynamic>> result;
    //for guest user
    if(userId == null) {
      result = await db.query(
        'watchlist',
        where: 'userId IS NULL AND mediaId = ?',
        whereArgs: [mediaId]
      );
    }
    else {
      result = await db.query(
        'watchlist',
        where: 'userId = ? AND mediaId = ?',
        whereArgs: [userId, mediaId],
      );
    }
    return result.map((map) => WatchlistItem.fromMap(map)).toList();
  }
  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
        'watchlist',
        where: 'id = ?',
        whereArgs: [id]);
  }
  Future<int> updateItem(WatchlistItem item) async {
    final db = await database;
    return await db.update(
      'watchlist',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }
}
