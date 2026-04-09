import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class NativeChannel {
  final MethodChannel channel = const MethodChannel('com.sahraouilarbi.cacheflow/native');

  Future<List<Map<String, dynamic>>> getAppStats() async {
    try {
      final List<dynamic> result = await channel.invokeMethod('getAppStats');
      return result.map((e) => Map<String, dynamic>.from(e)).toList();
    } on PlatformException catch (e) {
      throw Exception('Failed to get app stats: [${e.code}] ${e.message}');
    }
  }

  Future<bool> clearCache(List<String> packageNames) async {
    try {
      final bool result = await channel.invokeMethod('clearCache', {'packages': packageNames});
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to clear cache: [${e.code}] ${e.message}');
    }
  }

  Future<bool> isAccessibilityServiceEnabled() async {
    try {
      final bool result = await channel.invokeMethod('isAccessibilityServiceEnabled');
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to check accessibility service: [${e.code}] ${e.message}');
    }
  }

  Future<void> requestAccessibilityService() async {
    try {
      await channel.invokeMethod('requestAccessibilityService');
    } on PlatformException catch (e) {
      throw Exception('Failed to request accessibility service: [${e.code}] ${e.message}');
    }
  }

  Future<bool> triggerAccessibilityCleaning(List<String> packageNames) async {
    try {
      final bool result = await channel.invokeMethod('triggerAccessibilityCleaning', {'packages': packageNames});
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to trigger accessibility cleaning: [${e.code}] ${e.message}');
    }
  }
}
