import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String author;

  @HiveField(3)
  bool isIssued;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.isIssued = false,
  });
}
