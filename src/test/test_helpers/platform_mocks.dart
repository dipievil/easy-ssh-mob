import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_audio_setup.dart';
void registerPlatformMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupTestAudio();
  final audioGlobalChannel =
      const MethodChannel('xyz.luan/audioplayers.global');
  final audioCreateChannel = const MethodChannel('xyz.luan/audioplayers');
  final audioEventsChannel =
      const MethodChannel('xyz.luan/audioplayers.global/events');
  final storageChannel =
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final Map<String, String> secureStorage = {};
  TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(audioCreateChannel, (MethodCall call) async {
    if (call.method == 'create') {
      return null;
    }
    return null;
  });
  TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(audioEventsChannel, (MethodCall call) async {
    switch (call.method) {
      case 'listen':
        return null;
      case 'cancel':
        return null;
      default:
        return null;
    }
  });
  TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(audioGlobalChannel, (MethodCall call) async {
    switch (call.method) {
      case 'init':
      case 'listen':
      case 'pause':
      case 'resume':
      case 'stop':
      case 'play':
      case 'setUrl':
        return null;
      default:
        return null;
    }
  });
  TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(storageChannel, (MethodCall call) async {
    final args = call.arguments;
    final key =
        (args is Map && args.containsKey('key')) ? args['key'] as String : null;
    switch (call.method) {
      case 'read':
        return key != null ? secureStorage[key] : null;
      case 'write':
        if (args is Map && key != null) {
          final value = args['value'] as String?;
          if (value != null) secureStorage[key] = value;
        }
        return null;
      case 'readAll':
        return Map<String, String>.from(secureStorage);
      case 'delete':
        if (key != null) secureStorage.remove(key);
        return null;
      case 'containsKey':
        return key != null ? secureStorage.containsKey(key) : false;
      case 'deleteAll':
        secureStorage.clear();
        return null;
      default:
        return null;
    }
  });
}
