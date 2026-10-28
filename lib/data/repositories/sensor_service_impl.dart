import 'dart:async';
import '../../domain/models/sensor_snapshot.dart';
import '../../domain/repositories/sensor_service.dart';
import '../datasources/ambient_noise_datasource.dart';
import '../datasources/live_sensor_datasource.dart';

class SensorServiceImpl implements SensorService {
  final LiveSensorDataSource _motionDataSource;
  final AmbientNoiseDataSource _noiseDataSource;

  final _unifiedController = StreamController<SensorSnapshot>.broadcast();
  StreamSubscription<MotionData>? _motionSub;
  StreamSubscription<AudioLevelData>? _audioSub;

  SensorSnapshot _currentSnapshot = SensorSnapshot.calmBaseline();
  bool _isListening = false;
  bool _isMockMode = false;

  SensorServiceImpl({
    LiveSensorDataSource? motionDataSource,
    AmbientNoiseDataSource? noiseDataSource,
  })  : _motionDataSource = motionDataSource ?? LiveSensorDataSource(),
        _noiseDataSource = noiseDataSource ?? AmbientNoiseDataSource();

  @override
  Stream<SensorSnapshot> get liveSensorStream => _unifiedController.stream;

  @override
  SensorSnapshot get currentSnapshot => _currentSnapshot;

  @override
  bool get isMocking => _isMockMode || _motionDataSource.isMocking || _noiseDataSource.isMocking;

  @override
  bool get isListening => _isListening;

  @override
  Future<bool> initialize() async {
    if (_isListening) return true;

    await _motionDataSource.start(forceMock: _isMockMode);
    await _noiseDataSource.start(forceMock: _isMockMode);

    _motionSub = _motionDataSource.motionStream.listen((motion) {
      _currentSnapshot = _currentSnapshot.copyWith(
        accelX: motion.accelX,
        accelY: motion.accelY,
        accelZ: motion.accelZ,
        gyroX: motion.gyroX,
        gyroY: motion.gyroY,
        gyroZ: motion.gyroZ,
        movementScore: motion.movementScore,
        pitch: motion.pitch,
        roll: motion.roll,
        isSimulated: motion.isSimulated || _noiseDataSource.isMocking,
        timestamp: DateTime.now(),
      );
      _unifiedController.add(_currentSnapshot);
    });

    _audioSub = _noiseDataSource.audioStream.listen((audio) {
      _currentSnapshot = _currentSnapshot.copyWith(
        decibelLevel: audio.decibels,
        isSimulated: audio.isSimulated || _motionDataSource.isMocking,
        timestamp: DateTime.now(),
      );
      _unifiedController.add(_currentSnapshot);
    });

    _isListening = true;
    return true;
  }

  @override
  void toggleMockMode(bool enableMock) {
    _isMockMode = enableMock;
    _motionDataSource.setMockMode(enableMock);
    _noiseDataSource.setMockMode(enableMock);
    _currentSnapshot = _currentSnapshot.copyWith(isSimulated: enableMock);
    _unifiedController.add(_currentSnapshot);
  }

  @override
  Future<SensorSnapshot> captureSnapshot() async {
    // Return a pristine copy of the sensor state at this exact millisecond
    return _currentSnapshot.copyWith(
      timestamp: DateTime.now(),
    );
  }

  @override
  void pause() {
    _motionSub?.pause();
    _audioSub?.pause();
  }

  @override
  void resume() {
    _motionSub?.resume();
    _audioSub?.resume();
  }

  @override
  void dispose() {
    _motionSub?.cancel();
    _audioSub?.cancel();
    _motionDataSource.dispose();
    _noiseDataSource.dispose();
    _unifiedController.close();
    _isListening = false;
  }
}
