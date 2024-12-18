import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tracks.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tracks(
            id TEXT PRIMARY KEY,
            name TEXT,
            artist TEXT,
            albumName TEXT,
            imageUrl TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveFavoriteTrack(Map<String, dynamic> track) async {
    final db = await database;
    await db.insert(
      'tracks',
      {
        'id': track['id'],
        'name': track['name'],
        'artist': track['artists'][0]['name'],
        'albumName': track['album']['name'],
        'imageUrl': track['album']['images'].isNotEmpty
            ? track['album']['images'].last['url']
            : '',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getFavoriteTracks() async {
    final db = await database;
    return db.query('tracks');
  }

  Future<void> deleteFavoriteTrack(String id) async {
    final db = await database;
    await db.delete('tracks', where: 'id = ?', whereArgs: [id]);
  }
}
