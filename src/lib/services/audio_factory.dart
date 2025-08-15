import 'package:audioplayers/audioplayers.dart';

/// Simple factory to create AudioPlayer instances.
/// Tests can override `audioPlayerFactory` with a fake implementation.
abstract class AudioPlayerFactory {
  AudioPlayer create();
}

class DefaultAudioPlayerFactory implements AudioPlayerFactory {
  @override
  AudioPlayer create() => AudioPlayer();
}

// Global factory instance (can be replaced in tests)
AudioPlayerFactory audioPlayerFactory = DefaultAudioPlayerFactory();
