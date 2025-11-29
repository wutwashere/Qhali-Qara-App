import 'package:flutter/material.dart';

import '../../models/alert.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<Alert> _alerts = [];
  bool _isLoading = true;
  String _filter = 'all'; // 'all', 'unread', 'high_risk'

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    // Simular carga
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _alerts = _getMockAlerts();
      _isLoading = false;
    });
  }

  List<Alert> _getFilteredAlerts() {
    switch (_filter) {
      case 'unread':
        return _alerts.where((alert) => !alert.isRead).toList();
      case 'high_risk':
        return _alerts.where((alert) => alert.type == 'HIGH_RISK').toList();
      default:
        return _alerts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAlerts = _getFilteredAlerts();

    return Scaffold(
      appBar: AppBar(
        title: Text('Alertas'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        actions: [
          if (_alerts.any((alert) => !alert.isRead))
            IconButton(
              icon: Badge(
                label: Text(_alerts.where((alert) => !alert.isRead).length.toString()),
                child: Icon(Icons.notifications),
              ),
              onPressed: _markAllAsRead,
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filter = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Todas las alertas'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'unread',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_unread, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('No leídas'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'high_risk',
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Alto riesgo'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : filteredAlerts.isEmpty
          ? _buildEmptyState()
          : _buildAlertsList(filteredAlerts),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.amber),
          SizedBox(height: 16),
          Text('Cargando alertas...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No hay alertas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            _filter == 'all'
                ? 'No tienes alertas en este momento'
                : _filter == 'unread'
                ? 'No hay alertas sin leer'
                : 'No hay alertas de alto riesgo',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList(List<Alert> alerts) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        return _buildAlertCard(alerts[index]);
      },
    );
  }

  Widget _buildAlertCard(Alert alert) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: alert.isRead ? Colors.white : Colors.blue[50],
      elevation: alert.isRead ? 1 : 2,
      child: ListTile(
        leading: _buildAlertIcon(alert.type),
        title: Text(
          alert.title,
          style: TextStyle(
            fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.message),
            SizedBox(height: 4),
            Text(
              _formatTimeAgo(alert.date),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: !alert.isRead
            ? Icon(Icons.circle, color: Colors.red, size: 12)
            : null,
        onTap: () => _showAlertDetails(alert),
        onLongPress: () => _markAsRead(alert),
      ),
    );
  }

  Widget _buildAlertIcon(String type) {
    switch (type) {
      case 'HIGH_RISK':
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.warning, color: Colors.red, size: 24),
        );
      case 'SYSTEM':
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.info, color: Colors.blue, size: 24),
        );
      case 'REMINDER':
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.calendar_today, color: Colors.amber, size: 24),
        );
      default:
        return Icon(Icons.notifications, color: Colors.grey, size: 24);
    }
  }

  void _showAlertDetails(Alert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            _buildAlertIcon(alert.type),
            SizedBox(width: 8),
            Expanded(child: Text(alert.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.message),
            SizedBox(height: 16),
            Text(
              'Fecha: ${_formatDateTime(alert.date)}',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          if (!alert.isRead)
            TextButton(
              onPressed: () {
                _markAsRead(alert);
                Navigator.pop(context);
              },
              child: Text('Marcar como leída'),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );

    // Marcar como leída al ver detalles
    if (!alert.isRead) {
      _markAsRead(alert);
    }
  }

  void _markAsRead(Alert alert) {
    setState(() {
      alert.isRead = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var alert in _alerts) {
        alert.isRead = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Todas las alertas marcadas como leídas'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Ahora mismo';
    if (difference.inMinutes < 60) return 'Hace ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'Hace ${difference.inHours} h';
    if (difference.inDays < 7) return 'Hace ${difference.inDays} días';
    return 'El ${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  List<Alert> _getMockAlerts() {
    return [
      Alert(
        id: '1',
        type: 'HIGH_RISK',
        title: 'Posible melanoma detectado',
        message: 'Tu último análisis mostró características de melanoma. Consulta con un especialista.',
        date: DateTime.now().subtract(Duration(hours: 2)),
        isRead: false,
      ),
      Alert(
        id: '2',
        type: 'REMINDER',
        title: 'Recordatorio de seguimiento',
        message: 'Es hora de realizar un nuevo análisis de seguimiento.',
        date: DateTime.now().subtract(Duration(days: 1)),
        isRead: true,
      ),
      Alert(
        id: '3',
        type: 'SYSTEM',
        title: 'Actualización del sistema',
        message: 'El modelo de IA ha sido mejorado para mayor precisión.',
        date: DateTime.now().subtract(Duration(days: 3)),
        isRead: true,
      ),
      Alert(
        id: '4',
        type: 'HIGH_RISK',
        title: 'Alerta de riesgo moderado',
        message: 'Se detectó carcinoma de células basales. Programa una consulta.',
        date: DateTime.now().subtract(Duration(days: 5)),
        isRead: false,
      ),
    ];
  }
}