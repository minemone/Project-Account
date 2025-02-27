import 'package:account/model/training_session.dart';
import 'package:account/provider/training_provider.dart';
import 'package:flutter/material.dart';
import 'formScreen.dart';
import 'editScreen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TrainingProvider()),
      ],
      child: MaterialApp(
        title: 'Employee Training Program',
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Employee Training Program'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลจากฐานข้อมูลเมื่อเริ่มต้น
    Provider.of<TrainingProvider>(context, listen: false).initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const FormScreen();
              }));
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<TrainingProvider>(context, listen: false).initData();
            },
          ),
        ],
      ),
      body: Consumer<TrainingProvider>(
        builder: (context, provider, child) {
          int itemCount = provider.sessions.length;
          if (itemCount == 0) {
            return const Center(
              child: Text(
                'ไม่มีรายการ',
                style: TextStyle(fontSize: 50, color: Colors.grey),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: itemCount,
              itemBuilder: (context, int index) {
                TrainingSession data = provider.sessions[index];
                // Format startDate and endDate
                String formattedStartDate = data.startDate != null
                    ? DateFormat('yyyy-MM-dd').format(data.startDate!)
                    : 'N/A';
                String formattedEndDate = data.endDate != null
                    ? DateFormat('yyyy-MM-dd').format(data.endDate!)
                    : 'N/A';

                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    title: Text(
                      data.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ผู้สอน: ${data.instructor}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'รายละเอียด: ${data.description}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'ระยะเวลาอบรม: $formattedStartDate ถึง $formattedEndDate',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.lightBlueAccent,
                      child: FittedBox(
                        child: Text(
                          data.cost.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Color.fromARGB(255, 255, 0, 0)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('ยืนยันการลบ'),
                              content: const Text('คุณต้องการลบรายการใช่หรือไม่ ?'),
                              actions: [
                                TextButton(
                                  child: const Text('ยกเลิก'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('ลบรายการ'),
                                  onPressed: () {
                                    provider.deleteTrainingSession(data);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return EditScreen(session: data);
                      }));
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
