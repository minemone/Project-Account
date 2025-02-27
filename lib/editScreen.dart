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

class _EditScreenState extends State<EditScreen> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final instructorController = TextEditingController();

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.session.title;
    amountController.text = widget.session.cost.toString();
    descriptionController.text = widget.session.description;
    instructorController.text = widget.session.instructor;
    _selectedStartDate = widget.session.startDate;
    _selectedEndDate = widget.session.endDate;
  }

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

  void _submitData() {
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
    );

    Provider.of<TrainingProvider>(context, listen: false)
        .updateTrainingSession(updatedSession);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูล'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
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
                // ช่องสำหรับรายละเอียด (Description)
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
                // ช่องสำหรับผู้สอน (Instructor)
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
                // ช่องเลือกวันเริ่มต้นอบรม
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
                // ช่องเลือกวันสิ้นสุดอบรม
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
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'แก้ไขข้อมูล',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
