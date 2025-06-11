import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as paths;
import '../models/document.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = paths.join(await getDatabasesPath(), 'brain_crate.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE documents(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        course TEXT NOT NULL,
        topic TEXT NOT NULL,
        filePath TEXT NOT NULL,
        fileType TEXT NOT NULL,
        dateAdded INTEGER NOT NULL,
        fileSize INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertDocument(Document document) async {
    final db = await database;
    return await db.insert('documents', document.toMap());
  }

  Future<List<Document>> getAllDocuments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('documents', orderBy: 'dateAdded DESC');
    return List.generate(maps.length, (i) => Document.fromMap(maps[i]));
  }

  Future<List<Document>> getDocumentsByCourse(String course) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'documents',
      where: 'course = ?',
      whereArgs: [course],
      orderBy: 'dateAdded DESC',
    );
    return List.generate(maps.length, (i) => Document.fromMap(maps[i]));
  }

  Future<int> deleteDocument(String id) async {
    final db = await database;
    return await db.delete(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> getAllCourses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'documents',
      distinct: true,
      columns: ['course'],
      orderBy: 'course ASC',
    );
    return maps.map((map) => map['course'] as String).toList();
  }
} 