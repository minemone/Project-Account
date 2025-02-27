import 'dart:io';
import 'package:account/model/training_session.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class TrainingDB {
  String dbName;

  TrainingDB({required this.dbName});

  // เปิดฐานข้อมูล
  Future<Database> openDatabase() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDir.path, dbName);
    DatabaseFactory dbFactory = databaseFactoryIo;
    Database db = await dbFactory.openDatabase(dbLocation);
    return db;
  }

  // เพิ่มข้อมูลลงฐานข้อมูล
  Future<int> insertDatabase(TrainingSession session) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('training');
    Future<int> keyID = store.add(db, {
      'title': session.title,
      'cost': session.cost,
      'startDate': session.startDate?.toIso8601String(),  // เพิ่มการจัดการ startDate
      'endDate': session.endDate?.toIso8601String(),      // เพิ่มการจัดการ endDate
      'description': session.description,  // เพิ่ม description
      'instructor': session.instructor,    // เพิ่ม instructor
    });
    db.close();
    return keyID;
  }

  // โหลดข้อมูลทั้งหมดจากฐานข้อมูล
  Future<List<TrainingSession>> loadAllData() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('training');
    var snapshot = await store.find(db, finder: Finder(sortOrders: [SortOrder('startDate', false)]));
    List<TrainingSession> sessions = [];
    for (var record in snapshot) {
      TrainingSession session = TrainingSession(
        keyID: record.key,
        title: record['title'].toString(),
        cost: double.parse(record['cost'].toString()),
        startDate: record['startDate'] != null ? DateTime.parse(record['startDate'].toString()) : null,  // แปลง startDate
        endDate: record['endDate'] != null ? DateTime.parse(record['endDate'].toString()) : null,      // แปลง endDate
        description: record['description'].toString(),  // อ่าน description
        instructor: record['instructor'].toString(),    // อ่าน instructor
      );
      sessions.add(session);
    }
    db.close();
    return sessions;
  }

  // ลบข้อมูลจากฐานข้อมูล
  Future deleteData(TrainingSession session) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('training');
    await store.delete(db, finder: Finder(filter: Filter.equals(Field.key, session.keyID)));
    db.close();
  }

  // อัปเดตข้อมูลในฐานข้อมูล
  Future updateData(TrainingSession session) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('training');
    await store.update(
      db,
      {
        'title': session.title,
        'cost': session.cost,
        'startDate': session.startDate?.toIso8601String(),  // อัปเดต startDate
        'endDate': session.endDate?.toIso8601String(),      // อัปเดต endDate
        'description': session.description, // อัปเดต description
        'instructor': session.instructor,   // อัปเดต instructor
      },
      finder: Finder(filter: Filter.equals(Field.key, session.keyID)),
    );
    db.close();
  }
}
