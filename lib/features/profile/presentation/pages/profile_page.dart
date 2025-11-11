import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Página de perfil del usuario
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state.user;

            if (user == null) {
              return const Center(child: Text('No user data'));
            }

            return Column(
              children: [
                // Header
                _buildHeader(context),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Avatar y nombre
                        _buildProfileHeader(user.firstName, user.lastName),

                        const SizedBox(height: 24),

                        // Información
                        _buildInfoSection(user.email, user.phoneNumber),

                        const SizedBox(height: 24),

                        // Botón Edit Profile
                        _buildEditButton(context),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF5B7C99),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(String firstName, String lastName) {
    return Column(
      children: [
        // Avatar
        const CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 55,
            backgroundColor: Color(0xFFD1D5DB),
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
        ),

        const SizedBox(height: 16),

        // Nombre
        Text(
          '$firstName $lastName',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B2D42),
          ),
        ),

        const SizedBox(height: 4),

        // Rol
        const Text(
          'Owner',
          style: TextStyle(fontSize: 16, color: Color(0xFF8D99AE)),
        ),

        const SizedBox(height: 8),

        // Rating
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '4.9',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B2D42),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.star, size: 20, color: Colors.amber),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoSection(String email, String phoneNumber) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.email, 'Email', email),
          const Divider(height: 32),
          _buildInfoRow(Icons.phone, 'Phone Number', phoneNumber),
          const Divider(height: 32),
          _buildWorkshopsSection(),
          const Divider(height: 32),
          _buildNotificationsSection(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2B2D42)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF8D99AE)),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2B2D42),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkshopsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.build, color: Color(0xFF2B2D42)),
            const SizedBox(width: 12),
            const Text(
              'Favorite Workshops',
              style: TextStyle(fontSize: 12, color: Color(0xFF8D99AE)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildWorkshopItem('Iker Motors'),
        const SizedBox(height: 8),
        _buildWorkshopItem('Autoking Workshop'),
      ],
    );
  }

  Widget _buildWorkshopItem(String name) {
    return Padding(
      padding: const EdgeInsets.only(left: 36),
      child: Row(
        children: [
          const Icon(Icons.garage, size: 20, color: Color(0xFF5B7C99)),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 14, color: Color(0xFF2B2D42)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notifications',
          style: TextStyle(fontSize: 12, color: Color(0xFF8D99AE)),
        ),
        const SizedBox(height: 12),
        _buildNotificationToggle(Icons.message, 'Message notifications', true),
        const SizedBox(height: 8),
        _buildNotificationToggle(
          Icons.local_offer,
          'Offers notifications',
          true,
        ),
      ],
    );
  }

  Widget _buildNotificationToggle(IconData icon, String label, bool value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2B2D42)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF2B2D42)),
          ),
        ),
        Switch(
          value: value,
          onChanged: (val) {
            // TODO: Implementar cambio de notificaciones
          },
          activeColor: const Color(0xFF2B3E50),
        ),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          AppRouter.toEditProfile(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2B3E50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Edit Profile',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
