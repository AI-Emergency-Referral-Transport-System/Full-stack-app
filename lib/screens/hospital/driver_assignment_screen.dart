import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/hospital_provider.dart';
import '../../providers/request_provider.dart';
import '../../models/emergency_request_model.dart';
import '../../models/driver_model.dart';

class DriverAssignmentScreen extends StatefulWidget {
  final String requestId;

  const DriverAssignmentScreen({super.key, required this.requestId});

  @override
  State<DriverAssignmentScreen> createState() => _DriverAssignmentScreenState();
}

class _DriverAssignmentScreenState extends State<DriverAssignmentScreen> {
  @override
  Widget build(BuildContext context) {
    final hospitalProvider = Provider.of<HospitalProvider>(context);
    final requestProvider = Provider.of<RequestProvider>(context);
    
    final availableDrivers = hospitalProvider.drivers.where((d) => d.status == DriverStatus.available).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Assign Driver',
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: availableDrivers.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 80, color: Colors.red[300]),
                    const SizedBox(height: 24),
                    Text(
                      'No Available Drivers!',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You must have an available driver to accept this request.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        requestProvider.updateRequestStatus(widget.requestId, RequestStatus.failed);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Mark Request as Failed'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: availableDrivers.length,
              itemBuilder: (context, index) {
                final driver = availableDrivers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFFF5F6FA),
                        child: Icon(Icons.person, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driver.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Phone: ${driver.phoneNumber}',
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                         onPressed: () {},
                         icon: const Icon(Icons.phone, color: Color(0xFFC62828)),
                         style: IconButton.styleFrom(
                           backgroundColor: const Color(0xFFC62828).withValues(alpha: 0.1),
                         ),
                       ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          requestProvider.updateRequestStatus(
                            widget.requestId,
                            RequestStatus.accepted,
                            driverId: driver.id,
                          );
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(80, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('Assign'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
