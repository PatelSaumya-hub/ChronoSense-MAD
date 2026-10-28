import '../models/sensor_snapshot.dart';

abstract class SensorService {
  Stream<SensorSnapshot> get liveSensorStream;
  SensorSnapshot get currentSnapshot;
  bool get isMocking;
  bool get isListening;

  Future<bool> initialize();
  void toggleMockMode(bool enableMock);
  Future<SensorSnapshot> captureSnapshot();
  void pause();
  void resume();
  void dispose();
}
