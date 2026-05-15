import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/hospital_provider.dart';
import '../../models/hospital_model.dart';

class HospitalRegistration extends StatefulWidget {
  final HospitalModel? hospital;
  const HospitalRegistration({super.key, this.hospital});

  @override
  State<HospitalRegistration> createState() => _HospitalRegistrationState();
}

class _HospitalRegistrationState extends State<HospitalRegistration> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _capacityController = TextEditingController();
  final _bedCountController = TextEditingController();
  final _icuCountController = TextEditingController();
  LatLng _selectedLocation = const LatLng(9.03, 38.74);

  @override
  void initState() {
    super.initState();
    if (widget.hospital != null) {
      _nameController.text = widget.hospital!.name;
      _addressController.text = widget.hospital!.address;
      _phoneController.text = widget.hospital!.phoneNumber;
      _bedCountController.text = widget.hospital!.bedCount.toString();
      _icuCountController.text = widget.hospital!.icuCount.toString();
      _selectedLocation = widget.hospital!.location;
    }
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
          widget.hospital == null ? 'Register Hospital' : 'Edit Hospital',
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hospital Information',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailedField('Hospital Name', _nameController, Icons.local_hospital_outlined),
              const SizedBox(height: 16),
              _buildDetailedField('Full Address', _addressController, Icons.location_on_outlined),
              const SizedBox(height: 16),
              _buildDetailedField('Emergency Phone', _phoneController, Icons.phone_outlined),
              const SizedBox(height: 16),
              _buildDetailedField('Hospital Admin Email', _emailController, Icons.email_outlined),
              const SizedBox(height: 16),
              _buildDetailedField('Login Password', _passwordController, Icons.lock_outline, isPassword: true),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDetailedField('Available Beds', _bedCountController, Icons.bed_outlined, keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDetailedField('ICU Rooms', _icuCountController, Icons.meeting_room_outlined, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailedField('Ambulance Capacity', _capacityController, Icons.directions_car_outlined, keyboardType: TextInputType.number),
              const SizedBox(height: 32),
              Text(
                'Map Location (Tap to select)',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lat: ${_selectedLocation.latitude.toStringAsFixed(4)}, Long: ${_selectedLocation.longitude.toStringAsFixed(4)}',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: _selectedLocation,
                      initialZoom: 13.0,
                      onTap: (tapPosition, point) {
                        setState(() {
                          _selectedLocation = point;
                        });
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
                            point: _selectedLocation,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_on, color: Color(0xFFC62828), size: 40),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              hospitalProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        final newHosp = HospitalModel(
                          id: widget.hospital?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          name: _nameController.text,
                          address: _addressController.text,
                          location: _selectedLocation,
                          phoneNumber: _phoneController.text,
                          bedCount: int.tryParse(_bedCountController.text) ?? 0,
                          icuCount: int.tryParse(_icuCountController.text) ?? 0,
                        );
                        
                        if (widget.hospital == null) {
                          await hospitalProvider.addHospital(
                            newHosp,
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                        } else {
                          await hospitalProvider.adminUpdateHospital(newHosp);
                        }
                        
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: Text(
                        widget.hospital == null ? 'REGISTER HOSPITAL' : 'UPDATE HOSPITAL',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedField(String label, TextEditingController controller, IconData icon, {bool isPassword = false, TextInputType? keyboardType}) {
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
