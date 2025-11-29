class Alert {
  final String id;
  final String type; // 'HIGH_RISK', 'REMINDER', 'SYSTEM'
  final String title;
  final String message;
  final DateTime date;
  bool isRead;

  Alert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
  });
}