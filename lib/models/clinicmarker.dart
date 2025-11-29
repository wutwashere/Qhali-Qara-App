
import 'package:latlong2/latlong.dart';

class ClinicMarker {
  final String id;
  final LatLng position;
  final String name;
  final String type;
  final String address;
  final String? phone;
  final String? schedule;

  ClinicMarker({
    required this.id,
    required this.position,
    required this.name,
    required this.type,
    required this.address,
    this.phone,
    this.schedule,
  });
}

final List<ClinicMarker> clinics = [
  /*ClinicMarker(
    id: '1',
    position: LatLng(-12.0464, -77.0428), // Lima
    name: 'Hospital Nacional Arzobispo Loayza',
    type: 'hospital',
    address: 'Av. Alfonso Ugarte 848, Lima',
    phone: '(01) 315-6600',
    schedule: 'Lun-Vie: 7:00 AM - 7:00 PM',
  ),
  ClinicMarker(
    id: '2',
    position: LatLng(-12.0670, -77.0335), // Lima Centro
    name: 'Clínica Internacional',
    type: 'clinic',
    address: 'Av. Salaverry 1196, Jesús María',
    phone: '(01) 619-6161',
    schedule: 'Lun-Dom: 24 horas',
  ),
  ClinicMarker(
    id: '3',
    position: LatLng(-12.0934, -77.0195), // Miraflores
    name: 'Clínica Ricardo Palma',
    type: 'clinic',
    address: 'Av. Javier Prado Este 1066, San Isidro',
    phone: '(01) 224-2224',
    schedule: 'Lun-Dom: 24 horas',
  ),
  ClinicMarker(
    id: '4',
    position: LatLng(-12.1165, -77.0423), // Barranco
    name: 'Hospital de la Policía Nacional del Perú',
    type: 'hospital',
    address: 'Av. Guardia Chalaca 995, Callao',
    phone: '(01) 514-5757',
    schedule: 'Lun-Dom: 24 horas',
  ),
   */
];
