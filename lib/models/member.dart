class Member {
  final int? id;
  final String name;
  final String phone;
  final String section;
  final DateTime joinedDate;
  final DateTime validTill;
  final bool isActive;

  Member({
    this.id,
    required this.name,
    required this.phone,
    required this.section,
    required this.joinedDate,
    required this.validTill,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'section': section,
      'joinedDate': joinedDate.toIso8601String(),
      'validTill': validTill.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      section: map['section'],
      joinedDate: DateTime.parse(map['joinedDate']),
      validTill: DateTime.parse(map['validTill']),
      isActive: map['isActive'] == 1,
    );
  }
}
