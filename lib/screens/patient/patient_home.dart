import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../services/api_service.dart';
import 'emergency_tracking.dart';
import 'profile_page.dart';
import 'hospital_selection_screen.dart';

class PatientHome extends StatefulWidget {
  const PatientHome({super.key});

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RequestProvider>(context, listen: false).fetchRequests();
    });
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('About Derash', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'Derash connects patients, hospitals, and ambulances to speed up emergency response.\n\n'
          'This app helps you send an emergency request, choose a nearby hospital, and track the ambulance in real time.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showHowToDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('How to use', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          '1) Create an account and set your home location.\n'
          '2) Tap “TRIGGER EMERGENCY” and select the emergency type.\n'
          '3) Choose the nearest hospital.\n'
          '4) Track the ambulance on the map until it arrives.\n\n'
          'Tip: If your home location is not set, please re-register or add it later (coming soon).',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userName = auth.user?.name ?? 'User';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DERASH',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            Text(
              'Welcome, $userName',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                  return;
                case 'about':
                  _showAboutDialog();
                  return;
                case 'howto':
                  _showHowToDialog();
                  return;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Text('Profile')),
              const PopupMenuItem(value: 'about', child: Text('About us')),
              const PopupMenuItem(value: 'howto', child: Text('How to use')),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Consumer<RequestProvider>(
              builder: (context, requestProvider, _) {
                final activeRequest = requestProvider.activeRequest;
                if (activeRequest == null) return const SizedBox.shrink();
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emergency_share, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Emergency Request',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              'Status: ${activeRequest.status.toString().split('.').last.toUpperCase()}',
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange.shade900),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EmergencyTracking(
                                requestId: Provider.of<RequestProvider>(context, listen: false).activeRequest?.id,
                              ),
                            ),
                          );
                        },
                        child: const Text('TRACK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Quick Emergency Trigger
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Emergency Assistance',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFC62828),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC62828).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.emergency, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Need Immediate Help?',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button below to alert the nearest hospitals and dispatch an ambulance.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const EmergencyTypeSheet(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFC62828),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.flash_on, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'TRIGGER EMERGENCY',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Recent Status / Dashboard Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Your Health Status',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDashboardItem(
              icon: Icons.history,
              title: 'Recent Requests',
              subtitle: 'You have no active or past requests.',
              color: Colors.blue,
            ),
            _buildDashboardItem(
              icon: Icons.health_and_safety,
              title: 'Medical Profile',
              subtitle: 'Blood Type: O+, Allergic to Penicillin',
              color: Colors.green,
            ),
            _buildDashboardItem(
              icon: Icons.location_on,
              title: 'Saved Locations',
              subtitle: 'Home, Office, Parents\' House',
              color: Colors.orange,
            ),
            const SizedBox(height: 32),
          ],
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'PROFILE'),
        ],
      ),
    );
  }

  Widget _buildDashboardItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

class EmergencyTypeSheet extends StatelessWidget {
  const EmergencyTypeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final emergencyTypes = [
      {'icon': Icons.favorite, 'label': 'Cardiac'},
      {'icon': Icons.car_crash, 'label': 'Accident'},
      {'icon': Icons.air, 'label': 'Respiratory'},
      {'icon': Icons.local_fire_department, 'label': 'Burn'},
      {'icon': Icons.child_care, 'label': 'Pediatric'},
      {'icon': Icons.psychology, 'label': 'Neurological'},
      {'icon': Icons.healing, 'label': 'Trauma'},
      {'icon': Icons.more_horiz, 'label': 'Other'},
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Select Emergency Type',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps hospitals prepare for your arrival',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: emergencyTypes.length,
              itemBuilder: (context, index) {
                final type = emergencyTypes[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close sheet
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _HomeLocationGate(
                          emergencyType: type['label'] as String,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(type['icon'] as IconData, 
                             color: const Color(0xFFC62828), size: 32),
                        const SizedBox(height: 8),
                        Text(
                          type['label'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeLocationGate extends StatefulWidget {
  final String emergencyType;
  const _HomeLocationGate({required this.emergencyType});

  @override
  State<_HomeLocationGate> createState() => _HomeLocationGateState();
}

class _HomeLocationGateState extends State<_HomeLocationGate> {
  final _api = ApiService();
  bool _loading = true;
  LatLng? _home;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loc = await _api.getPatientHomeLocation();
    if (!mounted) return;
    setState(() {
      _home = loc == null ? null : LatLng(loc.lat, loc.lng);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_home == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Home location missing')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Your home location is not set. Please create an account again and select your home location on the map.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(),
            ),
          ),
        ),
      );
    }

    return HospitalSelectionScreen(
      emergencyType: widget.emergencyType,
      patientLocation: _home!,
    );
  }
}
