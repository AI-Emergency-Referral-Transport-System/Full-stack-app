import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hospital_provider.dart';

class DriverManagement extends StatefulWidget {
  const DriverManagement({super.key});

  @override
  State<DriverManagement> createState() => _DriverManagementState();
}

class _DriverManagementState extends State<DriverManagement> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<HospitalProvider>(context, listen: false).fetchDrivers(auth.user!.id);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hospitalProvider = Provider.of<HospitalProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Register New Driver',
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Driver Details',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Use the driver’s email and password on the login page with Account Role set to Driver.',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            _buildDriverField('Full Name', Icons.person_outline, _nameController),
            const SizedBox(height: 16),
            _buildDriverField('Email Address', Icons.email_outlined, _emailController,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildDriverField('Phone Number', Icons.phone_outlined, _phoneController,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildDriverField('Password', Icons.lock_outline, _passwordController, isPassword: true),
            const SizedBox(height: 32),
            hospitalProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async {
                      final name = _nameController.text.trim();
                      final email = _emailController.text.trim();
                      final phone = _phoneController.text.trim();
                      final password = _passwordController.text;

                      if (name.isEmpty || email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Name, email, and password are required.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final err = await hospitalProvider.registerDriver(
                        name: name,
                        email: email,
                        password: password,
                        phone: phone,
                      );

                      if (!context.mounted) return;

                      if (err != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(err), backgroundColor: Colors.red),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Driver registered. They can log in with this email and password.',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.green.shade700,
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: Text('REGISTER DRIVER', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
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
          obscureText: isPassword,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFC62828)),
            hintText: 'Enter $label',
          ),
        ),
      ],
    );
  }
}
