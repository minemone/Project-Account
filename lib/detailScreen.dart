import 'package:account/model/training_session.dart';
import 'package:flutter/material.dart';
import 'editScreen.dart';
import 'package:intl/intl.dart';
import 'package:account/provider/training_provider.dart';
import 'package:provider/provider.dart';

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
                        content: const Text('คุณต้องการลบรายการนี้ใช่หรือไม่ ?'),
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
                              // เรียกใช้ฟังก์ชันการลบจาก Provider
                              Provider.of<TrainingProvider>(context, listen: false)
                                  .deleteTrainingSession(session);
                              Navigator.of(context).pop(); // ปิด AlertDialog
                              Navigator.of(context).pop(); // กลับไปที่หน้าก่อนหน้า
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
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              session.title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 24, 
                  color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Instructor: ${session.instructor}',
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Description: ${session.description}',
              style: const TextStyle(fontSize: 16, color: Colors.black),
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.black),
                const SizedBox(width: 5),
                Text(
                  'ระยะเวลาอบรม: $formattedStartDate ถึง $formattedEndDate',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 18, color: Colors.black),
                const SizedBox(width: 5),
                Text(
                  session.cost == 0.0
                      ? 'ซื้อแล้ว' // ถ้าซื้อแล้วจะขึ้นคำว่า "ซื้อแล้ว"
                      : 'ค่าใช้จ่าย: ${session.cost} บาท',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: session.cost == 0.0 ? Colors.red : Colors.black87, // เปลี่ยนสีเมื่อซื้อแล้ว
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ปุ่มสำหรับซื้อ
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('ยืนยันการซื้อ', style: TextStyle(fontWeight: FontWeight.bold)),
                      content: const Text('คุณต้องการซื้อโปรแกรมนี้ใช่หรือไม่?'),
                      actions: [
                        TextButton(
                          child: const Text('ยกเลิก', style: TextStyle(color: Colors.blue)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('ยืนยันการซื้อ', style: TextStyle(color: Colors.green)),
                          onPressed: () {
                            // ฟังก์ชันการซื้อ (อัปเดตสถานะ)
                            session.cost = 0.0; // เปลี่ยนราคาหลังการซื้อ
                            Provider.of<TrainingProvider>(context, listen: false)
                                .updateTrainingSession(session);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'ซื้อโปรแกรม',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
