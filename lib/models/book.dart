class Book {
  final int id;
  final String title;
  final String author;
  bool isIssued;
  final int? issuedTo;
  final DateTime? dueDate;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.isIssued = false,
    this.issuedTo,
    this.dueDate,
  });

  // Map() -> Book
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      isIssued: map['isIssued'] == 1,
      issuedTo: map['issuedTo'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
    );
  }

  // Book -> Map()
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isIssued': isIssued ? 1 : 0,
      'issuedTo': issuedTo,
      'dueDate': dueDate?.toIso8601String(),
    };
  }
}
