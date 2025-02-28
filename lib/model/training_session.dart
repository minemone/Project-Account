class TrainingSession {
  int? keyID;
  String title;
  double cost;
  DateTime? startDate;  // วันที่เริ่มต้น
  DateTime? endDate;    // วันที่สิ้นสุด
  String description;
  String instructor;
  String imageUrl; // URL ของรูปภาพ

  TrainingSession({
    this.keyID,
    required this.title,
    required this.cost,
    this.startDate,
    this.endDate,
    required this.description,
    required this.instructor,
    required this.imageUrl,  // เพิ่มการเก็บ URL รูปภาพ
  });

  // แปลงเป็น Map สำหรับบันทึกลงฐานข้อมูล
  Map<String, dynamic> toMap() {
    return {
      'keyID': keyID,
      'title': title,
      'cost': cost,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'description': description,
      'instructor': instructor,
      'imageUrl': imageUrl,  // เพิ่มการจัดการรูปภาพ
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
      imageUrl: map['imageUrl'],  // อ่าน URL รูปภาพ
    );
  }
}
