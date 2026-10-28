import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AudioWaveVisualizer extends StatefulWidget {
  final double decibels;
  final double height;
  final Color? waveColor;
  final bool showDecibelBadge;

  const AudioWaveVisualizer({
    super.key,
    required this.decibels,
    this.height = 120.0,
    this.waveColor,
    this.showDecibelBadge = true,
  });

  @override
  State<AudioWaveVisualizer> createState() => _AudioWaveVisualizerState();
}

class _AudioWaveVisualizerState extends State<AudioWaveVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.waveColor ?? AppColors.colorForDecibels(widget.decibels);

    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(double.infinity, widget.height),
                painter: _WaveformPainter(
                  progress: _waveController.value,
                  decibels: widget.decibels,
                  primaryColor: activeColor,
                ),
              );
            },
          ),
          if (widget.showDecibelBadge)
            Positioned(
              top: 10,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: activeColor.withOpacity(0.5),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withOpacity(0.25),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: activeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.decibels.toStringAsFixed(1)} dB',
                      style: TextStyle(
                        color: activeColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double progress;
  final double decibels;
  final Color primaryColor;

  _WaveformPainter({
    required this.progress,
    required this.decibels,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final centerY = size.height / 2.0;
    // Map decibels to amplitude
    final normalizedDb = ((decibels - 30.0) / 60.0).clamp(0.05, 1.0);
    final amplitude = (size.height * 0.38) * normalizedDb;

    // Draw background equalizer bars
    final barCount = 36;
    final barWidth = size.width / (barCount * 1.8);
    final barPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < barCount; i++) {
      final x = (i * size.width / barCount) + (barWidth / 2);
      final phase = progress * math.pi * 2 + (i * 0.28);
      final barHeight = (math.sin(phase).abs() * amplitude * 0.85) + 4.0;

      barPaint.color = primaryColor.withOpacity(0.12 + (normalizedDb * 0.2));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, centerY),
            width: barWidth,
            height: barHeight,
          ),
          const Radius.circular(4),
        ),
        barPaint,
      );
    }

    // Draw primary fluid sinusoids
    final wave1Paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final wave2Paint = Paint()
      ..color = primaryColor.withOpacity(0.45)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path1 = Path();
    final path2 = Path();

    for (double x = 0; x <= size.width; x += 4) {
      final relativeX = x / size.width;
      // Damping at screen edges for visual elegance
      final edgeDamp = math.sin(relativeX * math.pi);

      final y1 = centerY +
          math.sin((relativeX * 3.5 * math.pi) - (progress * math.pi * 2)) *
              amplitude *
              edgeDamp;

      final y2 = centerY +
          math.cos((relativeX * 4.5 * math.pi) + (progress * math.pi * 2)) *
              (amplitude * 0.65) *
              edgeDamp;

      if (x == 0) {
        path1.moveTo(x, y1);
        path2.moveTo(x, y2);
      } else {
        path1.lineTo(x, y1);
        path2.lineTo(x, y2);
      }
    }

    canvas.drawPath(path2, wave2Paint);
    canvas.drawPath(path1, wave1Paint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) => true;
}
