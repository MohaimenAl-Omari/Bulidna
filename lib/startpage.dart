import 'package:buildna/view/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/startup_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    _controller.forward();
    Future.delayed(const Duration(seconds: 5), () async {
      final startup = Get.put(StartupController());
      final ok = await startup.boot(); // this calls determainController(role) internally

      if (!ok) {
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/static/carpentry 1.png',
            fit: BoxFit.cover, 
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.6),
            colorBlendMode: BlendMode.darken,
          ),
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation, 
              child: FadeTransition(
                opacity: _fadeAnimation, 
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.construction, // Placeholder icon
                        color: Colors.amber,
                        size: 80,
                      ),
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter', 
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'BUILD',
                            style: TextStyle(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const TextSpan(
                            text: 'NA',
                            style: TextStyle(color: Colors.amber),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
