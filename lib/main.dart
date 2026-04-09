import 'package:android_cache_cleaner/cacheflow_app.dart';
import 'package:flutter/material.dart';

import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const CacheFlowApp());
}
