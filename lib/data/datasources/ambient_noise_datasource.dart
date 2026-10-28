import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioLevelData {
  final double decibels;
  final bool isSimulated;

  const AudioLevelData({
    required this.decibels,
    required this.isSimulated,
  });
}

class AmbientNoiseDataSource {
  final _controller = StreamController<AudioLevelData>.broadcast();
  Stream<AudioLevelData> get audioStream => _controller.stream;

  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSub;
  Timer? _mockTimer;

  bool _isMocking = false;
  bool get isMocking => _isMocking;

  double _simTime = 0.0;
  double _baseDb = 42.0;

  Future<void> start({bool forceMock = false}) async {
    _isMocking = forceMock;
    if (forceMock) {
      _startMockAcoustics();
      return;
    }

    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        debugPrint('ChronoSense: Mic permission not granted. Activating acoustic simulator.');
        _switchToMock();
        return;
      }

      _noiseMeter = NoiseMeter();
      _noiseSub = _noiseMeter?.noise.listen(
        (NoiseReading reading) {
          final db = reading.meanDecibel.isFinite
              ? reading.meanDecibel.clamp(20.0, 110.0)
              : 40.0;
          _controller.add(AudioLevelData(decibels: db, isSimulated: false));
        },
        onError: (err) {
          debugPrint('ChronoSense: Noise meter stream error: $err. Activating acoustic simulator.');
          _switchToMock();
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('ChronoSense: Exception starting hardware NoiseMeter: $e. Using fallback.');
      _switchToMock();
    }
  }

  void _switchToMock() {
    _noiseSub?.cancel();
    _isMocking = true;
    _startMockAcoustics();
  }

  void _startMockAcoustics() {
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(milliseconds: 70), (timer) {
      _simTime += 0.07;
      // Synthesize realistic ambient acoustic drift (ambient quiet ~38dB, pulsing with organic speech rhythm)
      final organicWave = math.sin(_simTime * 1.5) * 8.0 + math.sin(_simTime * 4.2) * 4.0;
      final speechPulse = (math.sin(_simTime * 0.4) > 0.7) ? math.sin(_simTime * 8.0).abs() * 22.0 : 0.0;
      final microJitter = (math.Random().nextDouble() - 0.5) * 3.0;

      final simulatedDb = (_baseDb + organicWave + speechPulse + microJitter).clamp(28.0, 95.0);
      _controller.add(AudioLevelData(decibels: simulatedDb, isSimulated: true));
    });
  }

  void setBaseAcousticLevel(double baseDb) {
    _baseDb = baseDb;
  }

  void setMockMode(bool enableMock) {
    if (enableMock == _isMocking) return;
    _noiseSub?.cancel();
    _mockTimer?.cancel();
    _isMocking = enableMock;

    if (enableMock) {
      _startMockAcoustics();
    } else {
      start(forceMock: false);
    }
  }

  void dispose() {
    _noiseSub?.cancel();
    _mockTimer?.cancel();
    _controller.close();
  }
}
