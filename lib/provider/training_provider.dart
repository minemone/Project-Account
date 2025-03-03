import 'package:flutter/foundation.dart';
import 'package:employeetrainingprogram_app/model/training_session.dart';
import 'package:employeetrainingprogram_app/database/training_db.dart';

class TrainingProvider with ChangeNotifier {
  List<TrainingSession> sessions = [];

  List<TrainingSession> getTrainingSessions() => sessions;

  void initData() async {
    var db = TrainingDB(dbName: 'training.db');
    sessions = await db.loadAllData();
    notifyListeners();
  }

  void addTrainingSession(TrainingSession session) async {
    var db = TrainingDB(dbName: 'training.db');
    await db.insertDatabase(session);
    sessions = await db.loadAllData();
    notifyListeners();
  }

  void deleteTrainingSession(TrainingSession session) async {
    var db = TrainingDB(dbName: 'training.db');
    await db.deleteData(session);
    sessions = await db.loadAllData();
    notifyListeners();
  }

  Future<void> updateTrainingSession(TrainingSession session) async {
    var db = TrainingDB(dbName: 'training.db');
    await db.updateData(session);
    sessions = await db.loadAllData();
    notifyListeners();
  }
}