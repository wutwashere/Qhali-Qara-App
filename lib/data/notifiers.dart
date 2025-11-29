//ValueNotifier: hold data
//ValueListenableBuilder: Listen to the data (don't need setstate)

import 'package:flutter/material.dart';
import '../models/historyrecord.dart';

// ValueNotifier para la navegación
ValueNotifier<int> selectedScreenNotifier = ValueNotifier(0);

// ValueNotifier para el historial
ValueNotifier<List<HistoryRecord>> historyRecordsNotifier = ValueNotifier([]);

// Funciones para manejar el historial
void addHistoryRecord(HistoryRecord record) {
  final currentRecords = List<HistoryRecord>.from(historyRecordsNotifier.value);
  currentRecords.insert(0, record);
  historyRecordsNotifier.value = currentRecords;
  _saveHistoryToStorage(currentRecords);
}

void removeHistoryRecord(String id) {
  final currentRecords = List<HistoryRecord>.from(historyRecordsNotifier.value);
  currentRecords.removeWhere((record) => record.id == id);
  historyRecordsNotifier.value = currentRecords;
  _saveHistoryToStorage(currentRecords);
}

Future<void> _saveHistoryToStorage(List<HistoryRecord> records) async {
  // TODO: Implementar guardado en SharedPreferences
  await Future.delayed(Duration(milliseconds: 100));
}

Future<void> loadHistoryFromStorage() async {
  // TODO: Implementar carga desde almacenamiento
  await Future.delayed(Duration(milliseconds: 100));
  // historyRecordsNotifier.value = recordsCargados;
}

// Funciones de utilidad para estadísticas
int get totalHistoryRecords => historyRecordsNotifier.value.length;

int get highRiskHistoryRecords => historyRecordsNotifier.value.where((record) =>
record.diagnosis == 'Melanoma' || record.diagnosis == 'Squamous_Cell_Carcinoma'
).length;

int get thisMonthHistoryRecords => historyRecordsNotifier.value.where((record) =>
    record.dateTime.isAfter(DateTime.now().subtract(Duration(days: 30)))
).length;