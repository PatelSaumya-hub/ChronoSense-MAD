import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MotionData {
  final double accelX;
  final double accelY;
  final double accelZ;
  final double gyroX;
  final double gyroY;
  final double gyroZ;
  final double movementScore; // 0 - 100
  final double pitch;
  final double roll;
  final bool isSimulated;

  const MotionData({
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.movementScore,
    required this.pitch,
    required this.roll,
    required this.isSimulated,
  });

  factory MotionData.zero({bool isSimulated = true}) => MotionData(
        accelX: 0.0,
        accelY: 0.0,
        accelZ: 9.8,
        gyroX: 0.0,
        gyroY: 0.0,
        gyroZ: 0.0,
        movementScore: 0.0,
        pitch: 0.0,
        roll: 0.0,
        isSimulated: isSimulated,
      );
}

class LiveSensorDataSource {
  final _controller = StreamController<MotionData>.broadcast();
  Stream<MotionData> get motionStream => _controller.stream;

  StreamSubscription<UserAccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  Timer? _mockTimer;

  bool _isMocking = false;
  bool get isMocking => _isMocking;

  double _currAccelX = 0.0;
  double _currAccelY = 0.0;
  double _currAccelZ = 9.8;
  double _currGyroX = 0.0;
  double _currGyroY = 0.0;
  double _currGyroZ = 0.0;

  DateTime? _lastPhysicalEventTime;
  double _simTime = 0.0;

  Future<void> start({bool forceMock = false}) async {
    _isMocking = forceMock;
    if (forceMock) {
      _startMockMotion();
      return;
    }

    try {
      _accelSub = userAccelerometerEventStream().listen(
        (event) {
          _lastPhysicalEventTime = DateTime.now();
          _currAccelX = event.x;
          _currAccelY = event.y;
          _currAccelZ = event.z;
          _emitCurrentMotion(isSimulated: false);
        },
        onError: (err) {
          debugPrint('ChronoSense: Accelerometer stream error: $err. Engaging mock fallback.');
          _switchToMock();
        },
        cancelOnError: false,
      );

      _gyroSub = gyroscopeEventStream().listen(
        (event) {
          _currGyroX = event.x;
          _currGyroY = event.y;
          _currGyroZ = event.z;
        },
        onError: (err) {
          debugPrint('ChronoSense: Gyroscope stream error: $err');
        },
        cancelOnError: false,
      );

      // Verify physical sensor responsiveness within 1.5 seconds; if stagnant (e.g. emulator), smoothly mock
      Timer(const Duration(milliseconds: 1500), () {
        if (_lastPhysicalEventTime == null && !_isMocking) {
          debugPrint('ChronoSense: No physical motion events detected. Activating graceful mock.');
          _switchToMock();
        }
      });
    } catch (e) {
      debugPrint('ChronoSense: Failed to bind hardware sensors: $e. Using mock fallback.');
      _switchToMock();
    }
  }

  void _switchToMock() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _isMocking = true;
    _startMockMotion();
  }

  void _startMockMotion() {
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      _simTime += 0.06;
      // Synthesize realistic micro-vibrations and natural hand sway
      final sway = math.sin(_simTime * 1.8) * 0.4 + math.cos(_simTime * 0.9) * 0.2;
      final tilt = math.cos(_simTime * 1.5) * 0.35;
      final noise = (math.Random().nextDouble() - 0.5) * 0.15;

      _currAccelX = sway + noise;
      _currAccelY = tilt + noise;
      _currAccelZ = 9.8 + math.sin(_simTime * 3.0) * 0.2;

      _currGyroX = math.cos(_simTime * 2.0) * 0.3;
      _currGyroY = math.sin(_simTime * 2.2) * 0.3;
      _currGyroZ = math.sin(_simTime * 1.1) * 0.1;

      _emitCurrentMotion(isSimulated: true);
    });
  }

  void _emitCurrentMotion({required bool isSimulated}) {
    // Dynamic motion magnitude calculation
    final accelMag = math.sqrt(_currAccelX * _currAccelX +
        _currAccelY * _currAccelY +
        math.pow(_currAccelZ - 9.8, 2));

    final gyroMag = math.sqrt(_currGyroX * _currGyroX +
        _currGyroY * _currGyroY +
        _currGyroZ * _currGyroZ);

    // Compute 0 - 100 movement score
    final rawScore = (accelMag * 22.0) + (gyroMag * 35.0);
    final score = rawScore.clamp(0.0, 100.0);

    // Calculate pitch and roll angles (in radians, clamped for graceful 3D cards)
    final pitch = math.atan2(_currAccelY, math.sqrt(_currAccelX * _currAccelX + _currAccelZ * _currAccelZ))
        .clamp(-0.45, 0.45);
    final roll = math.atan2(-_currAccelX, _currAccelZ)
        .clamp(-0.45, 0.45);

    _controller.add(MotionData(
      accelX: _currAccelX,
      accelY: _currAccelY,
      accelZ: _currAccelZ,
      gyroX: _currGyroX,
      gyroY: _currGyroY,
      gyroZ: _currGyroZ,
      movementScore: score,
      pitch: pitch,
      roll: roll,
      isSimulated: isSimulated,
    ));
  }

  void setMockMode(bool enableMock) {
    if (enableMock == _isMocking) return;
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _mockTimer?.cancel();
    _isMocking = enableMock;

    if (enableMock) {
      _startMockMotion();
    } else {
      start(forceMock: false);
    }
  }

  void dispose() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _mockTimer?.cancel();
    _controller.close();
  }
}
