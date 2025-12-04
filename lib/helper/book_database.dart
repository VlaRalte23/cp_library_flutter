// import 'dart:developer';

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

    // Temporary - force delete old db
    // await deleteDatabase(path);
    // log('Deleted old db at: $path');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE books ADD COLUMN issuedDate TEXT;");
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        author TEXT NOT NULL,
        bookshelf TEXT,
        copies INT DEFAULT 0,
        issuedCount INTEGER DEFAULT 0,
        isIssued INTEGER NOT NULL DEFAULT 0,
        issuedTo INTEGER,
        issuedDate TEXT,
        dueDate TEXT
        )
    ''');

    // Debug to Print schema to verify columns exist
    // final schema = await db.rawQuery("PRAGMA table_info(books)");
    // log("BOOKS TABLE SCHEMA: ");
    // print(schema);
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
  // Future<int> issuedBook(int bookId, int memberId) async {
  //   final db = await instance.database;
  //   return await db.update(
  //     'books',
  //     {'isIssued': 1, 'issuedTo': memberId},
  //     where: 'id = ?',
  //     whereArgs: [bookId],
  //   );
  // }

  // Return a book
  Future<void> returnBook(int bookId) async {
    final db = await instance.database;

    final result = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [bookId],
      limit: 1,
    );

    final book = Book.fromMap(result.first);

    if (book.issuedCount > 0) {
      book.issuedCount--;
    }

    if (book.issuedCount == 0) {
      book.issuedTo = null;
      book.issuedDate = null;
      book.dueDate = null;
    }

    await db.update(
      'books',
      book.toMap(),
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
  Future<String> issueBook(int bookId, int memberId) async {
    final db = await instance.database;

    final result = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [bookId],
      limit: 1,
    );

    if (result.isEmpty) return 'Book not found';

    final book = Book.fromMap(result.first);

    if (book.issuedCount >= book.copies) {
      return 'No copies available';
    }

    book.issuedCount++;
    book.issuedTo = memberId;
    book.issuedDate = DateTime.now();
    book.dueDate = DateTime.now().add(const Duration(days: 14));
    book.isIssued = true;

    await db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [bookId],
    );

    return 'Issued successfully';
  }

  // Return a Book
  // Future<int> returnedBook(int bookId) async {
  //   final db = await instance.database;
  //   return await db.update(
  //     'books',
  //     {'isIssued': 0, 'issuedTo': null, 'dueDate': null},
  //     where: 'id = ?',
  //     whereArgs: [bookId],
  //   );
  // }

  // Extend DueDate
  Future<void> extendDueDate(int bookId, DateTime newDate) async {
    final db = await instance.database;

    await db.update(
      'books',
      {'dueDate': newDate.toIso8601String()},
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  Future<List<Book>> getIssuedBooks() async {
    final db = await instance.database;

    final result = await db.query(
      'books',
      where: 'isIssued = ?',
      whereArgs: [1],
    );
    //print("DEBUG: Issued books raw DB result → $result");

    return result.map((map) => Book.fromMap(map)).toList();
  }

  Future<Map<String, dynamic>?> getMemberById(int id) async {
    final db = await instance.database;
    final result = await db.query('members', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
