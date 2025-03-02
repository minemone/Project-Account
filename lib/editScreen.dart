import 'package:account/model/training_session.dart';
import 'package:account/provider/training_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditScreen extends StatefulWidget {
  final TrainingSession session;
  const EditScreen({super.key, required this.session});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> with SingleTickerProviderStateMixin {
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

    titleController.text = widget.session.title;
    amountController.text = widget.session.cost.toString();
    descriptionController.text = widget.session.description;
    instructorController.text = widget.session.instructor;
    imageUrlController.text = widget.session.imageUrl; // กำหนดค่าจากข้อมูลเดิม
    _selectedStartDate = widget.session.startDate; // กำหนดวันที่เริ่มต้นจากข้อมูลเดิม
    _selectedEndDate = widget.session.endDate; // กำหนดวันที่สิ้นสุดจากข้อมูลเดิม
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ฟังก์ชันสำหรับเลือกวันที่เริ่มต้น
  Future<void> _selectStartDate() async {
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

  // ฟังก์ชันสำหรับเลือกวันที่สิ้นสุด
  Future<void> _selectEndDate() async {
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
        const SnackBar(content: Text('กรุณาเลือกวันที่เริ่มต้นและสิ้นสุดอบรม')),
      );
      return;
    }

    if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('วันสิ้นสุดต้องไม่ก่อนวันเริ่มต้น')),
      );
      return;
    }

    final updatedSession = TrainingSession(
      keyID: widget.session.keyID,
      title: titleController.text,
      cost: double.parse(amountController.text),
      startDate: _selectedStartDate,
      endDate: _selectedEndDate,
      description: descriptionController.text,
      instructor: instructorController.text,
      imageUrl: imageUrlController.text, // ใช้ URL ของรูปภาพ
    );

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<TrainingProvider>(context, listen: false).updateTrainingSession(updatedSession);
      await Future.delayed(const Duration(seconds: 2)); // แสดง Loading Animation 3 วินาที
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('แก้ไขข้อมูลสำเร็จ', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('คุณได้แก้ไขข้อมูลโปรแกรมฝึกอบรมเรียบร้อยแล้ว'),
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
        title: const Text('แก้ไขข้อมูล'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                    // ช่องสำหรับชื่อโปรแกรมฝึกอบรม
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'ชื่อโปรแกรมฝึกอบรม'),
                      autofocus: true,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณาป้อนชื่อโปรแกรม';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // ช่องสำหรับค่าใช้จ่าย
                    TextFormField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: 'ค่าใช้จ่าย'),
                      keyboardType: TextInputType.number,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณาป้อนจำนวนเงิน';
                        }
                        try {
                          double cost = double.parse(value);
                          if (cost <= 0) {
                            return 'กรุณาป้อนจำนวนเงินที่มากกว่า 0';
                          }
                        } catch (e) {
                          return 'กรุณาป้อนเป็นตัวเลขเท่านั้น';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // ช่องสำหรับรายละเอียด
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'รายละเอียด'),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณาป้อนรายละเอียด';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // ช่องสำหรับผู้สอน
                    TextFormField(
                      controller: instructorController,
                      decoration: const InputDecoration(labelText: 'ผู้สอน'),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณาป้อนชื่อผู้สอน';
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
                          return 'กรุณากรอก URL ของรูปภาพ';
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
                          onPressed: _selectStartDate,
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
                          onPressed: _selectEndDate,
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
                          ? const Text('กำลังแก้ไขข้อมูล...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                          : const Text('แก้ไขข้อมูล', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                      'กำลังแก้ไขข้อมูล...',
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