import 'package:flutter/material.dart';
import 'package:qhaliqara_app/data/notifiers.dart';
import 'package:qhaliqara_app/views/screens/welcome_screen.dart';

import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildProfileHeader(),

            // Opciones
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  _buildProfileSection(),
                  SizedBox(height: 24),
                  _buildSettingsSection(),
                  SizedBox(height: 24),
                  _buildSupportSection(),
                  SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.icon(
                  onPressed: () {
                    selectedScreenNotifier.value = 0;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) {
                            return WelcomeScreen();
                          }
                      ),
                    );
                  },
                  icon: Icon(Icons.logout, size: 20),
                  label: Text('CERRAR SESIÓN'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber, width: 3),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/profile_placeholder.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.amber[100],
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.amber,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 16),

          // Nombre
          Text(
            'Sebas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),

          // Email
          Text(
            'sebas@gmail.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),

          // Botón editar
          OutlinedButton.icon(
            onPressed: () {
              // Editar perfil
            },
            icon: Icon(Icons.edit, size: 16),
            label: Text('Editar perfil'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.amber,
              side: BorderSide(color: Colors.amber),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información personal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            _buildInfoItem(Icons.person, 'Nombre completo', 'Sebas'),
            _buildInfoItem(Icons.phone, 'Teléfono', '--- --- ---'),
            _buildInfoItem(Icons.cake, 'Fecha de nacimiento', '-- --- --'),
            _buildInfoItem(Icons.transgender, 'Género', '---'),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            _buildSettingItem(
              Icons.notifications,
              'Notificaciones',
              'Gestionar alertas',
              Icons.arrow_forward_ios,
                  () {},
            ),
            _buildSettingItem(
              Icons.security,
              'Privacidad',
              'Controla tu información',
              Icons.arrow_forward_ios,
                  () {},
            ),
            _buildSettingItem(
              Icons.language,
              'Idioma',
              'Español',
              Icons.arrow_forward_ios,
                  () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soporte',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            _buildSettingItem(
              Icons.help,
              'Centro de ayuda',
              'Preguntas frecuentes',
              Icons.arrow_forward_ios,
                  () {},
            ),
            _buildSettingItem(
              Icons.contact_support,
              'Contactar soporte',
              'Estamos aquí para ayudarte',
              Icons.arrow_forward_ios,
                  () {},
            ),
            _buildSettingItem(
              Icons.description,
              'Términos y condiciones',
              'Lee nuestros términos',
              Icons.arrow_forward_ios,
                  () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
      IconData icon,
      String title,
      String subtitle,
      IconData trailingIcon,
      VoidCallback onTap,
      ) {
    return ListTile(
      leading: Icon(icon, color: Colors.amber),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(trailingIcon, size: 16, color: Colors.grey),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar sesión'),
        content: Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Navegar al login
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
