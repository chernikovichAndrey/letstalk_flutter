import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_video_caching/flutter_video_caching.dart';
import 'package:lets_talk/app.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lets_talk/common/service/callkit_service.dart';
import 'package:lets_talk/common/service/push_notification_service.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/app/config/firebase_options.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await VideoProxy.init();
  await configureDependencies();
  await getIt<PushNotificationService>().initialize();
  await getIt<CallKitService>().initialize();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const App());
}