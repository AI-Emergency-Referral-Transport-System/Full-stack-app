import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/hospital_provider.dart';
import 'providers/request_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/patient/patient_home.dart';
import 'screens/hospital/hospital_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/driver/driver_dashboard.dart';
import 'screens/auth/landing_screen.dart';
import 'screens/auth/register_screen.dart';
import 'models/user_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HospitalProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
      ],
      child: const DerashApp(),
    ),
  );
}

class DerashApp extends StatefulWidget {
  const DerashApp({super.key});

  @override
  State<DerashApp> createState() => _DerashAppState();
}

class _DerashAppState extends State<DerashApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Derash Emergency',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC62828),
          primary: const Color(0xFFC62828),
          secondary: const Color(0xFFE53935),
          surface: const Color(0xFFF8F9FA),
          onSurface: Colors.black87,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFC62828), width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC62828),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
        ),
        useMaterial3: true,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            switch (auth.user!.role) {
              case UserRole.patient: return const PatientHome();
              case UserRole.hospital: return const HospitalDashboard();
              case UserRole.admin: return const AdminDashboard();
              case UserRole.driver: return const DriverDashboard();
            }
          }
          return const LandingScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (!auth.isAuthenticated) return const LandingScreen();
            switch (auth.user!.role) {
              case UserRole.patient: return const PatientHome();
              case UserRole.hospital: return const HospitalDashboard();
              case UserRole.admin: return const AdminDashboard();
              case UserRole.driver: return const DriverDashboard();
            }
          },
        ),
      },
    );
  }
}
