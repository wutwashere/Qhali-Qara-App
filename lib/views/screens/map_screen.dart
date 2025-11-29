import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/clinicmarker.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  double _currentZoom = 13.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(-12.0464, -77.0428), // Centro de Lima
          zoom: _currentZoom,
          onPositionChanged: (position, hasGesture) {
            if (hasGesture) {
              setState(() {
                _currentZoom = position.zoom!;
              });
            }
          },
        ),
        children: [
          // Capa de tiles (mapa)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.qhaliqara_app',
            subdomains: ['a', 'b', 'c'],
          ),

          // Capa de marcadores
          MarkerLayer(
            markers: _buildMarkers(),
          ),

          // Controles de zoom
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  onPressed: _zoomIn,
                  child: Icon(Icons.add),
                ),
                SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  onPressed: _zoomOut,
                  child: Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showClinicsList,
        child: Icon(Icons.list),
        tooltip: 'Ver lista de clínicas',
      ),
    );
  }

  List<Marker> _buildMarkers() {
    return clinics.map((clinic) {
      return Marker(
        point: clinic.position,
        width: 80.0,
        height: 80.0,
        child: GestureDetector(
          onTap: () => _showClinicDetails(clinic),
          child: _buildCustomMarker(clinic),
        ),
      );
    }).toList();
  }

  Widget _buildCustomMarker(ClinicMarker clinic) {
    final isHospital = clinic.type == 'hospital';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isHospital ? Colors.red : Colors.blue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isHospital ? Icons.local_hospital : Icons.medical_services,
            color: Colors.white,
            size: 20,
          ),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            clinic.name.split(' ').first, // Solo el primer nombre
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _showClinicDetails(ClinicMarker clinic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  clinic.type == 'hospital'
                      ? Icons.local_hospital
                      : Icons.medical_services,
                  color: clinic.type == 'hospital' ? Colors.red : Colors.blue,
                  size: 30,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    clinic.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildDetailRow(Icons.location_on, clinic.address),
            if (clinic.phone != null)
              _buildDetailRow(Icons.phone, clinic.phone!),
            if (clinic.schedule != null)
              _buildDetailRow(Icons.schedule, clinic.schedule!),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _launchMaps(clinic),
                    icon: Icon(Icons.directions),
                    label: Text('Cómo llegar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                if (clinic.phone != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _launchPhone(clinic.phone!),
                      icon: Icon(Icons.call),
                      label: Text('Llamar'),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showClinicsList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Clínicas Disponibles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: clinics.length,
                itemBuilder: (context, index) {
                  final clinic = clinics[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        clinic.type == 'hospital'
                            ? Icons.local_hospital
                            : Icons.medical_services,
                        color: clinic.type == 'hospital' ? Colors.red : Colors.blue,
                      ),
                      title: Text(clinic.name),
                      subtitle: Text(clinic.address),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(context);
                        _zoomToClinic(clinic);
                        _showClinicDetails(clinic);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _zoomToClinics() {
    if (clinics.isEmpty) return;

    double minLat = clinics.first.position.latitude;
    double maxLat = clinics.first.position.latitude;
    double minLng = clinics.first.position.longitude;
    double maxLng = clinics.first.position.longitude;

    for (var clinic in clinics) {
      minLat = min(minLat, clinic.position.latitude);
      maxLat = max(maxLat, clinic.position.latitude);
      minLng = min(minLng, clinic.position.longitude);
      maxLng = max(maxLng, clinic.position.longitude);
    }

    final bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );

    _mapController.fitBounds(
      bounds,
      options: FitBoundsOptions(
        padding: EdgeInsets.all(50.0),
      ),
    );
  }

  void _zoomToClinic(ClinicMarker clinic) {
    _mapController.move(clinic.position, 15.0);
  }

  void _zoomIn() {
    _mapController.move(_mapController.camera.center, _currentZoom + 1);
    setState(() {
      _currentZoom += 1;
    });
  }

  void _zoomOut() {
    _mapController.move(_mapController.camera.center, _currentZoom - 1);
    setState(() {
      _currentZoom -= 1;
    });
  }

  Future<void> _launchMaps(ClinicMarker clinic) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${clinic.position.latitude},${clinic.position.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _launchPhone(String phone) async {
    final url = 'tel:${phone.replaceAll(RegExp(r'[^0-9+]'), '')}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}