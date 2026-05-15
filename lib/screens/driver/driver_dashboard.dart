import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../models/emergency_request_model.dart';
import '../patient/profile_page.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  LatLng _driverPos = const LatLng(9.04, 38.75);
  LatLng _patientPos = const LatLng(9.03, 38.74);
  Timer? _simulationTimer;
  final String _driverLabel = 'Abebe Kebede • +251 911 223 344';
  final MapController _mapController = MapController();
  bool _followDriver = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    final requestProvider = Provider.of<RequestProvider>(context, listen: false);
    requestProvider.fetchRequests().then((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      // Find request assigned to this driver
      try {
        final assignedRequest = requestProvider.requests.firstWhere(
          (r) => r.assignedDriverId == auth.user?.id && r.status == RequestStatus.accepted,
        );
        requestProvider.setActiveRequest(assignedRequest);
        setState(() {
          _patientPos = assignedRequest.patientLocation;
          // Set driver starting position slightly offset from patient for simulation
          _driverPos = LatLng(_patientPos.latitude + 0.01, _patientPos.longitude + 0.01);
        });
        _startSimulation();
      } catch (e) {
        debugPrint('No active assignment found for driver');
      }
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      setState(() {
        double newLat = _driverPos.latitude - 0.0002;
        double newLng = _driverPos.longitude - 0.0002;
        if (newLat <= _patientPos.latitude) {
          _driverPos = _patientPos;
          timer.cancel();
        } else {
          _driverPos = LatLng(newLat, newLng);
        }
      });
      if (_followDriver) {
        _mapController.move(_driverPos, _mapController.camera.zoom);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final requestProvider = Provider.of<RequestProvider>(context);
    final activeRequest = requestProvider.activeRequest;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Driver Dashboard', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: () => _initializeData(),
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
      body: activeRequest == null 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('No active assignment', style: GoogleFonts.poppins(color: Colors.grey)),
              ],
            ),
          )
        : Column(
            children: [
              Expanded(
                flex: 3,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _patientPos,
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.derash.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _patientPos,
                          width: 40,
                          height: 40,
                          child: const Tooltip(
                            message: 'Patient Home',
                            child: Icon(Icons.home, color: Colors.blue, size: 40),
                          ),
                        ),
                        Marker(
                          point: _driverPos,
                          width: 40,
                          height: 40,
                          child: Tooltip(
                            message: _driverLabel,
                            child: const Icon(Icons.location_on, color: Color(0xFFC62828), size: 40),
                          ),
                        ),
                      ],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [_driverPos, _patientPos],
                          color: const Color(0xFFC62828),
                          strokeWidth: 4.0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Active Assignment', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                              child: Text('ON ROUTE', style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(Icons.person_outline, 'Patient ID', activeRequest.patientId),
                        _buildInfoRow(Icons.location_on_outlined, 'Status', activeRequest.status.toString().split('.').last.toUpperCase()),
                        _buildInfoRow(Icons.emergency_outlined, 'Emergency', activeRequest.emergencyType ?? 'General'),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            await requestProvider.updateRequestStatus(
                              activeRequest.id, 
                              RequestStatus.completed,
                            );
                            requestProvider.setActiveRequest(null);
                            _simulationTimer?.cancel();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC62828),
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('MARK AS COMPLETED'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFFC62828),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.navigation_outlined), label: 'NAVIGATE'),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: 'HISTORY'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'PROFILE'),
        ],
      ),
      floatingActionButton: activeRequest == null
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFC62828),
              onPressed: () {
                setState(() => _followDriver = !_followDriver);
                if (_followDriver) {
                  _mapController.move(_driverPos, _mapController.camera.zoom);
                }
              },
              child: Icon(_followDriver ? Icons.gps_fixed : Icons.gps_not_fixed),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFC62828)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
              Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
