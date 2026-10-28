# 🌌 ChronoSense — Dynamic Sensory Memory Journal

[![Flutter](https://img.shields.io/badge/Flutter-3.x%20%7C%20Dart%203-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-6C5CE7)](https://flutter.dev)
[![Design](https://img.shields.io/badge/UI-Cyber%20Glassmorphism-00CEC9)](https://flutter.dev)
[![Sensors](https://img.shields.io/badge/Sensors-Acoustic%20%26%20Kinematic-FD79A8)](https://pub.dev/packages/sensors_plus)
[![Platform](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web-2ED573)](#platforms)

> **ChronoSense** transforms personal journaling from static text into living, sensory time-capsules. When you record a memory, ChronoSense captures the exact ambient telemetry of that fleeting moment—ambient acoustic decibels, 3D accelerometer stability, gyroscope angular tilts, and emotional frequency. Upon opening a past memory, the application's entire UI ambiance—background particle velocities, wave harmonic frequencies, and neon specular lighting—morphs into the sensory state of that original moment.

---

## 🔮 Key Innovations

### 1. 🎙️ Real-Time Acoustic Spectrum Analysis
- Streams continuous decibel ($\text{dB}$) readings through hardware microphone telemetry via `noise_meter` and `permission_handler`.
- Dynamic CustomPainter waveform visualizer renders sinusoidal harmonic frequencies and spectral bars that pulse in sync with live sound pressure.

### 2. 📱 3D Kinematics & Gyroscope Motion Reactor
- Captures 3-axis acceleration ($X, Y, Z$) and rotational velocity ($\text{rad/s}$) using `sensors_plus`.
- Calculates an objective **Movement Score** ($0 - 100\%$) and derives 3D Euler angles (Pitch & Roll).
- Renders an interactive 3D perspective card powered by a 4D homogeneous transformation matrix (`Matrix4.identity()..setEntry(3, 2, 0.0018)..rotateX(pitch)..rotateY(roll)`).

### 3. 🌀 Context-Morphing Sensory Replay
- Opening any memory triggers the **Sensory Morphing Engine**:
  - **Bioluminescent Calm (<40 dB, <20% Motion):** Slow, gentle cyan particles drift peacefully with low-frequency waves.
  - **Conversational Flow (40-65 dB, 20-50% Motion):** Balanced purple/violet ambient radiance with moderate harmonic oscillation.
  - **High Metropolitan Chaos (>75 dB, >70% Motion):** Electric pink and amber radial flare with high-speed particles and turbulent waveforms.

### 4. 🛡️ Fault-Tolerant Telemetry Engine (Zero Crash Guarantee)
- If hardware sensors are unavailable (e.g., Android/iOS Simulator, Web, Desktop, or if microphone permissions are denied), ChronoSense activates an **organic synthetic telemetry engine**.
- Users and examiners can also toggle between `LIVE` and `MOCK` modes on demand via the Capture Screen toggle.

### 5. 💾 Offline-First Local Storage & Instant Demo Seeding
- Backed by persistent key-value JSON storage (`shared_preferences`).
- Comes pre-seeded with **3 rich authentic sensory memories** (*Midnight Astronomy Peak*, *Neon Metro Transit Pulse*, and *Rainy Loft Architecture Study*) so graders can immediately evaluate sensory morphing without having to type first.

---

## 🏛️ Clean Architecture Breakdown

ChronoSense adheres strictly to Clean Architecture principles, ensuring modularity, testability, and separation of concerns:

```
lib/
├── core/
│   ├── constants/
│   │   └── sensor_constants.dart     # Decibel & motion classification thresholds
│   ├── theme/
│   │   ├── app_colors.dart           # Neon Cyber palette (#6C5CE7, #00CEC9, #FD79A8)
│   │   └── app_theme.dart            # Dark theme, Glassmorphism typography & styles
│   └── utils/
│       └── date_formatter.dart       # Human-readable temporal stamps
│
├── domain/
│   ├── models/
│   │   ├── mood_type.dart            # Mood taxonomy (Serene, Energetic, Reflective, etc.)
│   │   ├── sensor_snapshot.dart      # Immutable 3D telemetry & acoustic data model
│   │   └── journal_entry.dart        # Complete sensory memory entity
│   └── repositories/
│       ├── journal_repository.dart   # Abstract contract for memory persistence
│       └── sensor_service.dart       # Abstract contract for multi-modal telemetry streams
│
├── data/
│   ├── datasources/
│   │   ├── local_storage_datasource.dart # SharedPreferences + auto demo seed
│   │   ├── live_sensor_datasource.dart   # SensorsPlus + synthetic kinematic generator
│   │   └── ambient_noise_datasource.dart # NoiseMeter + acoustic room simulator
│   └── repositories/
│       ├── journal_repository_impl.dart  # Concrete persistence implementation
│       └── sensor_service_impl.dart      # Unified telemetry fusion engine
│
├── presentation/
│   ├── providers/
│   │   ├── journal_controller.dart       # State management for entries, stats & search
│   │   └── sensor_stream_controller.dart # Live capture stream & freeze controller
│   ├── screens/
│   │   ├── dashboard_screen.dart         # Glassmorphism timeline & sensory stats HUD
│   │   ├── capture_screen.dart           # Real-time visualizers & memory encoder
│   │   └── entry_detail_screen.dart      # Immersive sensory replay modal
│   └── widgets/
│       ├── glass_container.dart          # BackdropFilter frosted glass widget
│       ├── ambient_particle_field.dart   # CustomPainter reactive particle canvas
│       ├── audio_wave_visualizer.dart    # CustomPainter acoustic sinusoidal waves
│       ├── gyro_tilt_card.dart           # 3D Matrix4 perspective kinematics card
│       ├── sensor_badge_pill.dart        # Glowing telemetry badge chips
│       └── mood_selector.dart            # Interactive neon mood picker
│
└── main.dart                             # Application bootstrap & dependency injection
```

---

## 🎨 Color Palette & Design System

| Role | Color | Hex Code | Visual Expression |
| :--- | :---: | :---: | :--- |
| **Primary Neon** | Cyber Purple | `#6C5CE7` | Primary accents, buttons, reflective mood |
| **Secondary Neon** | Cyber Cyan | `#00CEC9` | Acoustic visualizers, tranquil state, serene mood |
| **Tertiary Neon** | Cyber Pink | `#FD79A8` | High turbulence, motion indicators, anxious mood |
| **Warning/Energy** | Amber Flare | `#FFA502` | Energetic pulses, simulation indicators |
| **Canvas** | Obsidian Deep | `#0A0C16` | Ultra dark background for high-contrast neon |
| **Surface Glass** | Translucent Slate | `rgba(27,33,59,0.35)` | Frosted glass cards with blurred backdrop |

---

## ⚙️ Hardware Permissions Configuration

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<!-- Ambient Acoustic & Motion Telemetry Permissions -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.HIGH_SAMPLING_RATE_SENSORS" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<!-- Microphone & Motion Usage Descriptions -->
<key>NSMicrophoneUsageDescription</key>
<string>ChronoSense requires microphone access to measure ambient sound decibels and capture auditory memory ambiance.</string>
<key>NSMotionUsageDescription</key>
<string>ChronoSense requires motion sensor access to capture accelerometer and gyroscope stability telemetry during journal entries.</string>
```

---

## 🚀 Getting Started & Execution

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.10.0 or higher
- Dart SDK 3.0.0 or higher

### 1. Clone & Fetch Dependencies
```bash
git clone <your-repo-url>
cd "ChronoSense - MAD "
flutter pub get
```

### 2. Run the Application
```bash
# Run on connected device or simulator
flutter run

# Run directly on Chrome (Web)
flutter run -d chrome

# Run directly on Android / iOS
flutter run -d android
flutter run -d ios
```

---

## 🧪 Grader & Examiner Walkthrough Guide

Follow these steps to experience the complete feature set:

1. **Inspect Pre-Seeded Memories on Launch:**
   - Launch the app. Observe the 3 pre-seeded memories on the Timeline showing dynamic badges (`31 dB • Serene Whisper`, `82 dB • Energetic Pulse`, `52 dB • Gentle Murmur`).
   - Notice the top HUD calculating the running **Acoustic Average** and **Motion Index**.

2. **Test Filter & Search:**
   - Type `"Transit"` or `"Astronomy"` in the search bar.
   - Tap mood chips like `🌿 Serene` or `⚡ Energetic` to filter entries instantly.

3. **Experience Context-Morphing Replay:**
   - Tap on **"Midnight Astronomy Peak"**: The entire screen ambiance shifts to deep, calm bioluminescent cyan with slow, tranquil particles and gentle waves.
   - Go back and tap **"Neon Metro Transit Pulse"**: The entire screen shifts into high-energy turbulence with electric pink/amber flaring, rapid particle dispersion, and intense waveforms.
   - Inspect the **Sensor Telemetry Matrix** at the bottom showing exact $X, Y, Z$ vectors.

4. **Encode a New Sensory Memory:**
   - Tap the **"Capture Telemetry"** floating button.
   - Observe the live **Acoustic Spectrum Stream** and **3D Kinematics Card** tilting as you move the phone (or sway organically in simulated mode).
   - Toggle the **MOCK / LIVE** switch in the top app bar to demonstrate the fallback engine.
   - Tap **"Freeze Ambient Telemetry"** to lock the instantaneous sensory snapshot.
   - Select a mood frequency, enter a title, add tags (e.g. `#Demo`), and tap **"Encode & Save Memory"**.
   - Watch the new memory appear seamlessly at the top of your timeline!

---

## 📄 License
This project is built for academic & practical evaluation under the Mobile Application Development curriculum. Released under the MIT License.
