import 'dart:io';
import 'package:account/model/training_session.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class TrainingDB {
  String dbName;

  TrainingDB({required this.dbName});

  Future<Database> openDatabase() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDir.path, dbName);
    DatabaseFactory dbFactory = databaseFactoryIo;
    Database db = await dbFactory.openDatabase(dbLocation);
    return db;
  }

  Future<int> insertDatabase(TrainingSession session) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('training');
    Future<int> keyID = store.add(db, {
      'title': session.title,
      'cost': session.cost,
      'startDate': session.startDate?.toIso8601String(),
      'endDate': session.endDate?.toIso8601String(),
      'description': session.description,  // เพิ่ม description
      'instructor': session.instructor,    // เพิ่ม instructor
      'imageUrl': session.imageUrl,        // เพิ่ม imageUrl
    });
    db.close();
    return keyID;
  }

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
        startDate: record['startDate'] != null ? DateTime.parse(record['startDate'].toString()) : null,
        endDate: record['endDate'] != null ? DateTime.parse(record['endDate'].toString()) : null,
        description: record['description'].toString(),  // อ่าน description
        instructor: record['instructor'].toString(),    // อ่าน instructor
        imageUrl: record['imageUrl'].toString(),        // อ่าน imageUrl
      );
      sessions.add(session);
    }
    db.close();
    return sessions;
  }

  Future deleteData(TrainingSession session) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('training');
    await store.delete(db, finder: Finder(filter: Filter.equals(Field.key, session.keyID)));
    db.close();
  }

  Future updateData(TrainingSession session) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('training');
    await store.update(
      db,
      {
        'title': session.title,
        'cost': session.cost,
        'startDate': session.startDate?.toIso8601String(),
        'endDate': session.endDate?.toIso8601String(),
        'description': session.description, // อัปเดต description
        'instructor': session.instructor,   // อัปเดต instructor
        'imageUrl': session.imageUrl,       // อัปเดต imageUrl
      },
      finder: Finder(filter: Filter.equals(Field.key, session.keyID)),
    );
    db.close();
  }
}
