import 'package:flutter/widgets.dart';
import 'app.dart';
import 'core/di/injection.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const TranslyApp());
}
