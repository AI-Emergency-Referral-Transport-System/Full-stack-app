import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hospital_provider.dart';
import '../../models/user_model.dart';
import '../../models/hospital_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bedController = TextEditingController();
  final _icuController = TextEditingController();
  String _selectedBloodType = 'O+';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
      _addressController.text = user.address ?? '';
      _bedController.text = user.bedCount?.toString() ?? '0';
      _icuController.text = user.icuCount?.toString() ?? '0';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user?.role != UserRole.hospital || !mounted) return;
      final hp = Provider.of<HospitalProvider>(context, listen: false);
      await hp.fetchMyHospitalProfile();
      if (!mounted) return;
      final h = hp.myHospitalProfile;
      if (h != null) {
        setState(() {
          _nameController.text = h.name;
          _addressController.text = h.address;
          _phoneController.text = h.phoneNumber;
          _bedController.text = h.bedCount.toString();
          _icuController.text = h.icuCount.toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit, color: const Color(0xFFC62828)),
            onPressed: () async {
              setState(() {
                _isEditing = !_isEditing;
              });
              if (!_isEditing) {
                final hp = Provider.of<HospitalProvider>(context, listen: false);
                if (user!.role == UserRole.hospital) {
                  final base = hp.myHospitalProfile;
                  if (base != null) {
                    await hp.updateHospital(
                      HospitalModel(
                        id: base.id,
                        name: _nameController.text.trim(),
                        address: _addressController.text.trim(),
                        location: base.location,
                        phoneNumber: _phoneController.text.trim(),
                        bedCount: int.tryParse(_bedController.text.trim()) ?? base.bedCount,
                        icuCount: int.tryParse(_icuController.text.trim()) ?? base.icuCount,
                      ),
                    );
                    if (!context.mounted) return;
                  }
                }

                final updatedUser = UserModel(
                  id: user.id,
                  name: user.role == UserRole.hospital
                      ? _nameController.text.trim()
                      : _nameController.text,
                  email: _emailController.text,
                  phoneNumber: _phoneController.text,
                  role: user.role,
                  address: user.role == UserRole.hospital ? _addressController.text.trim() : user.address,
                  bedCount:
                      user.role == UserRole.hospital ? int.tryParse(_bedController.text.trim()) : user.bedCount,
                  icuCount:
                      user.role == UserRole.hospital ? int.tryParse(_icuController.text.trim()) : user.icuCount,
                );

                await Provider.of<AuthProvider>(context, listen: false).updateProfile(updatedUser);
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      child: Icon(Icons.person, size: 60),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildEditableField('FULL NAME', _nameController, Icons.person_outline),
              const SizedBox(height: 20),
              _buildEditableField('EMAIL ADDRESS', _emailController, Icons.email_outlined),
              const SizedBox(height: 20),
              _buildEditableField('PHONE NUMBER', _phoneController, Icons.phone_outlined),
              if (user?.role == UserRole.hospital) ...[
                const SizedBox(height: 20),
                _buildEditableField('HOSPITAL ADDRESS', _addressController, Icons.location_on_outlined),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildEditableField('TOTAL BEDS', _bedController, Icons.bed_outlined)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildEditableField('ICU ROOMS', _icuController, Icons.meeting_room_outlined)),
                  ],
                ),
              ],
              if (user?.role == UserRole.patient) ...[
                const SizedBox(height: 20),
                _buildBloodTypeSection(),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  auth.logout();
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFC62828),
                  side: const BorderSide(color: Color(0xFFC62828)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('LOG OUT'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: _isEditing,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFC62828)),
            filled: !_isEditing,
            fillColor: _isEditing ? Colors.white : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: _isEditing ? const BorderSide(color: Color(0xFFC62828)) : BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBloodTypeSection() {
    final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BLOOD TYPE',
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: bloodTypes.map((type) {
            final isSelected = _selectedBloodType == type;
            return GestureDetector(
              onTap: _isEditing ? () => setState(() => _selectedBloodType = type) : null,
              child: Container(
                width: 60,
                height: 40,
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
          }).toList(),
        ),
      ],
    );
  }
}
