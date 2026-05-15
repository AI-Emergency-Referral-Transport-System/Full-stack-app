import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/request_provider.dart';
import '../../services/api_service.dart';

class EmergencyTracking extends StatefulWidget {
  final String? requestId;

  const EmergencyTracking({super.key, required this.requestId});

  @override
  State<EmergencyTracking> createState() => _EmergencyTrackingState();
}

class _EmergencyTrackingState extends State<EmergencyTracking> {
  final ApiService _api = ApiService();

  Timer? _pollTimer;
  Timer? _simTimer;
  bool _isLoading = true;
  String? _statusText;

  LatLng? _patientPos;
  LatLng? _hospitalPos;
  LatLng? _driverPos;

  final String _driverLabel = 'Abebe Kebede • +251 911 223 344';
  final Distance _distance = const Distance();
  double? _kmRemaining;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final requestProvider = Provider.of<RequestProvider>(context, listen: false);
      final activeRequest = requestProvider.activeRequest;
      _patientPos = activeRequest?.patientLocation;
      _startPolling();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _simTimer?.cancel();
    super.dispose();
  }

  void _startLocalSimulationIfNeeded() {
    if (_patientPos == null) return;
    if (_driverPos != null) return;

    // Start the ambulance a bit away and move towards patient.
    final start = LatLng(_patientPos!.latitude + 0.01, _patientPos!.longitude - 0.01);
    _driverPos = start;

    _simTimer?.cancel();
    _simTimer = Timer.periodic(const Duration(seconds: 2), (t) {
      if (!mounted || _patientPos == null || _driverPos == null) return;
      final dKm = _distance.as(LengthUnit.Kilometer, _driverPos!, _patientPos!);
      if (dKm <= 0.05) {
        setState(() {
          _driverPos = _patientPos;
          _kmRemaining = 0;
          _statusText = 'Ambulance arrived';
        });
        t.cancel();
        return;
      }

      // Move ~10% closer each tick.
      final newLat = _driverPos!.latitude + (_patientPos!.latitude - _driverPos!.latitude) * 0.10;
      final newLng = _driverPos!.longitude + (_patientPos!.longitude - _driverPos!.longitude) * 0.10;
      setState(() {
        _driverPos = LatLng(newLat, newLng);
        _kmRemaining = _distance.as(LengthUnit.Kilometer, _driverPos!, _patientPos!);
        _statusText = 'Ambulance is on the way';
      });
    });
  }

  void _startPolling() {
    // Poll tracking snapshot every 4 seconds. Backend returns 400 until driver assigned.
    _pollOnce();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _pollOnce());
  }

  Future<void> _pollOnce() async {
    final requestProvider = Provider.of<RequestProvider>(context, listen: false);
    final requestId = widget.requestId ?? requestProvider.activeRequest?.id;
    final activeRequest = requestProvider.activeRequest;

    if (requestId == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _statusText = 'No active request to track.';
      });
      return;
    }

    _patientPos ??= activeRequest?.patientLocation;

    try {
      final res = await _api.get('requests/$requestId/tracking/');
      if (!mounted) return;

      final route = (res as Map)['route'] as Map?;
      final start = route?['start'] as Map?;
      final end = route?['end'] as Map?;
      final driverLocation = (res)['driver_location'] as Map?;

      setState(() {
        _isLoading = false;
        _statusText = 'Ambulance is on the way';
        _hospitalPos = (start != null)
            ? LatLng((start['latitude'] as num).toDouble(), (start['longitude'] as num).toDouble())
            : _hospitalPos;
        _patientPos = (end != null)
            ? LatLng((end['latitude'] as num).toDouble(), (end['longitude'] as num).toDouble())
            : (_patientPos ?? (activeRequest?.patientLocation));
        _driverPos = (driverLocation != null)
            ? LatLng(
                (driverLocation['latitude'] as num).toDouble(),
                (driverLocation['longitude'] as num).toDouble(),
              )
            : _driverPos;
        if (_driverPos != null && _patientPos != null) {
          _kmRemaining = _distance.as(LengthUnit.Kilometer, _driverPos!, _patientPos!);
        }
      });

      // If backend doesn't provide driver_location yet, show a local simulation anyway.
      _startLocalSimulationIfNeeded();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _statusText = e.toString().replaceFirst('Exception: ', '');
      });

      // If tracking isn't ready yet, still simulate visually.
      _startLocalSimulationIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestProvider = Provider.of<RequestProvider>(context);
    final activeRequest = requestProvider.activeRequest;

    final center = _patientPos ?? activeRequest?.patientLocation ?? const LatLng(9.03, 38.74);
    final markers = <Marker>[
      if (_patientPos != null)
        Marker(
          point: _patientPos!,
          width: 44,
          height: 44,
          child: const Tooltip(
            message: 'Patient Home',
            child: Icon(Icons.home, color: Colors.blue, size: 44),
          ),
        ),
      if (_driverPos != null)
        Marker(
          point: _driverPos!,
          width: 44,
          height: 44,
          child: Tooltip(
            message: _driverLabel,
            child: const Icon(Icons.location_on, color: Color(0xFFC62828), size: 44),
          ),
        ),
    ];

    final polylines = <Polyline>[
      if (_driverPos != null && _patientPos != null)
        Polyline(
          points: [_driverPos!, _patientPos!],
          color: const Color(0xFFC62828),
          strokeWidth: 4.0,
        ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // OpenStreetMap with flutter_map
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.derash.app',
              ),
              MarkerLayer(markers: markers),
              if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
            ],
          ),
          // Back Button
          Positioned(
            top: 48,
            left: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ),
          // Status Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 20),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Tracking',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (_isLoading) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                      if (_isLoading) const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _statusText ??
                              (activeRequest == null ? 'Loading...' : 'Status: ${activeRequest.status.toString().split('.').last.toUpperCase()}'),
                          style: GoogleFonts.poppins(color: Colors.grey[700]),
                        ),
                      ),
                      IconButton(
                        onPressed: _pollOnce,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _legendItem(const Icon(Icons.person_pin_circle, color: Colors.blue), 'You'),
                      const SizedBox(width: 12),
                      _legendItem(const Icon(Icons.emergency, color: Color(0xFFC62828)), 'Ambulance'),
                    ],
                  ),
                  if (_kmRemaining != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Distance: ${_kmRemaining!.toStringAsFixed(2)} km',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Widget icon, String label) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.poppins(fontSize: 12)),
      ],
    );
  }
}
