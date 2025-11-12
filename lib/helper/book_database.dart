import 'package:library_chawnpui/models/book.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BookDatabase {
  static final BookDatabase instance = BookDatabase._init();
  static Database? _database;

  BookDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('books.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books(
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        isIssued INTEGER NOT NULL DEFAULT 0,
        issuedTo INTEGER
        )
    ''');
  }

  // Add Book
  Future<int> insertBook(Book book) async {
    final db = await instance.database;
    return await db.insert('books', book.toMap());
  }

  // List book
  Future<List<Book>> getBooks() async {
    final db = await instance.database;
    final result = await db.query('books');
    return result.map((map) => Book.fromMap(map)).toList();
  }

  // Update Book
  Future<int> updateBook(Book book) async {
    final db = await instance.database;
    return await db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  // Issue a book to member
  Future<int> issuedBook(int bookId, int memberId) async {
    final db = await instance.database;
    return await db.update(
      'books',
      {'isIssued': 1, 'issuedTo': memberId},
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  // Return a book
  Future<int> returnBook(int bookId) async {
    final db = await instance.database;
    return await db.update(
      'books',
      {'isIssued': 0, 'issuedTo': null},
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  // Get books Issued To
  Future<List<Book>> getBooksIssuedTo(int memberId) async {
    final db = await instance.database;
    final result = await db.query(
      'books',
      where: 'issuedTo = ?',
      whereArgs: [memberId],
    );
    return result.map((map) => Book.fromMap(map)).toList();
  }

  // Delete Book
  Future<int> deleteBook(int id) async {
    final db = await instance.database;
    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  // Issue a Book to a Member
  Future<int> issueBook(int bookId, int memberId) async {
    final db = await instance.database;
    return await db.update(
      'books',
      {
        'isIssued': 1, // mark as Issued
        'issuedTo': memberId, // Track with member has it
      },
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  // Return a Book
  Future<int> returnedBook(int bookId) async {
    final db = await instance.database;
    return await db.update(
      'books',
      {'isIssued': 0, 'issuedTo': null},
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
