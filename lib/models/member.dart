import 'package:hive/hive.dart';

part 'member.g.dart';

@HiveType(typeId: 1)
class Member extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  DateTime joinedDate;

  @HiveField(4)
  DateTime? validTill;

  Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.joinedDate,
    required this.validTill,
  });

  bool get isActive => validTill!.isAfter(DateTime.now());
}
