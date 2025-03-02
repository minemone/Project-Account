import 'package:account/model/training_session.dart';
import 'package:account/provider/training_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final instructorController = TextEditingController();
  final imageUrlController = TextEditingController(); // สำหรับกรอก URL รูปภาพ

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _isLoading = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ฟังก์ชันเลือกวันเริ่มต้น
  void _presentStartDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedStartDate = pickedDate;
      });
    }
  }

  // ฟังก์ชันเลือกวันสิ้นสุด
  void _presentEndDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedEndDate = pickedDate;
      });
    }
  }

  // ฟังก์ชันส่งข้อมูล
  Future<void> _submitData() async {
    if (!formKey.currentState!.validate()) return;

    if (_selectedStartDate == null || _selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกวันเริ่มต้นและวันสิ้นสุดอบรม')),
      );
      return;
    }

    if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('วันสิ้นสุดต้องไม่ก่อนวันเริ่มต้น')),
      );
      return;
    }

    final enteredTitle = titleController.text;
    final enteredAmount = double.tryParse(amountController.text);
    final enteredDescription = descriptionController.text;
    final enteredInstructor = instructorController.text;

    if (enteredAmount == null || enteredAmount <= 0) return;

    // ใช้ URL รูปภาพที่กรอกมา
    final imageUrl = imageUrlController.text;

    final session = TrainingSession(
      title: enteredTitle,
      cost: enteredAmount,
      startDate: _selectedStartDate,
      endDate: _selectedEndDate,
      description: enteredDescription,
      instructor: enteredInstructor,
      imageUrl: imageUrl, // ใช้ URL ของรูปภาพ
    );

    setState(() {
      _isLoading = true;
    });

    try {
       Provider.of<TrainingProvider>(context, listen: false).addTrainingSession(session);
      await Future.delayed(const Duration(seconds: 2)); // แสดง Loading Animation 3 วินาที
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('เพิ่มข้อมูลสำเร็จ', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('คุณได้เพิ่มข้อมูลโปรแกรมฝึกอบรมเรียบร้อยแล้ว'),
            actions: [
              TextButton(
                child: const Text('ตกลง', style: TextStyle(color: Colors.green)),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // ปิดหน้าฟอร์ม
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('เพิ่มข้อมูล'),
      ),
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'ชื่อโปรแกรมฝึกอบรม'),
                      autofocus: true,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "กรุณาป้อนชื่อโปรแกรม";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: 'ค่าใช้จ่าย'),
                      keyboardType: TextInputType.number,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "กรุณาป้อนจำนวนเงิน";
                        }
                        try {
                          double cost = double.parse(value);
                          if (cost <= 0) {
                            return "กรุณาป้อนจำนวนเงินที่มากกว่า 0";
                          }
                        } catch (e) {
                          return "กรุณาป้อนเป็นตัวเลขเท่านั้น";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'รายละเอียด'),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "กรุณาป้อนรายละเอียด";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: instructorController,
                      decoration: const InputDecoration(labelText: 'ผู้สอน'),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "กรุณาป้อนชื่อผู้สอน";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // ช่องสำหรับกรอก URL ของภาพ
                    TextFormField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(labelText: 'กรอก URL รูปภาพ'),
                      keyboardType: TextInputType.url,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "กรุณากรอก URL ของรูปภาพ";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // ช่องเลือกวันที่เริ่มต้น
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedStartDate == null
                                ? 'ยังไม่เลือกวันเริ่มต้นอบรม'
                                : 'เริ่ม: ${_selectedStartDate!.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        TextButton(
                          onPressed: _presentStartDatePicker,
                          child: const Text('เลือกวันเริ่มต้น'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // ช่องเลือกวันที่สิ้นสุด
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedEndDate == null
                                ? 'ยังไม่เลือกวันสิ้นสุดอบรม'
                                : 'สิ้นสุด: ${_selectedEndDate!.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        TextButton(
                          onPressed: _presentEndDatePicker,
                          child: const Text('เลือกวันสิ้นสุด'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const Text('กำลังเพิ่มข้อมูล...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                          : const Text('เพิ่มข้อมูล', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: _controller.drive(ColorTween(
                        begin: Colors.blue,
                        end: Colors.red,
                      )),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'กำลังเพิ่มข้อมูล...',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}