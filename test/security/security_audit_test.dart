import 'package:android_cache_cleaner/data/datasources/native_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late NativeChannel nativeChannel;
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    nativeChannel = NativeChannel();
    
    // Intercept MethodChannel calls to simulate Native responses
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(nativeChannel.channel, (MethodCall methodCall) async {
      log.add(methodCall);
      
      switch (methodCall.method) {
        case 'clearCache':
          final packages = methodCall.arguments['packages'] as List<dynamic>;
          // Simulate the Native Regex/Security validation
          final packageRegex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+$');
          for (var pkg in packages) {
            if (!packageRegex.hasMatch(pkg.toString())) {
              throw PlatformException(code: 'SECURITY_ERROR', message: 'Invalid package name');
            }
          }
          return true;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    log.clear();
  });

  group('Security Audit - Injection & Traversal Protection', () {
    test('should reject malicious package names (Command Injection attempt)', () async {
      final maliciousPackages = ['com.example.app; rm -rf /'];
      
      expect(
        () => nativeChannel.clearCache(maliciousPackages),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('SECURITY_ERROR'))),
      );
    });

    test('should reject path traversal attempts in package names', () async {
      final traversalPackages = ['../../data/system'];
      
      expect(
        () => nativeChannel.clearCache(traversalPackages),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('SECURITY_ERROR'))),
      );
    });

    test('should accept valid package names', () async {
      final validPackages = ['com.sahraouilarbi.cacheflow', 'org.mozilla.firefox'];
      
      final result = await nativeChannel.clearCache(validPackages);
      expect(result, isTrue);
    });
  });
}
