import 'package:library_chawnpui/models/member.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MemberDatabase {
  static final MemberDatabase instance = MemberDatabase._init();
  static Database? _database;

  MemberDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('members.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE members ADD COLUMN isActive INTEGER NOT NULL DEFAULT 1',
      );
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE members (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      phone TEXT NOT NULL,
      section TEXT NOT NULL,
      joinedDate TEXT NOT NULL,
      validTill TEXT NOT NULL,
      isActive INTEGER NOT NULL DEFAULT 1
      )
   ''');
  }

  // Insert a Member
  Future<int> createMember(Member member) async {
    final db = await instance.database;
    return await db.insert('members', member.toMap());
  }

  // Get all Members
  Future<List<Member>> getMembers() async {
    final db = await instance.database;
    final result = await db.query('members');
    return result.map((map) => Member.fromMap(map)).toList();
  }

  // Update A Member
  Future<int> updateMember(Member member) async {
    final db = await instance.database;
    return await db.update(
      'members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  // Delete A Member
  Future<int> deleteMember(int id) async {
    final db = await instance.database;
    return await db.delete('members', where: 'id = ?', whereArgs: [id]);
  }

    // Get single Member by ID
  Future<Member?> getMemberById(int id) async {
    final db = await instance.database;

    final result = await db.query(
      'members',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Member.fromMap(result.first);
    }

    return null;
  }


  // Close Database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
