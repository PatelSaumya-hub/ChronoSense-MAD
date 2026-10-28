import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/models/sensor_snapshot.dart';
import '../../domain/repositories/sensor_service.dart';

class SensorStreamController extends ChangeNotifier {
  final SensorService _sensorService;
  StreamSubscription<SensorSnapshot>? _subscription;

  SensorSnapshot _currentSnapshot = SensorSnapshot.calmBaseline();
  bool _isLocked = false;
  SensorSnapshot? _lockedSnapshot;

  SensorStreamController(this._sensorService);

  SensorSnapshot get currentSnapshot => _isLocked && _lockedSnapshot != null
      ? _lockedSnapshot!
      : _currentSnapshot;

  bool get isLocked => _isLocked;
  bool get isMocking => _sensorService.isMocking;

  Future<void> initialize() async {
    await _sensorService.initialize();
    _subscription = _sensorService.liveSensorStream.listen((snapshot) {
      if (!_isLocked) {
        _currentSnapshot = snapshot;
        notifyListeners();
      }
    });
  }

  void toggleMockMode(bool enableMock) {
    _sensorService.toggleMockMode(enableMock);
    notifyListeners();
  }

  /// Freezes/captures current live telemetry snapshot for the journal entry
  void captureTelemetry() {
    _lockedSnapshot = _currentSnapshot.copyWith(timestamp: DateTime.now());
    _isLocked = true;
    notifyListeners();
  }

  /// Unlocks telemetry back to live reading
  void resetCapture() {
    _isLocked = false;
    _lockedSnapshot = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _sensorService.dispose();
    super.dispose();
  }
}
