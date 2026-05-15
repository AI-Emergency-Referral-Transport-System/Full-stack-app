import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/hospital_provider.dart';
import '../../providers/request_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/hospital_model.dart';
import 'emergency_tracking.dart';

class HospitalSelectionScreen extends StatefulWidget {
  final String emergencyType;
  final LatLng patientLocation;

  const HospitalSelectionScreen({
    super.key,
    required this.emergencyType,
    required this.patientLocation,
  });

  @override
  State<HospitalSelectionScreen> createState() => _HospitalSelectionScreenState();
}

class _HospitalSelectionScreenState extends State<HospitalSelectionScreen> {
  final Distance _distance = const Distance();

  double _displayDistanceKm(HospitalModel hospital) {
    if (hospital.distanceMeters != null && hospital.distanceMeters! > 0) {
      return hospital.distanceKm;
    }
    return _distance.as(LengthUnit.Kilometer, widget.patientLocation, hospital.location);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HospitalProvider>(context, listen: false).fetchNearbyHospitalsForPatient(
        widget.patientLocation.latitude,
        widget.patientLocation.longitude,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final hospitalProvider = Provider.of<HospitalProvider>(context);
    final requestProvider = Provider.of<RequestProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Backend returns hospitals sorted nearest → farthest.
    final sortedHospitals = List<HospitalModel>.from(hospitalProvider.hospitals);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Select Nearest Hospital',
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFC62828).withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.emergency, color: Color(0xFFC62828)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Emergency: ${widget.emergencyType}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFC62828),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: hospitalProvider.isLoading && sortedHospitals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Color(0xFFC62828)),
                        const SizedBox(height: 16),
                        Text('Loading registered hospitals…', style: GoogleFonts.poppins()),
                      ],
                    ),
                  )
                : sortedHospitals.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_hospital_outlined, size: 72, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'No hospitals registered yet.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ask an administrator to add hospitals.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: sortedHospitals.length,
                        itemBuilder: (context, index) {
                          final hospital = sortedHospitals[index];
                          final dist = _displayDistanceKm(hospital);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFC62828).withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.local_hospital, color: Color(0xFFC62828)),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            hospital.name,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            hospital.address.isEmpty ? '—' : hospital.address,
                                            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                                          ),
                                          Text(
                                            'Beds: ${hospital.bedCount} • ICU: ${hospital.icuCount}',
                                            style: GoogleFonts.poppins(color: Colors.black54, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${dist.toStringAsFixed(1)} km',
                                        style: GoogleFonts.poppins(
                                          color: Colors.green.shade800,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: requestProvider.isLoading
                                      ? null
                                      : () async {
                                          await requestProvider.createRequest(
                                            authProvider.user!.id,
                                            widget.patientLocation,
                                            widget.emergencyType,
                                            targetHospitalId: hospital.id,
                                          );
                                          if (!context.mounted) return;
                                          final requestId = requestProvider.activeRequest?.id;
                                          if (requestId != null) {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => EmergencyTracking(requestId: requestId),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Could not create request. Check connection.'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFC62828),
                                    minimumSize: const Size(double.infinity, 48),
                                  ),
                                  child: Text(
                                    requestProvider.isLoading ? 'SENDING…' : 'SEND REQUEST',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.grey,
                                    side: const BorderSide(color: Colors.grey),
                                    minimumSize: const Size(double.infinity, 48),
                                  ),
                                  child: const Text('CANCEL'),
                                ),
                              ],
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
