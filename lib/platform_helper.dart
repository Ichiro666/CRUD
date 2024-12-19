import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class PlatformHelper {
  static Future<void> configurePlatform() async {
    if (!kIsWeb) {
      // Initialize for desktop/mobile platforms
      sqfliteFfiInit();
      // Set the database factory
      databaseFactory = databaseFactoryFfi;
    }
  }
}
