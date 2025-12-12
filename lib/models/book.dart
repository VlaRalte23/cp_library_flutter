class Book {
  int? id;
  String name;
  String author;
  String bookshelf;
  int copies;
  int issuedCount; // still useful for UI only (optional)

  Book({
    this.id,
    required this.name,
    required this.author,
    required this.bookshelf,
    this.copies = 0,
    this.issuedCount = 0,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      name: map['name'],
      author: map['author'],
      bookshelf: map['bookshelf'],
      copies: map['copies'] ?? 0,
      issuedCount: map['issuedCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'author': author,
      'bookshelf': bookshelf,
      'copies': copies,
      'issuedCount': issuedCount,
    };
  }
}
