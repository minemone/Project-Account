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

  @override
  void initState() {
    super.initState();
    titleController.text = widget.session.title;
    amountController.text = widget.session.cost.toString();
  }

  void _submitData() {
    if (!formKey.currentState!.validate()) return;

    final updatedSession = TrainingSession(
      keyID: widget.session.keyID,
      title: titleController.text,
      cost: double.parse(amountController.text),
      date: widget.session.date, // ถ้าต้องการอัปเดตวันที่ สามารถใช้ DateTime.now() แทน
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
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
    );
  }
}
