class HistoryRecord {
  final String id;
  final String diagnosis;
  final double confidence;
  final DateTime dateTime;
  final String? imagePath;
  final List<double>? allPredictions;

  HistoryRecord({
    required this.id,
    required this.diagnosis,
    required this.confidence,
    required this.dateTime,
    this.imagePath,
    this.allPredictions,
  });

  //transformar analisis a historial
  factory HistoryRecord.fromAnalysisResult(AnalysisResult result) {
    return HistoryRecord(
      id: result.id,
      diagnosis: result.className,
      confidence: result.confidence / 100.0,
      dateTime: result.date,
      imagePath: result.imagePath,
      allPredictions: result.allPredictions,
    );
  }
}

// Clase auxiliar para la cámara (puede ir en el mismo archivo o en uno separado)
class AnalysisResult {
  final String id;
  final String imagePath;
  final String className;
  final double confidence;
  final DateTime date;
  final List<double> allPredictions;

  AnalysisResult({
    required this.id,
    required this.imagePath,
    required this.className,
    required this.confidence,
    required this.date,
    required this.allPredictions,
  });

  String get formattedDate => '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  String get confidencePercent => '${confidence.toStringAsFixed(1)}%';
}