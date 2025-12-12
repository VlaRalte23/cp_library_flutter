class BookIssue {
  int? id;
  int bookId;
  int memberId;
  DateTime issuedDate;
  DateTime dueDate;
  DateTime? returnDate;

  BookIssue({
    this.id,
    required this.bookId,
    required this.memberId,
    required this.issuedDate,
    required this.dueDate,
    this.returnDate,
  });

  factory BookIssue.fromMap(Map<String, dynamic> map) {
    return BookIssue(
      id: map['id'],
      bookId: map['bookId'],
      memberId: map['memberId'],
      issuedDate: DateTime.parse(map['issuedDate']),
      dueDate: DateTime.parse(map['dueDate']),
      returnDate: map['returnDate'] != null
          ? DateTime.parse(map['returnDate'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'memberId': memberId,
      'issuedDate': issuedDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
    };
  }
}
