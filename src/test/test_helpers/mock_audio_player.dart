import 'package:audioplayers/audioplayers.dart';
import 'package:easy_ssh_mob_new/services/audio_factory.dart';

class MockAudioPlayer extends AudioPlayer {
  bool _isDisposed = false;
  double _volume = 1.0;
  String? _lastPlayedSource;
  @override
  Future<void> play(
    Source source, {
    double? volume,
    double? balance,
    AudioContext? ctx,
    Duration? position,
    PlayerMode? mode,
  }) async {
    if (_isDisposed) throw Exception('AudioPlayer disposed');
    if (source is AssetSource) {
      _lastPlayedSource = source.path;
    }
    return;
  }

  @override
  Future<void> setVolume(double volume) async {
    if (_isDisposed) throw Exception('AudioPlayer disposed');
    _volume = volume;
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
  }

  @override
  Future<void> pause() async {
    if (_isDisposed) throw Exception('AudioPlayer disposed');
  }

  @override
  Future<void> resume() async {
    if (_isDisposed) throw Exception('AudioPlayer disposed');
  }

  @override
  Future<void> stop() async {
    if (_isDisposed) throw Exception('AudioPlayer disposed');
  }

  @override
  Future<void> seek(Duration position) async {
    if (_isDisposed) throw Exception('AudioPlayer disposed');
  }

  @override
  Future<void> setPlaybackRate(double rate) async {
    if (_isDisposed) throw Exception('AudioPlayer disposed');
  }

  @override
  Future<void> setPlayerMode(PlayerMode mode) async {
    if (_isDisposed) throw Exception('AudioPlayer disposed');
  }

  @override
  Future<void> setSource(Source source) async {
    if (_isDisposed) throw Exception('AudioPlayer disposed');
    if (source is AssetSource) {
      _lastPlayedSource = source.path;
    }
  }

  @override
  Future<void> setReleaseMode(ReleaseMode mode) async {
    if (_isDisposed) throw Exception('AudioPlayer disposed');
  }

  @override
  Future<void> setAudioContext(AudioContext ctx) async {
    if (_isDisposed) throw Exception('AudioPlayer disposed');
  }

  @override
  Future<Duration?> getDuration() async {
    if (_isDisposed) throw Exception('AudioPlayer disposed');
    return const Duration(seconds: 1);
  }

  @override
  Future<Duration?> getCurrentPosition() async {
    if (_isDisposed) throw Exception('AudioPlayer disposed');
    return Duration.zero;
  }

  @override
  PlayerState get state => PlayerState.stopped;
  bool get isDisposed => _isDisposed;
  double get volume => _volume;
  String? get lastPlayedSource => _lastPlayedSource;
}

class MockAudioPlayerFactory implements AudioPlayerFactory {
  @override
  AudioPlayer create() => MockAudioPlayer();
}
