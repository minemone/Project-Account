class TrainingSession {
  int? keyID;
  String title;
  double cost;
  DateTime? startDate;  // วันที่เริ่มต้นอบรม
  DateTime? endDate;    // วันที่สิ้นสุดอบรม
  String description;
  String instructor;

  TrainingSession({
    this.keyID,
    required this.title,
    required this.cost,
    this.startDate,
    this.endDate,
    required this.description,
    required this.instructor,
  });

  // แปลงเป็น Map สำหรับบันทึกลงฐานข้อมูล
  Map<String, dynamic> toMap() {
    return {
      'keyID': keyID,
      'title': title,
      'cost': cost,
      'description': description,
      'instructor': instructor,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  // โหลดจาก Map (เช่น จากฐานข้อมูล SQLite)
  factory TrainingSession.fromMap(Map<String, dynamic> map) {
    return TrainingSession(
      keyID: map['keyID'],
      title: map['title'],
      cost: map['cost'],
      description: map['description'],
      instructor: map['instructor'],
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
    );
  }
}
