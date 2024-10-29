import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _lineAnimation;
  late Animation<double> _leeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 라인 애니메이션
    _lineAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOutCirc),
    ));

    // Lee 애니메이션
    _leeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
    ));

    _animationController.forward().then((_) {
      _navigateToMain();
    });
  }

  void _navigateToMain() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/main');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 상단 장식 라인
                Container(
                  width: 100 * _lineAnimation.value,
                  height: 1.5,
                  color: const Color(0xFF4A148C),
                ),

                const SizedBox(height: 40),

                // Lee 텍스트
                Transform.translate(
                  offset: Offset(0, 10 * (1 - _leeAnimation.value)),
                  child: Opacity(
                    opacity: _leeAnimation.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 배경 원
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF4A148C).withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        // Lee 텍스트
                        const Text(
                          'Lee',
                          style: TextStyle(
                            fontFamily: 'Dancing Script',
                            fontSize: 42,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7B1FA2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 하단 장식 라인
                Container(
                  width: 100 * _lineAnimation.value,
                  height: 1.5,
                  color: const Color(0xFF4A148C),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
