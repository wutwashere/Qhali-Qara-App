import 'package:flutter/foundation.dart';

import '../models/historyrecord.dart';

class HistoryNotifier extends ChangeNotifier {
  List<HistoryRecord> _records = [];

  List<HistoryRecord> get records => _records;

  void addRecord(HistoryRecord record) {
    _records.insert(0, record);
    notifyListeners();
    _saveToStorage();
  }

  void removeRecord(String id) {
    _records.removeWhere((record) => record.id == id);
    notifyListeners();
    _saveToStorage();
  }

  void clearRecords() {
    _records.clear();
    notifyListeners();
    _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    //guardado
    await Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> loadFromStorage() async {
    // cargar
    await Future.delayed(Duration(milliseconds: 100));
    notifyListeners();
  }

  // Estadísticas
  int get totalRecords => _records.length;

  int get highRiskRecords => _records.where((record) =>
  record.diagnosis == 'Melanoma' || record.diagnosis == 'Squamous_Cell_Carcinoma'
  ).length;

  int get thisMonthRecords => _records.where((record) =>
      record.dateTime.isAfter(DateTime.now().subtract(Duration(days: 30)))
  ).length;
}