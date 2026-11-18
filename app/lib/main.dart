import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() => runApp(const RobotApp());

class RobotApp extends StatelessWidget {
  const RobotApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    title: 'Robotics Control Center',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: const Color(0xFF08111E),
      colorScheme: const ColorScheme.dark(primary: Color(0xFF61BEED)),
    ),
    home: const ControlScreen(),
  );
}

class Pose {
  final double x, y, heading;
  const Pose(this.x, this.y, this.heading);
}

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});
  @override State<ControlScreen> createState() => _ControlScreenState();
}
class _ControlScreenState extends State<ControlScreen> {
  Pose pose = const Pose(0, 0, 0);
  final List<Pose> trail = [const Pose(0, 0, 0)];
  double linear = .65, angular = .25;
  bool running = false;
  Timer? timer;
  Process? process;
  StreamSubscription<String>? subscription;
  final List<String> logs = [];
  bool native = false;
  void _log(String text) {
    if (!mounted) return;
    setState(() {logs.insert(0, text); if(logs.length > 25) logs.removeLast();});
  }
  void _handle(String line) {
    try {
      final data = jsonDecode(line) as Map<String, dynamic>;
      if(data.containsKey('x')) {
        setState(() {
          pose = Pose((data['x'] as num).toDouble(), (data['y'] as num).toDouble(), (data['heading'] as num).toDouble());
          trail.add(pose); if (trail.length > 150) trail.removeAt(0);
        });
      } else {_log(line);}
    } catch (_) {_log(line);}
  }
  Future<void> connect() async {
    try {
      final executable = Platform.isWindows ? 'robot_simulator.exe' : './robot_simulator';
      final child = await Process.start(executable, []);
      process = child;
      subscription = child.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen(_handle);
      child.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen(_log);
      child.exitCode.then((_) {if(mounted)setState(() {native = false;running = false;});});
      setState(() {native = true;});
      _log('Connected to native C++ simulation.');
    } catch (e) {_log('Native executable unavailable: $e. Using Dart simulation.');}
  }
  void step() {
    if (native) {
      process?.stdin.writeln('${linear.toStringAsFixed(4)} ${angular.toStringAsFixed(4)}');
    } else {
      const dt = .1;
      final h = pose.heading + angular * dt / 2;
      final next = Pose(pose.x + linear * math.cos(h) * dt, pose.y + linear * math.sin(h) * dt, pose.heading + angular * dt);
      setState(() {
        pose = next; trail.add(next); if (trail.length > 150) trail.removeAt(0);
      });
    }
  }
  void toggle() {
    if (running) {timer?.cancel();setState(() => running = false);}
    else {
      setState(() => running = true);
      timer = Timer.periodic(const Duration(milliseconds: 100), (_) => step());
    }
  }
  void reset() {
    timer?.cancel();setState(() {
      running = false;pose = const Pose(0,0,0);trail..clear()..add(pose);
    });
    if (native) {_log('Reset in UI. Restart native process to reset its internal pose.');}
  }
  @override void dispose(){timer?.cancel();subscription?.cancel();process?.kill();super.dispose();}
  Widget stat(String title, String value) => Expanded(child: Card(color: const Color(0xFF15283E), child: Padding(
    padding: const EdgeInsets.all(18),child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [Text(title,style: const TextStyle(color: Colors.blueGrey)),const SizedBox(height: 10),Text(value,style: const TextStyle(fontSize: 25,fontWeight: FontWeight.bold))]),
  )));
  @override Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1300),child: Padding(
      padding: const EdgeInsets.all(22),child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
        const Text('ROBOTICS / FLUTTER + C++',style: TextStyle(color: Color(0xFF77CAFA),letterSpacing: 2)),
        const SizedBox(height: 8),
        const Text('Robotics Control Center',style: TextStyle(fontSize: 32,fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(children: [stat('X POSITION','${pose.x.toStringAsFixed(2)} m'),stat('Y POSITION','${pose.y.toStringAsFixed(2)} m'),stat('HEADING','${(pose.heading*180/math.pi).toStringAsFixed(1)}°')]),
        Expanded(child: Row(children: [
          Expanded(flex: 3, child: Card(color: const Color(0xFF13263B),child: Padding(padding: const EdgeInsets.all(14), child: LayoutBuilder(builder:(context, constraints)=>CustomPaint(size: Size(constraints.maxWidth,constraints.maxHeight),painter: RobotPainter(pose,trail))))),
          const SizedBox(width: 14),
          Expanded(flex: 2,child: Column(children: [
            Card(color: const Color(0xFF13263B),child: Padding(padding: const EdgeInsets.all(18),child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
              Text('Linear speed: ${linear.toStringAsFixed(2)} m/s'),Slider(value: linear,min: -2,max: 2,onChanged:(v)=>setState(()=>linear=v)),
              Text('Angular speed: ${angular.toStringAsFixed(2)} rad/s'),Slider(value: angular,min: -3,max: 3,onChanged:(v)=>setState(()=>angular=v)),
              Wrap(spacing: 8,children: [FilledButton(onPressed: toggle,child: Text(running?'Pause':'Start')),OutlinedButton(onPressed: step,child: const Text('Step')),OutlinedButton(onPressed: reset,child: const Text('Reset')),OutlinedButton(onPressed:native?null:connect,child: const Text('Connect native'))]),
            ]))),
            Expanded(child: Card(color: const Color(0xFF13263B),child: Padding(padding: const EdgeInsets.all(14),child: ListView(children: [Text(native?'NATIVE C++ CONNECTED':'DART SIMULATION MODE',style: const TextStyle(color: Color(0xFF74DDB4))),const Divider(),...logs.map((x)=>Text(x,style: const TextStyle(fontSize: 12)))])))),
          ])),
        ])),
      ]),
    )))));
  }
}
class RobotPainter extends CustomPainter {
  final Pose pose;final List<Pose> trail;
  RobotPainter(this.pose,this.trail);
  @override void paint(Canvas canvas,Size size) {
    final center = Offset(size.width/2,size.height/2);
    final grid = Paint()..color=const Color(0xFF2A3F58)..strokeWidth=1;
    for(double x=0;x<size.width;x+=35){canvas.drawLine(Offset(x,0),Offset(x,size.height),grid);}
    for(double y=0;y<size.height;y+=35){canvas.drawLine(Offset(0,y),Offset(size.width,y),grid);}
    Offset xy(Pose p)=>center+Offset(p.x*35,-p.y*35);
    final path=Path();
    for(int i=0;i<trail.length;i++){final pt=xy(trail[i]);if(i==0)path.moveTo(pt.dx,pt.dy);else path.lineTo(pt.dx,pt.dy);}
    canvas.drawPath(path,Paint()..color=const Color(0xFF66DBB2)..strokeWidth=2..style=PaintingStyle.stroke);
    final here=xy(pose);canvas.drawCircle(here,14,Paint()..color=const Color(0xFF65B8F3));
    final tip=here+Offset(math.cos(pose.heading)*23,-math.sin(pose.heading)*23);
    canvas.drawLine(here,tip,Paint()..color=Colors.white..strokeWidth=3);
  }
  @override bool shouldRepaint(RobotPainter other)=>true;
}