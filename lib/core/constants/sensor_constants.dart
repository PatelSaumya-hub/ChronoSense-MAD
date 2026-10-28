class SensorConstants {
  SensorConstants._();

  // Decibel Thresholds (dB)
  static const double dbWhisper = 35.0;
  static const double dbQuiet = 48.0;
  static const double dbModerate = 65.0;
  static const double dbLoud = 78.0;
  static const double dbMax = 110.0;

  // Movement Score Thresholds (0 - 100)
  static const double motionStill = 20.0;
  static const double motionGentle = 45.0;
  static const double motionActive = 70.0;
  static const double motionChaotic = 85.0;

  // Telemetry Sample Rates
  static const int sensorPollingRateMs = 100;
  static const int visualizerUpdateRateMs = 40; // 25 FPS visualizer updates

  // Default initial values
  static const double defaultCalmDecibels = 38.0;
  static const double defaultCalmMotion = 12.0;
}
