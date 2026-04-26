import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Animasi Flip (Berputar 360 derajat)
    _flipAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOutBack),
      ),
    );

    // Animasi Memantul (Bounce)
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.bounceOut),
      ),
    );

    // Animasi Muncul Halus
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A), // Biru Gelap ala Loading Game
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Efek Cahaya Belakang (Glow)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: 200 * _bounceAnimation.value,
                height: 200 * _bounceAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2 * _fadeAnimation.value),
                      blurRadius: 50,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              );
            },
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animasi Logo Flip & Bounce
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..scale(_bounceAnimation.value) // Efek Memantul
                        ..rotateY(_flipAnimation.value), // Efek Flip 3D
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Image.asset(
                          'assets/images/smp5logo.png',
                          width: 150,
                          height: 150,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                
                // Teks Nama Sekolah dengan Animasi Slide Up
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _controller.value > 0.6 ? 1.0 : 0.0,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - _bounceAnimation.value)),
                        child: const Column(
                          children: [
                            Text(
                              "SMP NEGERI 5",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                                shadows: [
                                  Shadow(color: Colors.blue, blurRadius: 10)
                                ]
                              ),
                            ),
                            Text(
                              "LUMAJANG",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 22,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 6,
                              ),
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
          
          // Loading Bar di paling bawah
          Positioned(
            bottom: 50,
            child: SizedBox(
              width: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  backgroundColor: Colors.white10,
                  color: Colors.blue,
                  minHeight: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Tambahan extension warna jika diperlukan
extension on TextStyle {
  static const Color blueOutline = Colors.white70;
}
