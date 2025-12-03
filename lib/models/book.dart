class Book {
  final int id; // Primary key in the DB
  final String name; // Book name
  final String author;
  final int copies; // Number of copies available
  final String bookSlId; // Original Book ID from Excel
  final String bookshelf; // Bookshelf name
  bool isIssued; // Track if currently issued
  int? issuedTo; // Member ID
  DateTime? issuedDate; // Date when issued
  DateTime? dueDate; // Due date

  Book({
    required this.id,
    required this.name,
    required this.author,
    this.copies = 1,
    required this.bookSlId,
    required this.bookshelf,
    this.isIssued = false,
    this.issuedTo,
    this.issuedDate,
    this.dueDate,
  });

  // Convert Map -> Book
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? 0,
      name: map['name'] ?? map['book name'] ?? "Unknown",
      author: map['author'] ?? "Unknown",
      copies: map['copies'] != null
          ? int.tryParse(map['copies'].toString()) ?? 1
          : 1,
      bookSlId: map['bookSlId'] ?? "Unknown",
      bookshelf:
          map['bookshelf']?.toString() ??
          map['bookshelf name']?.toString() ??
          "Unknown Shelf",
      isIssued: map['isIssued'] == 1,
      issuedTo: map['issuedTo'],
      issuedDate: map['issuedDate'] != null
          ? DateTime.parse(map['issuedDate'])
          : null,
      dueDate: map['dueDate'] != null
          ? DateTime.tryParse(map['dueDate'])
          : null,
    );
  }

  // Convert Book -> Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'author': author,
      'copies': copies,
      'bookSlId': bookSlId,
      'bookshelf': bookshelf,
      'isIssued': isIssued ? 1 : 0,
      'issuedTo': issuedTo,
      'issuedDate': issuedDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
    };
  }
}
