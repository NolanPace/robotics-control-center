# Robotics Control Center

A **Flutter / Dart cross-platform telemetry dashboard** paired with a **C++17 differential-drive robot simulation**. The app supports a visual robot pose monitor, editable velocity commands, trail rendering, status panels and log streaming.

## Flutter UI
Install Flutter and run:
```bash
cd app
flutter pub get
flutter run -d windows
```
Alternatively choose `linux` or `macos`; the dashboard runs with its built-in Dart simulation if the native executable isn't available. The UI code is written for desktop Flutter.

## C++ simulator
```bash
cmake -S simulator -B build
cmake --build build
ctest --test-dir build --output-on-failure
./build/robot_simulator
```
The C++ process reads `linear angular` commands from stdin, emits newline-delimited JSON telemetry to stdout, and simulates nonholonomic kinematics. In the Flutter app, **Connect native** opens an adjacent `robot_simulator` or `robot_simulator.exe` executable if installed in `app/`. A simulation mode is always available if not connected.

## Scope
A synthetic local robot visualization, not remote robot control. No actual robotics hardware or network access is required. Velocity values are capped for demonstration; physical robot safety still requires hardware constraints and emergency stops.

MIT licensed.
