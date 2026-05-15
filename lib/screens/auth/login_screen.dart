import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.patient;

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
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Critical Response Portal',
                style: GoogleFonts.poppins(
                  color: Colors.blueGrey,
                  fontSize: 12,
                ),
              ),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Login',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your credentials to access your secure dashboard.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.brown[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildInputField(
                      label: 'Email Address',
                      controller: _emailController,
                      hint: 'name@medical-org.com',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      label: 'Password',
                      controller: _passwordController,
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      trailing: GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFC62828),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildRoleDropdown(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: false,
                          onChanged: (v) {},
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Remember this device for 30 days',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    auth.isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              final success = await auth.login(
                                _emailController.text, 
                                _passwordController.text,
                                _selectedRole,
                              );
                              
                              if (context.mounted) {
                                if (success) {
                                  Navigator.pushReplacementNamed(context, '/home');
                                } else if (auth.errorMessage != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(auth.errorMessage!),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('LOGIN', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                const Icon(Icons.login_outlined, size: 18),
                              ],
                            ),
                          ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('New to Derash? ', style: GoogleFonts.poppins(color: Colors.black54)),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/register'),
                          child: Text(
                            'Create an Account',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFC62828),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSocialIcon('assets/icons/google.png'), // Replace with real icons
                        _buildSocialIcon('assets/icons/apple.png'),
                        _buildSocialIcon('assets/icons/windows.png'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFooterLink('Privacy Policy'),
                  _buildFooterLink('Terms of Service'),
                  _buildFooterLink('Trust Center'),
                ],
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
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: isPassword ? const Icon(Icons.visibility_outlined, size: 20) : null,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCOUNT ROLE',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<UserRole>(
              value: _selectedRole,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              onChanged: (UserRole? newValue) {
                if (newValue != null) setState(() => _selectedRole = newValue);
              },
              items: UserRole.values.map<DropdownMenuItem<UserRole>>((UserRole value) {
                return DropdownMenuItem<UserRole>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(_getRoleIcon(value), size: 20, color: Colors.black54),
                      const SizedBox(width: 12),
                      Text(
                        value.toString().split('.').last[0].toUpperCase() + 
                        value.toString().split('.').last.substring(1),
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.patient: return Icons.person_pin_outlined;
      case UserRole.hospital: return Icons.local_hospital_outlined;
      case UserRole.admin: return Icons.admin_panel_settings_outlined;
      case UserRole.driver: return Icons.drive_eta_outlined;
    }
  }

  Widget _buildSocialIcon(String path) {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.shade50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(Icons.apps, color: Colors.blue.shade900), // Placeholder
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.blueGrey.shade400,
        fontSize: 12,
      ),
    );
  }
}

