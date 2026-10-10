import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class AppleLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final bool isSuccess;
  final String loadingText;
  final Widget child;
  
  const AppleLoadingOverlay({
    super.key, 
    required this.isLoading, 
    this.isSuccess = false, 
    this.loadingText = 'Generating Donor Card...',
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading || isSuccess)
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: _AppleLoadingScreen(
                isSuccess: isSuccess,
                loadingText: loadingText,
              ),
            ),
          ),
      ],
    );
  }
}

class _AppleLoadingScreen extends StatefulWidget {
  final bool isSuccess;
  final String loadingText;
  
  const _AppleLoadingScreen({
    required this.isSuccess,
    required this.loadingText,
  });

  @override
  State<_AppleLoadingScreen> createState() => _AppleLoadingScreenState();
}

class _AppleLoadingScreenState extends State<_AppleLoadingScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _successController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
    _successController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void didUpdateWidget(_AppleLoadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSuccess && !oldWidget.isSuccess) {
      _successController.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 320, // Increased to fit galaxy flow
              height: 320,
              child: AnimatedBuilder(
                animation: Listenable.merge([_controller, _successController]),
                builder: (context, child) {
                  // 3D Parallax Tilt Math
                  final double tiltX = math.sin(_controller.value * math.pi * 4) * 0.15;
                  final double tiltY = math.cos(_controller.value * math.pi * 4) * 0.15;
                  
                  // Organic Lub-Dub pulse for the heart
                  // Two sharp peaks close together, then a pause
                  final double t = (_controller.value * 12) % 1.0; 
                  final double lub = math.max(0.0, math.sin(t * math.pi * 4)) * (t < 0.25 ? 1.0 : 0.0);
                  final double dub = math.max(0.0, math.sin((t - 0.15) * math.pi * 4)) * (t > 0.15 && t < 0.4 ? 1.0 : 0.0);
                  final double pulseScale = 1.0 + (lub * 0.1) + (dub * 0.05);

                  final Matrix4 parallaxMatrix = Matrix4.identity()
                    ..setEntry(3, 2, 0.002) // Perspective depth
                    ..rotateX(tiltX)
                    ..rotateY(tiltY);

                  return Transform(
                    transform: parallaxMatrix,
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Optical Bloom Layer (Glowing Galaxy) - Made more subtle
                        Opacity(
                          opacity: 0.35, // Reduced glow intensity
                          child: ImageFiltered(
                            imageFilter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                            child: CustomPaint(
                              size: const Size(320, 320),
                              painter: _AppleSwirlPainter(_controller.value, _successController.value, isGlow: true),
                            ),
                          ),
                        ),
                        
                        // Crisp Particle Layer
                        CustomPaint(
                          size: const Size(320, 320),
                          painter: _AppleSwirlPainter(_controller.value, _successController.value, isGlow: false),
                        ),

                        // Center Logos
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glowing Heart Bloom - Made more subtle
                            if (!widget.isSuccess)
                              Transform.scale(
                                scale: pulseScale,
                                child: ImageFiltered(
                                  imageFilter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Color(0x33E52D27), // 20% opacity instead of 40%
                                    size: 56,
                                  ),
                                ),
                              ),
                            // Crisp Heart Icon
                            Transform.scale(
                              scale: widget.isSuccess 
                                  ? (1.0 - _successController.value) 
                                  : pulseScale,
                              child: Opacity(
                                opacity: 1.0 - _successController.value,
                                child: ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [Color(0xFFE52D27), Color(0xFFB31217)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 56,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Checkmark Icon (Success)
                            Transform.scale(
                              scale: _successController.value,
                              child: Opacity(
                                opacity: _successController.value,
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 72,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 50),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                widget.isSuccess ? 'Success!' : widget.loadingText,
                key: ValueKey<bool>(widget.isSuccess ? true : false),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                widget.isSuccess ? 'READY TO SAVE LIVES' : 'SECURING YOUR PROFILE',
                key: ValueKey<bool>(widget.isSuccess),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: widget.isSuccess ? Colors.green.shade600 : Colors.grey.shade500,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppleSwirlPainter extends CustomPainter {
  final double progress;
  final double successProgress;
  final bool isGlow;

  _AppleSwirlPainter(this.progress, this.successProgress, {this.isGlow = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (successProgress >= 1.0) return; 

    final center = Offset(size.width / 2, size.height / 2);

    final sweepGradient = const SweepGradient(
      colors: [
        Color(0xFFF2A384),
        Color(0xFFE66B9D),
        Color(0xFF8B47DD),
        Color(0xFF67A9ED),
        Color(0xFFF2A384),
      ],
      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      transform: GradientRotation(-math.pi / 2),
    );

    final rect = Rect.fromCircle(center: center, radius: size.width / 2);
    final paint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.fill;

    const int numArms = 20; 
    const int dotsPerArm = 9; 
    const double baseRadius = 45.0; 
    const double maxRadius = 140.0;
    const double spiralCurve = 0.6; 

    final double collapseCurve = math.pow(successProgress, 3).toDouble();

    for (int arm = 0; arm < numArms; arm++) {
      final double armBaseAngle = (arm * (math.pi * 2) / numArms) + (progress * math.pi * 4);

      for (int dot = 0; dot < dotsPerArm; dot++) {
        final double angle = armBaseAngle + (dot * spiralCurve);
        
        // Magnetic Flow: Dots flow INWARD toward the heart over time
        // progress flows 0 -> 1. We multiply by dotsPerArm to make it flow continuously.
        final double flowOffset = (dot - (progress * dotsPerArm * 3)) % dotsPerArm;
        final double normalizedFlow = (flowOffset < 0 ? flowOffset + dotsPerArm : flowOffset) / dotsPerArm; // 0.0 (center) to 1.0 (edge)
        
        // Calculate radius based on the inward flow
        final double standardRadius = baseRadius + (normalizedFlow * (maxRadius - baseRadius));
        final double radius = standardRadius * (1.0 - collapseCurve);

        final double x = center.dx + radius * math.cos(angle);
        final double y = center.dy + radius * math.sin(angle);

        // Dots are small at the edge, grow as they fall in, then shrink right before hitting the heart
        double sizeMultiplier = math.sin(normalizedFlow * math.pi); // 0 at edges, 1 in middle
        final double baseDotSize = 2.0 + (sizeMultiplier * 3.5);
        
        // Organic Lub-Dub pulse applied to dots
        final double t = (progress * 12 - (normalizedFlow * 0.5)) % 1.0; 
        final double lub = math.max(0.0, math.sin(t * math.pi * 4)) * (t < 0.25 ? 1.0 : 0.0);
        final double dub = math.max(0.0, math.sin((t - 0.15) * math.pi * 4)) * (t > 0.15 && t < 0.4 ? 1.0 : 0.0);
        
        // Boost size for the glow layer slightly so it doesn't overpower
        final double glowBoost = isGlow ? 1.15 : 1.0;
        final double dotSize = (baseDotSize + (lub * 2.0) + (dub * 1.0)) * glowBoost * (1.0 - successProgress);

        if (dotSize > 0) {
          canvas.drawCircle(Offset(x, y), dotSize, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AppleSwirlPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.successProgress != successProgress;
  }
}
