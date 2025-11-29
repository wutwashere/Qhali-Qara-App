import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qhaliqara_app/data/notifiers.dart';
import 'package:qhaliqara_app/models/historyrecord.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistoryRecords();
  }

  Future<void> _loadHistoryRecords() async {
    // Cargar desde storage si es necesario
    await loadHistoryFromStorage();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          'Historial',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Usar ValueListenableBuilder para mostrar el botón solo cuando hay registros
          ValueListenableBuilder<List<HistoryRecord>>(
            valueListenable: historyRecordsNotifier,
            builder: (context, records, child) {
              return records.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              )
                  : SizedBox.shrink();
            },
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : ValueListenableBuilder<List<HistoryRecord>>(
        valueListenable: historyRecordsNotifier,
        builder: (context, records, child) {
          return records.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(records);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.black),
          SizedBox(height: 16),
          Text(
            'Cargando historial',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 60),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 80,
              color: Colors.amber,
            ),
          ),
          SizedBox(height: 32),
          Text(
            'No hay registros',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Realiza tu primer análisis para comenzar tu historial.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
              selectedScreenNotifier.value = 2; // Índice de la cámara
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: Icon(Icons.camera_alt),
            label: Text('REALIZAR PRIMER ANÁLISIS'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
          SizedBox(height: 16),
          TextButton.icon(
            onPressed: _showDemoData,
            icon: Icon(Icons.visibility),
            label: Text('VER DATOS DEMO'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<HistoryRecord> records) {
    return Column(
      children: [
        _buildStatsHeader(records),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              return _buildHistoryCard(records[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(List<HistoryRecord> records) {
    final total = records.length;
    final highRisk = records.where((record) =>
    record.diagnosis == 'Melanoma' || record.diagnosis == 'Squamous_Cell_Carcinoma'
    ).length;
    final thisMonth = records.where((record) =>
        record.dateTime.isAfter(DateTime.now().subtract(Duration(days: 30)))
    ).length;

    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', total.toString(), Icons.assignment, Colors.blue),
          _buildStatItem('Riesgo Alto', highRisk.toString(), Icons.warning, Colors.red),
          _buildStatItem('Este Mes', thisMonth.toString(), Icons.calendar_today, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(HistoryRecord record) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _buildHistoryLeading(record),
        title: Text(
          record.diagnosis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confianza: ${(record.confidence * 100).toStringAsFixed(1)}%'),
            Text(
              _formatDate(record.dateTime),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showRecordDetails(record);
        },
      ),
    );
  }

  Widget _buildHistoryLeading(HistoryRecord record) {
    if (record.imagePath != null && File(record.imagePath!).existsSync()) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: FileImage(File(record.imagePath!)),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: _getColorForDiagnosis(record.diagnosis).withOpacity(0.2),
        ),
        child: Icon(
          _getIconForDiagnosis(record.diagnosis),
          color: _getColorForDiagnosis(record.diagnosis),
        ),
      );
    }
  }

  void _showRecordDetails(HistoryRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getIconForDiagnosis(record.diagnosis),
              color: _getColorForDiagnosis(record.diagnosis),
            ),
            SizedBox(width: 8),
            Text('Detalles del análisis'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (record.imagePath != null && File(record.imagePath!).existsSync()) ...[
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(File(record.imagePath!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],

              _buildDetailItem('Diagnóstico', record.diagnosis),
              _buildDetailItem('Confianza', '${(record.confidence * 100).toStringAsFixed(1)}%'),
              _buildDetailItem('Fecha', _formatDate(record.dateTime)),
              _buildDetailItem('Hora', _formatTime(record.dateTime)),

              if (record.allPredictions != null) ...[
                SizedBox(height: 16),
                Text(
                  'Todas las probabilidades:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ..._buildAllProbabilitiesList(record.allPredictions!),
              ],

              SizedBox(height: 16),
              Text(
                'Recomendación:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                _getRecommendation(record.diagnosis),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementar compartir
            },
            child: Text('Compartir'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAllProbabilitiesList(List<double> predictions) {
    final classes = [
      'Benign',
      'Squamous_Cell_Carcinoma',
      'Basal_Cell_Carcinoma',
      'Melanoma'
    ];

    return predictions.asMap().entries.map((entry) {
      final index = entry.key;
      final prob = entry.value * 100;
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(child: Text(classes[index])),
            Text('${prob.toStringAsFixed(1)}%'),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filtrar Historial'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.all_inclusive),
              title: Text('Todos los análisis'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.warning, color: Colors.red),
              title: Text('Solo alto riesgo'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Últimos 30 días'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDemoData() {
    final demoRecords = [
      HistoryRecord(
        id: '1',
        diagnosis: 'Benign',
        confidence: 0.85,
        dateTime: DateTime.now().subtract(Duration(days: 2)),
        allPredictions: [0.85, 0.05, 0.07, 0.03],
      ),
      HistoryRecord(
        id: '2',
        diagnosis: 'Melanoma',
        confidence: 0.72,
        dateTime: DateTime.now().subtract(Duration(days: 15)),
        allPredictions: [0.15, 0.08, 0.05, 0.72],
      ),
    ];

    historyRecordsNotifier.value = demoRecords;
  }

  Color _getColorForDiagnosis(String diagnosis) {
    switch (diagnosis) {
      case 'Melanoma': return Colors.red;
      case 'Basal_Cell_Carcinoma': return Colors.yellow;
      case 'Squamous_Cell_Carcinoma': return Colors.orange;
      default: return Colors.green;
    }
  }

  IconData _getIconForDiagnosis(String diagnosis) {
    switch (diagnosis) {
      case 'Melanoma': return Icons.warning;
      case 'Basal_Cell_Carcinoma': return Icons.info;
      case 'Squamous_Cell_Carcinoma': return Icons.error_outline;
      default: return Icons.check_circle;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getRecommendation(String diagnosis) {
    switch (diagnosis) {
      case 'Melanoma': return 'Consulta médica URGENTE recomendada.';
      case 'Squamous_Cell_Carcinoma': return 'Consulta médica recomendada en las próximas semanas.';
      case 'Basal_Cell_Carcinoma': return 'Consulta médica sugerida para seguimiento.';
      default: return 'Monitoreo regular recomendado.';
    }
  }
}