import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:airwave/core/constants/api_constants.dart';
import 'package:airwave/features/catalog/domain/models/channel.dart';
import 'package:airwave/features/catalog/domain/models/stream_source.dart';
import 'package:airwave/features/catalog/presentation/controllers/catalog_controller.dart';

enum PlayerAspectRatio {
  fit('Fit (16:9)', 16 / 9),
  fill('Fill', null),
  standard('Standard (4:3)', 4 / 3);

  final String label;
  final double? ratio;
  const PlayerAspectRatio(this.label, this.ratio);
}

class PlayerViewState {
  final Channel? currentChannel;
  final int currentStreamIndex;
  final bool isPlaying;
  final bool isBuffering;
  final bool isMuted;
  final double volume;
  final double brightness;
  final bool showControls;
  final bool isLocked;
  final PlayerAspectRatio aspectRatio;
  final String? statusMessage;
  final String? errorMessage;
  final int sleepTimerMinutes;

  const PlayerViewState({
    this.currentChannel,
    this.currentStreamIndex = 0,
    this.isPlaying = false,
    this.isBuffering = true,
    this.isMuted = false,
    this.volume = 1.0,
    this.brightness = 0.5,
    this.showControls = true,
    this.isLocked = false,
    this.aspectRatio = PlayerAspectRatio.fit,
    this.statusMessage,
    this.errorMessage,
    this.sleepTimerMinutes = 0,
  });

  PlayerViewState copyWith({
    Channel? currentChannel,
    int? currentStreamIndex,
    bool? isPlaying,
    bool? isBuffering,
    bool? isMuted,
    double? volume,
    double? brightness,
    bool? showControls,
    bool? isLocked,
    PlayerAspectRatio? aspectRatio,
    String? statusMessage,
    String? errorMessage,
    int? sleepTimerMinutes,
  }) {
    return PlayerViewState(
      currentChannel: currentChannel ?? this.currentChannel,
      currentStreamIndex: currentStreamIndex ?? this.currentStreamIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      isMuted: isMuted ?? this.isMuted,
      volume: volume ?? this.volume,
      brightness: brightness ?? this.brightness,
      showControls: showControls ?? this.showControls,
      isLocked: isLocked ?? this.isLocked,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      statusMessage: statusMessage,
      errorMessage: errorMessage,
      sleepTimerMinutes: sleepTimerMinutes ?? this.sleepTimerMinutes,
    );
  }
}

class PlayerNotifier extends Notifier<PlayerViewState> {
  late final Player player;
  late final VideoController videoController;

  Timer? _controlsTimer;
  Timer? _frameTimeoutTimer;
  Timer? _sleepTimer;
  StreamSubscription<bool>? _bufferingSub;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<String>? _errorSub;

  @override
  PlayerViewState build() {
    player = Player(configuration: const PlayerConfiguration());
    videoController = VideoController(player);

    _listenToPlayerStreams();

    ref.onDispose(() {
      _controlsTimer?.cancel();
      _frameTimeoutTimer?.cancel();
      _sleepTimer?.cancel();
      _bufferingSub?.cancel();
      _playingSub?.cancel();
      _errorSub?.cancel();
      player.dispose();
      WakelockPlus.disable().ignore();
    });

    return const PlayerViewState();
  }

  void _listenToPlayerStreams() {
    _bufferingSub = player.stream.buffering.listen((buffering) {
      state = state.copyWith(isBuffering: buffering);
      if (!buffering) {
        _frameTimeoutTimer?.cancel();
      }
    });

    _playingSub = player.stream.playing.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });

    _errorSub = player.stream.error.listen((err) {
      debugPrint('MediaKit error: $err');
      _handleStreamFailure();
    });
  }

  Future<void> loadChannel(Channel channel, {int streamIndex = 0}) async {
    _frameTimeoutTimer?.cancel();
    WakelockPlus.enable().ignore();

    // Record history
    ref.read(historyNotifierProvider.notifier).recordPlay(channel.id).ignore();

    if (channel.streams.isEmpty) {
      state = state.copyWith(
        currentChannel: channel,
        errorMessage: 'No playable stream sources available for this channel.',
        isBuffering: false,
      );
      return;
    }

    final safeIndex = streamIndex.clamp(0, channel.streams.length - 1);
    state = state.copyWith(
      currentChannel: channel,
      currentStreamIndex: safeIndex,
      isBuffering: true,
      errorMessage: null,
      statusMessage: null,
    );

    await _playStream(channel.streams[safeIndex]);
  }

  Future<void> _playStream(StreamSource stream) async {
    try {
      final headers = <String, String>{};
      if (stream.referrer != null && stream.referrer!.isNotEmpty) {
        headers['Referer'] = stream.referrer!;
      }
      if (stream.userAgent != null && stream.userAgent!.isNotEmpty) {
        headers['User-Agent'] = stream.userAgent!;
      }

      final media = Media(
        stream.url,
        httpHeaders: headers.isNotEmpty ? headers : null,
      );

      await player.open(media, play: true);

      // 8s no-frame / connection timeout rule
      _frameTimeoutTimer?.cancel();
      _frameTimeoutTimer = Timer(ApiConstants.playerStreamTimeout, () {
        if (state.isBuffering && state.currentChannel != null) {
          debugPrint('Stream 8s timeout exceeded, auto-failing over...');
          _handleStreamFailure();
        }
      });
    } catch (e) {
      debugPrint('Error playing stream: $e');
      _handleStreamFailure();
    }
  }

  void _handleStreamFailure() {
    final ch = state.currentChannel;
    if (ch == null || ch.streams.isEmpty) return;

    final nextIndex = state.currentStreamIndex + 1;
    if (nextIndex < ch.streams.length) {
      // Auto failover toast
      final total = ch.streams.length;
      state = state.copyWith(
        currentStreamIndex: nextIndex,
        isBuffering: true,
        statusMessage: 'Source ${nextIndex + 1} of $total — switching…',
      );
      _playStream(ch.streams[nextIndex]);
    } else {
      // Friendly final error
      state = state.copyWith(
        isBuffering: false,
        errorMessage: 'Offline, geo-blocked or unsupported stream source.',
        statusMessage: null,
      );
    }
  }

  void switchStream(int index) {
    final ch = state.currentChannel;
    if (ch == null || index < 0 || index >= ch.streams.length) return;
    state = state.copyWith(
      currentStreamIndex: index,
      isBuffering: true,
      errorMessage: null,
      statusMessage: null,
    );
    _playStream(ch.streams[index]);
  }

  void retryCurrent() {
    final ch = state.currentChannel;
    if (ch != null && ch.streams.isNotEmpty) {
      loadChannel(ch, streamIndex: 0);
    }
  }

  void zapChannel(List<Channel> channels, int direction) {
    if (channels.isEmpty || state.currentChannel == null) return;
    final currentIndex = channels.indexWhere((c) => c.id == state.currentChannel!.id);
    if (currentIndex == -1) return;

    final nextIndex = (currentIndex + direction + channels.length) % channels.length;
    loadChannel(channels[nextIndex]);
  }

  void togglePlayPause() {
    player.playOrPause();
  }

  void toggleMute() {
    final newMuted = !state.isMuted;
    player.setVolume(newMuted ? 0 : state.volume * 100);
    state = state.copyWith(isMuted: newMuted);
  }

  void setVolume(double volume) {
    final clamped = volume.clamp(0.0, 1.0);
    player.setVolume(clamped * 100);
    state = state.copyWith(volume: clamped, isMuted: clamped == 0);
  }

  void setBrightness(double val) {
    state = state.copyWith(brightness: val.clamp(0.1, 1.0));
  }

  void toggleControls() {
    if (state.isLocked) return;
    state = state.copyWith(showControls: !state.showControls);
    if (state.showControls) {
      _startControlsAutoHide();
    }
  }

  void toggleLock() {
    final newLock = !state.isLocked;
    state = state.copyWith(isLocked: newLock, showControls: !newLock);
  }

  void cycleAspectRatio() {
    final current = state.aspectRatio;
    final next = PlayerAspectRatio.values[(current.index + 1) % PlayerAspectRatio.values.length];
    state = state.copyWith(aspectRatio: next);
  }

  void setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    if (minutes <= 0) {
      state = state.copyWith(sleepTimerMinutes: 0);
      return;
    }
    state = state.copyWith(sleepTimerMinutes: minutes);
    _sleepTimer = Timer(Duration(minutes: minutes), () {
      player.pause();
      state = state.copyWith(isPlaying: false, sleepTimerMinutes: 0);
    });
  }

  void _startControlsAutoHide() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (!state.isLocked) {
        state = state.copyWith(showControls: false);
      }
    });
  }
}

final playerControllerProvider =
    NotifierProvider<PlayerNotifier, PlayerViewState>(PlayerNotifier.new);
