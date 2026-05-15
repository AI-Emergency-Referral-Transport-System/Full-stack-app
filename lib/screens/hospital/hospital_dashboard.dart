import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../providers/hospital_provider.dart';
import '../../models/emergency_request_model.dart';
import '../../models/driver_model.dart';
import '../patient/profile_page.dart';
import 'driver_management.dart';
import 'driver_assignment_screen.dart';

class HospitalDashboard extends StatefulWidget {
  const HospitalDashboard({super.key});

  @override
  State<HospitalDashboard> createState() => _HospitalDashboardState();
}

class _HospitalDashboardState extends State<HospitalDashboard> {
  final Set<String> _accepting = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user == null) return;
      final hp = Provider.of<HospitalProvider>(context, listen: false);
      final rp = Provider.of<RequestProvider>(context, listen: false);
      await hp.fetchMyHospitalProfile();
      if (!mounted) return;
      await hp.fetchDrivers(auth.user!.id);
      if (!mounted) return;
      await rp.fetchHospitalRequests();
    });
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final requestProvider = Provider.of<RequestProvider>(context);
    final hospitalProvider = Provider.of<HospitalProvider>(context);

    if (auth.user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final pendingRequests = requestProvider.requests.where((r) => r.status == RequestStatus.pending).toList();

    final hospitalPk = hospitalProvider.myHospitalProfile?.id;
    final activeCases = requestProvider.requests.where((r) {
      final assigned = r.assignedHospitalId;
      if (hospitalPk == null || assigned == null) return false;
      final match = assigned == hospitalPk;
      return match && (r.status == RequestStatus.accepted || r.status == RequestStatus.completed);
    }).length;
    
    final availableDrivers = hospitalProvider.drivers.where((d) => 
      d.status == DriverStatus.available).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Hospital Dashboard',
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: () {
              hospitalProvider.fetchMyHospitalProfile();
              requestProvider.fetchHospitalRequests();
              hospitalProvider.fetchDrivers(auth.user!.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () {
              auth.logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await hospitalProvider.fetchMyHospitalProfile();
          await requestProvider.fetchHospitalRequests();
          await hospitalProvider.fetchDrivers(auth.user!.id);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Section
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard('Active Cases', activeCases.toString(), Icons.emergency_outlined, Colors.orange),
                    _buildStatCard('Available Amb', availableDrivers.toString(), Icons.medical_services_outlined, Colors.green),
                    _buildStatCard(
                      'Total Beds',
                      '${hospitalProvider.myHospitalProfile?.bedCount ?? 0}',
                      Icons.bed_outlined,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'ICU Rooms',
                      '${hospitalProvider.myHospitalProfile?.icuCount ?? 0}',
                      Icons.meeting_room_outlined,
                      Colors.purple,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Incoming Requests',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              pendingRequests.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No pending requests',
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pendingRequests.length,
                      itemBuilder: (context, index) {
                        final req = pendingRequests[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                spreadRadius: 0,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC62828).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.emergency, color: Color(0xFFC62828)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          req.emergencyType ?? 'General',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'Patient ID: ${req.patientId.length > 8 ? req.patientId.substring(0, 8) : req.patientId}',
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'JUST NOW',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: const Color(0xFFC62828),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await requestProvider.updateRequestStatus(
                                          req.id,
                                          RequestStatus.rejected,
                                        );
                                        await requestProvider.fetchHospitalRequests();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade700,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 0,
                                      ),
                                      child: const Text('DECLINE'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_accepting.contains(req.id)) return;
                                        final hospitalProvider = Provider.of<HospitalProvider>(context, listen: false);
                                        final hasAvailable = hospitalProvider.drivers.any((d) => d.status == DriverStatus.available);
                                        if (!hasAvailable) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('No available drivers. Add/enable a driver first.'),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                          return;
                                        }

                                        setState(() => _accepting.add(req.id));
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(builder: (_) => DriverAssignmentScreen(requestId: req.id)))
                                            .then((_) async {
                                              await requestProvider.fetchHospitalRequests();
                                              if (mounted) setState(() => _accepting.remove(req.id));
                                            });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            _accepting.contains(req.id) ? Colors.grey : Colors.green.shade700,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 0,
                                      ),
                                      child: const Text('ACCEPT'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFFC62828),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
             Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DriverManagement()),
              );
          } else if (index == 2) {
            Navigator.of(context)
                .push(
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            )
                .then((_) {
              if (!context.mounted) return;
              Provider.of<HospitalProvider>(context, listen: false).fetchMyHospitalProfile();
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'DASHBOARD'),
          BottomNavigationBarItem(icon: Icon(Icons.person_add_outlined), label: 'REGISTER DRIVER'),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital_outlined), label: 'PROFILE'),
        ],
      ),
    );
  }
}
