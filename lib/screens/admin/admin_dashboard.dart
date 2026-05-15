import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hospital_provider.dart';
import '../../models/hospital_model.dart';
import 'hospital_registration.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HospitalProvider>(context, listen: false).fetchHospitals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final hospitalProvider = Provider.of<HospitalProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () {
              auth.logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'System Overview',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      'Register Hospital',
                      Icons.local_hospital_outlined,
                      const Color(0xFFC62828),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HospitalRegistration())),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(
                      'System Reports',
                      Icons.analytics_outlined,
                      Colors.blue,
                      () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Registered Hospitals',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            hospitalProvider.hospitals.isEmpty
                ? const Center(child: Text('No hospitals registered yet'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: hospitalProvider.hospitals.length,
                    itemBuilder: (context, index) {
                      final hosp = hospitalProvider.hospitals[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFC62828).withValues(alpha: 0.1),
                            child: const Icon(Icons.local_hospital, color: Color(0xFFC62828)),
                          ),
                          title: Text(hosp.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(hosp.address, style: GoogleFonts.poppins(fontSize: 10)),
                              Text(
                                'Loc: ${hosp.location.latitude.toStringAsFixed(2)}, ${hosp.location.longitude.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => HospitalRegistration(hospital: hosp)),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Color(0xFFC62828), size: 20),
                                onPressed: () => _showDeleteDialog(context, hospitalProvider, hosp),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, HospitalProvider provider, HospitalModel hospital) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Hospital', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete ${hospital.name}?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              provider.adminDeleteHospital(hospital.id);
              Navigator.pop(ctx);
            },
            child: Text('DELETE', style: GoogleFonts.poppins(color: const Color(0xFFC62828))),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
