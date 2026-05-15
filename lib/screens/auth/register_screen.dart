import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedBloodType = 'O+';
  LatLng? _homeLocation;
  final _api = ApiService();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            const Icon(Icons.local_hospital, color: Color(0xFFC62828), size: 24),
            const SizedBox(width: 8),
            Text(
              'DERASH',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://i.pravatar.cc/100'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade100.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Join Derash',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your account to access critical response services.',
                      style: GoogleFonts.poppins(
                        color: Colors.brown[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildInputField(
                      label: 'FULL NAME',
                      controller: _nameController,
                      hint: 'Johnathan Doe',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      label: 'EMAIL ADDRESS',
                      controller: _emailController,
                      hint: 'john@derash.com',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      label: 'PHONE NUMBER',
                      controller: _phoneController,
                      hint: '+1 (555) 000-0000',
                      icon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      label: 'PASSWORD',
                      controller: _passwordController,
                      hint: '••••••••••••',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 24),
                    _buildBloodTypeSelection(),
                    const SizedBox(height: 20),
                    _buildHomeLocationPicker(),
                    const SizedBox(height: 32),
                    auth.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () async {
                              if (_homeLocation == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select your home location on the map.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              final success = await auth.register(
                                _nameController.text,
                                _emailController.text,
                                _passwordController.text,
                                _phoneController.text,
                                UserRole.patient,
                              );
                              
                              if (!context.mounted) return;
                              if (success) {
                                await _api.savePatientHomeLocation(
                                  lat: _homeLocation!.latitude,
                                  lng: _homeLocation!.longitude,
                                );
                                if (!context.mounted) return;
                                Navigator.pushReplacementNamed(context, '/home');
                              } else if (auth.errorMessage != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(auth.errorMessage!),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.person_add_outlined, size: 20),
                                const SizedBox(width: 8),
                                Text('SIGN UP', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                    const SizedBox(height: 24),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ', style: GoogleFonts.poppins(color: Colors.black54)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              'LOGIN',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFC62828),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.circle, size: 10, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              'PROTOCOL ACTIVE',
                              style: GoogleFonts.poppins(
                                color: Colors.green.shade700,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: isPassword ? const Icon(Icons.visibility_outlined, size: 20) : null,
            fillColor: Colors.grey[100],
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBloodTypeSelection() {
    final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BLOOD TYPE (IF PATIENT)',
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.5,
          ),
          itemCount: bloodTypes.length,
          itemBuilder: (context, index) {
            final type = bloodTypes[index];
            final isSelected = _selectedBloodType == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedBloodType = type),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red.shade100 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFC62828) : Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: Text(
                    type,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFFC62828) : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHomeLocationPicker() {
    final selected = _homeLocation ?? const LatLng(9.03, 38.74);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HOME LOCATION',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _homeLocation == null
              ? 'Tap on the map to set your home location.'
              : 'Lat: ${selected.latitude.toStringAsFixed(5)}, Lng: ${selected.longitude.toStringAsFixed(5)}',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: selected,
                initialZoom: 13.5,
                onTap: (tapPosition, point) {
                  setState(() => _homeLocation = point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.derash.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selected,
                      width: 46,
                      height: 46,
                      child: const Icon(Icons.home, color: Colors.blue, size: 46),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

