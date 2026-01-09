import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lets_talk/app.dart';

import 'common/observer/custom_bloc_observer.dart';

// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
// }

void main() async {
  await dotenv.load(fileName: '.env');
  // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const App());
}