import 'package:account/model/training_session.dart';
import 'package:account/provider/training_provider.dart';
import 'package:flutter/material.dart';
import 'formScreen.dart';
import 'detailScreen.dart'; // เพิ่มการอ้างอิงไฟล์ใหม่
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';

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
  // ฟังก์ชันสุ่มสีที่ตัดกับสีอ่อน
  Color _getRandomColor() {
    // สุ่มจากสีที่มีความเข้มสูง
    List<Color> colorList = [
      Colors.red.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.purple.shade700,
      Colors.deepOrange.shade700,
      Colors.amber.shade700,
      Colors.cyan.shade700,
    ];

    Random random = Random();
    return colorList[random.nextInt(colorList.length)];
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

                // ฟอร์แมทวันที่เริ่มต้นและสิ้นสุด
                String formattedStartDate = data.startDate != null
                    ? DateFormat('yyyy-MM-dd').format(data.startDate!)
                    : 'N/A';
                String formattedEndDate = data.endDate != null
                    ? DateFormat('yyyy-MM-dd').format(data.endDate!)
                    : 'N/A';

                // สุ่มสีที่ตัดกับสีอ่อน
                Color randomColor = _getRandomColor();

                return Card(
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  color: randomColor, // ใช้สีที่สุ่ม
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // เพิ่มความโค้งมน
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(session: data),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        // แสดงรูปภาพ
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Image.network(
                            data.imageUrl, // แสดง URL ของรูปภาพ
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                data.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors
                                      .white, // ใช้สีขาวเพื่อให้ตัดกับพื้นหลัง
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),

                              // Instructor
                              Text(
                                'Instructor: ${data.instructor}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              const SizedBox(height: 8),

                              // Description
                              Text(
                                'Description: ${data.description}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),

                              // Duration
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Duration: $formattedStartDate to $formattedEndDate',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Cost
                              Row(
                                children: [
                                  const Icon(
                                    Icons.attach_money,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    data.cost == 0.0
                                        ? 'ซื้อแล้ว'
                                        : 'Cost: ${data.cost} THB',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: data.cost == 0.0
                                          ? const Color.fromARGB(255, 255, 255, 255)
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
