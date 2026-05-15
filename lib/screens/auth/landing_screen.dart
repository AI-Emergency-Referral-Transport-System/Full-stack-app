import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Disable swipe
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              _buildHeroPage(),
              _buildEcosystemPage(),
              _buildCTAPage(),
            ],
          ),
          // Top Navigation (Logo)
          Positioned(
            top: 60,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_hospital, color: Color(0xFFC62828), size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'DERASH',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                if (_currentPage > 0)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.grey),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
              ],
            ),
          ),
          // Bottom Navigation (Arrows and Indicators)
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Page Indicators
                Row(
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? const Color(0xFFC62828)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                // Next Arrow
                GestureDetector(
                  onTap: _nextPage,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFC62828),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 120),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFC62828).withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFFC62828)),
                  const SizedBox(width: 4),
                  Text(
                    'TRUSTED EMERGENCY NETWORK',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFC62828),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Seconds Save\nLives.',
              style: GoogleFonts.poppins(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            Text(
              'Connected\nCare Delivers\nResults.',
              style: GoogleFonts.poppins(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFC62828),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'DERASH synchronizes patients, ambulances, and hospital units into a single, high-performance ecosystem.',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFC62828).withValues(alpha: 0.1),
              ),
              child: const Center(
                child: Icon(Icons.emergency_outlined, size: 80, color: Color(0xFFC62828)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEcosystemPage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 120),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THE DERASH\nECOSYSTEM',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seamless integration across all critical emergency nodes.',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 48),
            _buildEcosystemFeature(
              icon: Icons.person_outline,
              title: 'The Patient',
              description: 'Real-time status tracking and direct communication with responders.',
            ),
            _buildEcosystemFeature(
              icon: Icons.local_shipping_outlined,
              title: 'The Dispatch',
              description: 'Advanced routing to ensure the closest ambulance arrives first.',
            ),
            _buildEcosystemFeature(
              icon: Icons.local_hospital_outlined,
              title: 'The Hospital',
              description: 'Live data streaming allows medical units to prepare for arrival.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTAPage() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFC62828),
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 120),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emergency, color: Colors.white, size: 80),
            const SizedBox(height: 48),
            Text(
              'Ready to modernize your emergency response?',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Join hundreds of healthcare units already optimized by the Derash platform.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 64),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFC62828),
                minimumSize: const Size(double.infinity, 64),
              ),
              child: Text(
                'CREATE ACCOUNT',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 64),
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'LOGIN TO PORTAL',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEcosystemFeature({required IconData icon, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFC62828).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFC62828)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
