import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get visitUrl => dotenv.env['VISIT_URL'] ?? '';

  static String get appBundle => dotenv.env['APP_BUNDLE_ID'] ?? '';

  static String get firebaseAndroidApiKey =>
      dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '';

  static String get firebaseAndroidAppId =>
      dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? '';

  static String get firebaseIosApiKey =>
      dotenv.env['FIREBASE_IOS_API_KEY'] ?? '';

  static String get firebaseIosAppId => dotenv.env['FIREBASE_IOS_APP_ID'] ?? '';

  static String get firebaseMessagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';

  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  static String get firebaseStorageBucket =>
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
}
