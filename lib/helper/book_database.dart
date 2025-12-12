import 'package:library_chawnpui/models/book.dart';
import 'package:library_chawnpui/models/book_issue.dart';
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

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Create new issues table
      await db.execute('''
        CREATE TABLE book_issues (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          bookId INTEGER NOT NULL,
          memberId INTEGER NOT NULL,
          issuedDate TEXT,
          dueDate TEXT,
          returnDate TEXT
        );
      ''');

      // Remove old issue-related columns
      await db.execute("ALTER TABLE books RENAME TO books_old;");

      // Re-create books table without old columns
      await db.execute('''
        CREATE TABLE books(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          author TEXT NOT NULL,
          bookshelf TEXT,
          copies INT DEFAULT 0,
          issuedCount INTEGER DEFAULT 0
        );
      ''');

      // Copy non-issue data
      await db.execute('''
        INSERT INTO books (id, name, author, bookshelf, copies, issuedCount)
        SELECT id, name, author, bookshelf, copies, issuedCount
        FROM books_old;
      ''');

      await db.execute("DROP TABLE books_old;");
    }
  }

  /// Returns books that currently have at least one available copy.
  /// Uses a single SQL query to count active issued copies per book.
  Future<List<Book>> getAvailableBooks() async {
    final db = await instance.database;

    final result = await db.rawQuery('''
    SELECT b.*,
      (SELECT COUNT(*) FROM book_issues bi WHERE bi.bookId = b.id AND (bi.returnDate IS NULL OR bi.returnDate = "")) AS activeCount
    FROM books b
    WHERE b.copies > (SELECT COUNT(*) FROM book_issues bi WHERE bi.bookId = b.id AND (bi.returnDate IS NULL OR bi.returnDate = ""))
    ORDER BY b.name COLLATE NOCASE;
  ''');

    return result.map((map) => Book.fromMap(map)).toList();
  }

  Future _createDB(Database db, int version) async {
    // BOOK TABLE
    await db.execute('''
      CREATE TABLE books(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        author TEXT NOT NULL,
        bookshelf TEXT,
        copies INT DEFAULT 0,
        issuedCount INTEGER DEFAULT 0
      );
    ''');

    // ISSUE TABLE
    await db.execute('''
      CREATE TABLE book_issues (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookId INTEGER NOT NULL,
        memberId INTEGER NOT NULL,
        issuedDate TEXT,
        dueDate TEXT,
        returnDate TEXT
      );
    ''');
  }

  // Add Book
  Future<int> insertBook(Book book) async {
    final db = await instance.database;
    return await db.insert('books', book.toMap());
  }

  // List all books
  Future<List<Book>> getBooks() async {
    final db = await instance.database;
    final result = await db.query('books');

    List<Book> books = result.map((map) => Book.fromMap(map)).toList();

    // this block is for counting issues
    for (var book in books) {
      book.issuedCount = await getIssuedCount(book.id!);
    }
    return books;
  }

  // Get a single book by its ID
  Future<Book?> getBookById(int id) async {
    final db = await instance.database;

    final result = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Book.fromMap(result.first);
    }

    return null;
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

  // Get all Active members

  Future<List<Map<String, dynamic>>> getAllActiveIssues() async {
    final db = await instance.database;

    return await db.rawQuery('''
    SELECT 
      bi.id AS issueId,
      b.id AS bookId,
      b.name AS bookName,
      b.author AS author,
      b.bookshelf AS bookshelf,
      bi.memberId AS memberId,
      bi.issuedDate AS issuedDate,
      bi.dueDate AS dueDate
    FROM book_issues bi
    INNER JOIN books b ON bi.bookId = b.id
    WHERE bi.returnDate IS NULL
    ORDER BY bi.dueDate ASC
  ''');
  }

  // Issue a book copy
  Future<String> issueBook(int bookId, int memberId) async {
    final db = await instance.database;

    final data = await db.query('books', where: 'id = ?', whereArgs: [bookId]);
    if (data.isEmpty) return "Book not found";
    Book book = Book.fromMap(data.first);

    // Count active issued copies
    final issuedCount = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM book_issues WHERE bookId = ? AND returnDate IS NULL',
        [bookId],
      ),
    )!;

    if (issuedCount >= book.copies) {
      return "No copies available";
    }

    final now = DateTime.now();

    await db.insert('book_issues', {
      'bookId': bookId,
      'memberId': memberId,
      'issuedDate': now.toIso8601String(),
      'dueDate': now.add(Duration(days: 7)).toIso8601String(),
      'returnDate': null,
    });

    return "Issued successfully";
  }

  // Return a book issue
  Future<void> returnBook(int issueId) async {
    final db = await instance.database;

    await db.update(
      'book_issues',
      {'returnDate': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [issueId],
    );
  }

  // Extend due date
  Future<void> extendDueDate(int issueId, DateTime newDate) async {
    final db = await instance.database;

    await db.update(
      'book_issues',
      {'dueDate': newDate.toIso8601String()},
      where: 'id = ?',
      whereArgs: [issueId],
    );
  }

  // Get all active issues for a member
  Future<List<BookIssue>> getBooksIssuedTo(int memberId) async {
    final db = await instance.database;

    final result = await db.query(
      'book_issues',
      where: 'memberId = ? AND returnDate IS NULL',
      whereArgs: [memberId],
    );

    return result.map((map) => BookIssue.fromMap(map)).toList();
  }

  // Get the number of book issued
  Future<int> getIssuedCount(int bookId) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
    SELECT COUNT(*) AS count
    FROM book_issues
    WHERE bookId = ? AND returnDate IS NULL
  ''',
      [bookId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get all issued books (active)
  Future<List<BookIssue>> getIssuedBooks() async {
    final db = await instance.database;

    final result = await db.query('book_issues', where: 'returnDate IS NULL');

    return result.map((map) => BookIssue.fromMap(map)).toList();
  }

  // Delete Book
  Future<String> deleteBook(int bookId) async {
    final db = await instance.database;

    // Check if book has active issues
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM book_issues WHERE bookId = ? AND returnDate IS NULL',
        [bookId],
      ),
    );

    if (count! > 0) {
      return "Cannot delete. Book is currently issued to members.";
    }

    // Delete all issue history for this book
    await db.delete('book_issues', where: 'bookId = ?', whereArgs: [bookId]);

    // Delete book
    await db.delete('books', where: 'id = ?', whereArgs: [bookId]);

    return "Book deleted successfully.";
  }

  Future<int> getActiveIssuedCount() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) AS count FROM book_issues WHERE returnDate IS NULL",
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getReturnedCount() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) AS count FROM book_issues WHERE returnDate IS NOT NULL",
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getNotReturnedCount() async {
    final db = await instance.database;
    final today = DateTime.now().toIso8601String();

    final result = await db.rawQuery(
      """
    SELECT COUNT(*) AS count
    FROM book_issues
    WHERE returnDate IS NULL 
    AND dueDate < ?
  """,
      [today],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Future<List<Map<String, dynamic>>> getAllReturnedIssues() async {
  //   final db = await instance.database;

  //   final result = await db.rawQuery('''
  //   SELECT
  //     bi.id AS issueId,
  //     b.id AS bookId,
  //     b.name AS bookName,
  //     b.author,
  //     b.bookshelf,
  //     m.id AS memberId,
  //     m.name AS memberName,
  //     m.phone,
  //     bi.issuedDate,
  //     bi.dueDate,
  //     bi.returnDate
  //   FROM book_issues bi
  //   INNER JOIN books b ON bi.bookId = b.id
  //   INNER JOIN members m ON bi.memberId = m.id
  //   WHERE bi.returnDate IS NOT NULL
  //   ORDER BY bi.returnDate DESC
  // ''');

  //   return result;
  // }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
