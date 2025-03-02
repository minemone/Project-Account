import 'package:account/model/training_session.dart';
import 'package:flutter/material.dart';
import 'editScreen.dart';
import 'package:intl/intl.dart';
import 'package:account/provider/training_provider.dart';
import 'package:provider/provider.dart';

class DetailScreen extends StatefulWidget {
  final TrainingSession session;
  const DetailScreen({super.key, required this.session});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isLoading = false;
  bool _isDeleting = false;

  Future<void> _submitData() async {
    setState(() {
      _isLoading = true;
    });

    widget.session.cost = 0.0;

    try {
      await Provider.of<TrainingProvider>(context, listen: false)
          .updateTrainingSession(widget.session);
      await Future.delayed(const Duration(seconds: 3)); // แสดง Loading Animation 3 วินาที
      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('การซื้อสำเร็จ', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('คุณได้ซื้อโปรแกรมนี้เรียบร้อยแล้ว'),
            actions: [
              TextButton(
                child: const Text('ตกลง', style: TextStyle(color: Colors.green)),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // ปิดหน้ารายละเอียด
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<void> _deleteData() async {
    setState(() {
      _isDeleting = true;
    });

    try {
       Provider.of<TrainingProvider>(context, listen: false)
          .deleteTrainingSession(widget.session);
      await Future.delayed(const Duration(seconds: 3)); // แสดง Loading Animation 3 วินาที
      setState(() {
        _isDeleting = false;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('ลบข้อมูลสำเร็จ', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('คุณได้ลบข้อมูลโปรแกรมฝึกอบรมเรียบร้อยแล้ว'),
            actions: [
              TextButton(
                child: const Text('ตกลง', style: TextStyle(color: Colors.green)),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedStartDate = widget.session.startDate != null
        ? DateFormat('yyyy-MM-dd').format(widget.session.startDate!)
        : 'N/A';
    String formattedEndDate = widget.session.endDate != null
        ? DateFormat('yyyy-MM-dd').format(widget.session.endDate!)
        : 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text("รายละเอียดการอบรม", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.deepOrangeAccent, size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditScreen(session: widget.session),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                onPressed: _isDeleting ? null : () {
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
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await _deleteData();
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.session.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.session.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  'Instructor: ${widget.session.instructor}',
                  style: const TextStyle(fontSize: 16, color: Colors.deepPurple, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Description: ${widget.session.description}',
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
                      widget.session.cost == 0.0
                          ? 'ซื้อแล้ว'
                          : 'ค่าใช้จ่าย: ${widget.session.cost} บาท',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: widget.session.cost == 0.0 ? Colors.red : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('ยืนยันการซื้อ', style: TextStyle(fontWeight: FontWeight.bold)),
                          content: const Text('คุณต้องการซื้อโปรแกรมนี้ใช่หรือไม่ ?'),
                          actions: [
                            TextButton(
                              child: const Text('ยกเลิก', style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('ยืนยันการซื้อ', style: TextStyle(color: Colors.green)),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await _submitData();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: _isLoading
                      ? const Text('กำลังซื้อ...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                      : const Text('ซื้อโปรแกรม', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          if (_isLoading || _isDeleting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}