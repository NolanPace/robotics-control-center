import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robotics_control_center/main.dart';

void main(){
 testWidgets('dashboard displays primary controls',(tester) async{
  await tester.pumpWidget(const RobotApp());
  expect(find.text('Robotics Control Center'),findsOneWidget);
  expect(find.text('Start'),findsOneWidget);
  expect(find.byType(Slider),findsNWidgets(2));
 });
}