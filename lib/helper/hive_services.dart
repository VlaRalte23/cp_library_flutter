// services/hive_service.dart
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/book.dart';
import '../models/member.dart'; // Import the Member model

class HiveService {
  // Singleton pattern: Ensure only one instance of HiveService exists.
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal(); // Private constructor

  // Declare late variables for both book and member boxes
  late Box<Book> _booksBox;
  late Box<Member> _memberBox;

  // Initialize both Hive boxes. This method should be called once at app startup
  // and awaited to ensure both boxes are open before use.
  Future<void> init() async {
    if (!Hive.isBoxOpen('books')) {
      _booksBox = await Hive.openBox<Book>('books');
      log('HiveService: "books" box opened and initialized.');
    } else {
      _booksBox = Hive.box<Book>('books');
      log('HiveService: "books" box was already open.');
    }

    if (!Hive.isBoxOpen('member')) {
      _memberBox = await Hive.openBox<Member>('member');
      log('HiveService: "member" box opened and initialized.');
    } else {
      _memberBox = Hive.box<Member>('member');
      log('HiveService: "member" box was already open.');
    }
  }

  // --- Book Operations ---

  // Get a ValueListenable for real-time updates to the books box.
  ValueListenable<Box<Book>> getBooksListenable() {
    return _booksBox.listenable();
  }

  // Get all books currently in the box.
  List<Book> getAllBooks() {
    return _booksBox.values.toList();
  }

  // Generate a unique ID for new books.
  int _generateUniqueBookId() {
    if (_booksBox.isEmpty) {
      return 1;
    }
    final maxId = _booksBox.values
        .map((book) => book.id)
        .fold(0, (prev, current) => prev > current ? prev : current);
    return maxId + 1;
  }

  // Add a new book to Hive.
  Future<void> addBook(Book book) async {
    if (book.id == 0) {
      book.id = _generateUniqueBookId();
    }
    await _booksBox.add(book);
    log('Book added successfully with ID: ${book.id}');
  }

  // Update an existing book in Hive.
  Future<void> updateBook(Book book) async {
    final existingBookEntry = _booksBox.values.firstWhere(
      (b) => b.id == book.id,
      orElse: () =>
          throw Exception('Book with ID ${book.id} not found for update.'),
    );
    existingBookEntry.title = book.title;
    existingBookEntry.author = book.author;
    existingBookEntry.isIssued = book.isIssued;
    await existingBookEntry.save();
    log('Book updated successfully with ID: ${book.id}');
  }

  // Delete a book from Hive by its 'id' field.
  Future<void> deleteBook(int bookId) async {
    final bookToDelete = _booksBox.values.firstWhere(
      (book) => book.id == bookId,
      orElse: () =>
          throw Exception('Book with ID $bookId not found for deletion.'),
    );
    await bookToDelete.delete();
    log('Book deleted successfully with ID: $bookId');
  }

  // --- Member Operations ---

  // Get a ValueListenable for real-time updates to the members box.
  ValueListenable<Box<Member>> getMembersListenable() {
    return _memberBox.listenable();
  }

  // Get all members currently in the box.
  List<Member> getAllMembers() {
    return _memberBox.values.toList();
  }

  // Generate a unique ID for new members.
  int _generateUniqueMemberId() {
    if (_memberBox.isEmpty) {
      return 1;
    }
    final maxId = _memberBox.values
        .map((member) => member.id)
        .fold(0, (prev, current) => prev > current ? prev : current);
    return maxId + 1;
  }

  // Add a new member to Hive.
  Future<void> addMember(Member member) async {
    if (member.id == 0) {
      // Assuming 0 means a new member that needs an ID
      member.id = _generateUniqueMemberId();
    }
    await _memberBox.add(member);
    log('Member added successfully with ID: ${member.id}');
  }

  // Update an existing member in Hive.
  Future<void> updateMember(Member member) async {
    final existingMemberEntry = _memberBox.values.firstWhere(
      (m) => m.id == member.id,
      orElse: () =>
          throw Exception('Member with ID ${member.id} not found for update.'),
    );
    existingMemberEntry.name = member.name;
    existingMemberEntry.phone = member.phone;
    await existingMemberEntry.save();
    log('Member updated successfully with ID: ${member.id}');
  }

  // Delete a member from Hive by its 'id' field.
  Future<void> deleteMember(int memberId) async {
    final memberToDelete = _memberBox.values.firstWhere(
      (member) => member.id == memberId,
      orElse: () =>
          throw Exception('Member with ID $memberId not found for deletion.'),
    );
    await memberToDelete.delete();
    log('Member deleted successfully with ID: $memberId');
  }
}
