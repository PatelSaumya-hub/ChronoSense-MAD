import 'dart:math' as math;
import 'package:flutter/material.dart';

class AmbientParticleField extends StatefulWidget {
  final double chaosFactor; // 0.0 (Zen Calm) to 1.0 (Extreme Chaos)
  final Color primaryColor;
  final Color secondaryColor;
  final Widget? child;

  const AmbientParticleField({
    super.key,
    this.chaosFactor = 0.2,
    required this.primaryColor,
    required this.secondaryColor,
    this.child,
  });

  @override
  State<AmbientParticleField> createState() => _AmbientParticleFieldState();
}

class _Particle {
  double x;
  double y;
  double radius;
  double speedX;
  double speedY;
  double alpha;
  double pulsePhase;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speedX,
    required this.speedY,
    required this.alpha,
    required this.pulsePhase,
  });
}

class _AmbientParticleFieldState extends State<AmbientParticleField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();
  final int _particleCount = 45;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _initParticles();
  }

  void _initParticles() {
    _particles.clear();
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        radius: 1.5 + _random.nextDouble() * 3.5,
        speedX: (_random.nextDouble() - 0.5) * 0.0015,
        speedY: (_random.nextDouble() - 0.5) * 0.0015,
        alpha: 0.15 + _random.nextDouble() * 0.5,
        pulsePhase: _random.nextDouble() * math.pi * 2,
      ));
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            chaos: widget.chaosFactor,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
          ),
          child: widget.child ?? const SizedBox.expand(),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double chaos;
  final Color primaryColor;
  final Color secondaryColor;

  _ParticlePainter({
    required this.particles,
    required this.chaos,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final speedMultiplier = 1.0 + (chaos * 6.5);
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      // Update position with chaos factor
      p.x += p.speedX * speedMultiplier;
      p.y += p.speedY * speedMultiplier;

      // Wrap around canvas boundaries
      if (p.x < 0) p.x = 1.0;
      if (p.x > 1.0) p.x = 0.0;
      if (p.y < 0) p.y = 1.0;
      if (p.y > 1.0) p.y = 0.0;

      p.pulsePhase += 0.04 * (1.0 + chaos * 3.0);
      final pulse = (math.sin(p.pulsePhase) + 1.0) / 2.0;
      final currentAlpha = (p.alpha * 0.7 + pulse * 0.3).clamp(0.05, 0.9);

      // Interpolate particle color based on position and chaos
      final particleColor = Color.lerp(
        primaryColor,
        secondaryColor,
        (p.x + p.y) / 2.0,
      )!.withOpacity(currentAlpha);

      paint.color = particleColor;

      final currentRadius = p.radius * (1.0 + (chaos * 0.6) * pulse);
      final center = Offset(p.x * size.width, p.y * size.height);

      // Render glowing soft particle
      canvas.drawCircle(center, currentRadius, paint);

      // If chaotic or high energy, draw secondary halo ring
      if (chaos > 0.4) {
        final haloPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = particleColor.withOpacity(currentAlpha * 0.35);
        canvas.drawCircle(center, currentRadius * 2.2, haloPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
