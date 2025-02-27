import 'package:account/model/training_session.dart';
import 'package:account/provider/training_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final instructorController = TextEditingController();

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

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
  void _submitData() {
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

    final session = TrainingSession(
      title: enteredTitle,
      cost: enteredAmount,
      startDate: _selectedStartDate,
      endDate: _selectedEndDate,
      description: enteredDescription,
      instructor: enteredInstructor,
    );

    Provider.of<TrainingProvider>(context, listen: false)
        .addTrainingSession(session);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('เพิ่มข้อมูล'),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'ชื่อโปรแกรมฝึกอบรม'),
                  controller: titleController,
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
                  decoration: const InputDecoration(labelText: 'ค่าใช้จ่าย'),
                  controller: amountController,
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
                  decoration: const InputDecoration(labelText: 'รายละเอียด'),
                  controller: descriptionController,
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
                  decoration: const InputDecoration(labelText: 'ผู้สอน'),
                  controller: instructorController,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "กรุณาป้อนชื่อผู้สอน";
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
                    'เพิ่มข้อมูล',
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
