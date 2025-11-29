import 'package:flutter/material.dart';

import '../../models/specialist.dart';

class SpecialistsScreen extends StatelessWidget {
  const SpecialistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Especialistas'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Header con búsqueda
          _buildSearchHeader(),

          // Categorías
          _buildCategories(),

          // Lista de especialistas
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _getSpecialists().length,
              itemBuilder: (context, index) {
                return _buildSpecialistCard(context, _getSpecialists()[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          Text(
            'Encuentra Especialistas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar dermatólogos...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'icon': Icons.local_hospital, 'name': 'Hospitales', 'color': Colors.red},
      {'icon': Icons.medical_services, 'name': 'Clínicas', 'color': Colors.blue},
      {'icon': Icons.person, 'name': 'Privados', 'color': Colors.green},
      {'icon': Icons.video_call, 'name': 'Online', 'color': Colors.purple},
    ];

    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryItem(
            category['icon'] as IconData,
            category['name'] as String,
            category['color'] as Color,
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String name, Color color) {
    return Container(
      width: 80,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialistCard(BuildContext context, Specialist specialist) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300], // Color de fondo temporal
              ),
              child: Icon(Icons.person, color: Colors.grey[600]),
            ),
            SizedBox(width: 16),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    specialist.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    specialist.specialty,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text(
                        specialist.rating.toString(),
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${specialist.distance} km • ${specialist.experience} años exp.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Acciones
            Column(
              children: [
                FilledButton(
                  onPressed: () => _contactSpecialist(context, specialist),
                  child: Text('Contactar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    minimumSize: Size(100, 36),
                  ),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () => _viewProfile(context, specialist),
                  child: Text('Ver perfil'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _contactSpecialist(BuildContext context, Specialist specialist) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contactar a ${specialist.name}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildContactOption(
              Icons.phone,
              'Llamar',
              specialist.phone,
                  () => _makeCall(specialist.phone),
            ),
            _buildContactOption(
              Icons.email,
              'Email',
              specialist.email,
                  () => _sendEmail(specialist.email),
            ),
            _buildContactOption(
              Icons.video_call,
              'Videoconsulta',
              'Consulta online',
                  () => _startVideoCall(specialist),
            ),
            _buildContactOption(
              Icons.calendar_today,
              'Agendar cita',
              'Presencial o virtual',
                  () => _scheduleAppointment(context, specialist),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.amber),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  void _viewProfile(BuildContext context, Specialist specialist) {
   //pantalla no existe
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Perfil de ${specialist.name}'),
        content: Text('Especialidad: ${specialist.specialty}\n\nExperiencia: ${specialist.experience} años\n\nRating: ${specialist.rating}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );

    // Cuando crees la pantalla de perfil, puedes usar:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => SpecialistProfileScreen(specialist: specialist),
    //   ),
    // );
  }

  void _makeCall(String phone) {
    // Implementar llamada telefónica
    print('Llamando a: $phone');
  }

  void _sendEmail(String email) {
    // Implementar envío de email
    print('Enviando email a: $email');
  }

  void _startVideoCall(Specialist specialist) {
    // Implementar videollamada
    print('Iniciando videoconsulta con: ${specialist.name}');
  }

  void _scheduleAppointment(BuildContext context, Specialist specialist) {
    // Implementar agendamiento
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agendar cita'),
        content: Text('¿Desea agendar una cita con ${specialist.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí iría la lógica para agendar la cita
            },
            child: Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  List<Specialist> _getSpecialists() {
    return [
      Specialist(
        id: '1',
        name: 'Dr. Carlos Rodríguez',
        specialty: 'Dermatólogo',
        photoUrl: 'assets/images/doctor1.jpg',
        rating: 4.8,
        reviewCount: 124,
        experience: 15,
        distance: 2.5,
        phone: '+1 234 567 8901',
        email: 'c.rodriguez@clinica.com',
      ),
      Specialist(
        id: '2',
        name: 'Dra. María González',
        specialty: 'Dermatóloga',
        photoUrl: 'assets/images/doctor2.jpg',
        rating: 4.9,
        reviewCount: 89,
        experience: 12,
        distance: 3.2,
        phone: '+1 234 567 8902',
        email: 'm.gonzalez@hospital.com',
      ),
    ];
  }
}