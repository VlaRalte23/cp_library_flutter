class Member {
  final int? id;
  final String name;
  final String phone;
  final DateTime joinedDate;
  final DateTime validTill;

  Member({
    this.id,
    required this.name,
    required this.phone,
    required this.joinedDate,
    required this.validTill,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'joinedDate': joinedDate.toIso8601String(),
      'validTill': validTill.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Member.fromMap(Map<String, dynamic> toJson) {
    return Member(
      id: toJson['id'],
      name: toJson['name'],
      phone: toJson['phone'],
      joinedDate: DateTime.parse(toJson['joinedDate']),
      validTill: DateTime.parse(toJson['validTill']),
    );
  }

  bool get isActive => validTill.isAfter(DateTime.now());
}
