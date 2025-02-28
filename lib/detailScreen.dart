import 'package:account/model/training_session.dart';
import 'package:flutter/material.dart';
import 'editScreen.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatelessWidget {
  final TrainingSession session;
  const DetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    // ฟอร์แมทวันที่เริ่มต้นและสิ้นสุด
    String formattedStartDate = session.startDate != null
        ? DateFormat('yyyy-MM-dd').format(session.startDate!)
        : 'N/A';
    String formattedEndDate = session.endDate != null
        ? DateFormat('yyyy-MM-dd').format(session.endDate!)
        : 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text("รายละเอียดการอบรม", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          // เพิ่ม Row เพื่อจัดเรียงปุ่มแก้ไขและลบไว้ข้างๆ กัน
          Row(
            children: [
              // ปุ่มแก้ไข
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.deepOrangeAccent, size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditScreen(session: session),
                    ),
                  );
                },
              ),
              // ปุ่มลบ
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('ยืนยันการลบ', style: TextStyle(fontWeight: FontWeight.bold)),
                        content: const Text('คุณต้องการลบรายการนี้ใช่หรือไม่?'),
                        actions: [
                          TextButton(
                            child: const Text('ยกเลิก', style: TextStyle(color: Colors.blue)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('ลบรายการ', style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              // เพิ่มฟังก์ชันการลบที่เหมาะสมที่นี่
                              // Provider.of<TrainingProvider>(context, listen: false).deleteTrainingSession(session);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // แสดงรูปภาพ
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                session.imageUrl,  
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            // ชื่อการอบรม
            Text(
              session.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 24, 
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            // ผู้สอน
            Text(
              'ผู้สอน: ${session.instructor}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.deepPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            // คำอธิบาย
            Text(
              'คำอธิบาย: ${session.description}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            // ระยะเวลาอบรม
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  'ระยะเวลาอบรม: $formattedStartDate ถึง $formattedEndDate',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // ค่าใช้จ่าย
            Row(
              children: [
                const Icon(Icons.attach_money, size: 18, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  'ค่าใช้จ่าย: ${session.cost} บาท',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
