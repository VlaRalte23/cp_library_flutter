class Book {
  final int id;
  final String title;
  final String author;
  bool isIssued;
  final int? issuedTo;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.isIssued = false,
    this.issuedTo,
  });

  // Map() -> Book
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      // isIssued: map['isIssued'] == 1,
      // issuedTo: map['issuedTo'],
    );
  }

  // Book -> Map()
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      // 'isIssued': isIssued ? 1 : 0,
      // 'issuedTo': issuedTo,
    };
  }
}
