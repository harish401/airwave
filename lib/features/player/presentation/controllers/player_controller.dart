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

enum AudioPreset {
  standard('Standard'),
  vocalBoost('Vocal Boost (Clear Speech)'),
  bassBoost('Bass Boost (Music & Action)');

  final String label;
  const AudioPreset(this.label);
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
  final AudioPreset audioPreset;
  final String? statusMessage;
  final String? errorMessage;
  final int sleepTimerMinutes;
  final bool isMiniPlayer;
  final bool isAudioOnly;
  final int retryAttempts;
  final List<String> audioTracks;
  final List<String> subtitleTracks;
  final String? selectedAudioTrack;
  final String? selectedSubtitleTrack;

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
    this.audioPreset = AudioPreset.standard,
    this.statusMessage,
    this.errorMessage,
    this.sleepTimerMinutes = 0,
    this.isMiniPlayer = false,
    this.isAudioOnly = false,
    this.retryAttempts = 0,
    this.audioTracks = const [],
    this.subtitleTracks = const [],
    this.selectedAudioTrack,
    this.selectedSubtitleTrack,
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
    AudioPreset? audioPreset,
    String? statusMessage,
    String? errorMessage,
    int? sleepTimerMinutes,
    bool? isMiniPlayer,
    bool? isAudioOnly,
    int? retryAttempts,
    List<String>? audioTracks,
    List<String>? subtitleTracks,
    String? selectedAudioTrack,
    String? selectedSubtitleTrack,
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
      audioPreset: audioPreset ?? this.audioPreset,
      statusMessage: statusMessage,
      errorMessage: errorMessage,
      sleepTimerMinutes: sleepTimerMinutes ?? this.sleepTimerMinutes,
      isMiniPlayer: isMiniPlayer ?? this.isMiniPlayer,
      isAudioOnly: isAudioOnly ?? this.isAudioOnly,
      retryAttempts: retryAttempts ?? this.retryAttempts,
      audioTracks: audioTracks ?? this.audioTracks,
      subtitleTracks: subtitleTracks ?? this.subtitleTracks,
      selectedAudioTrack: selectedAudioTrack ?? this.selectedAudioTrack,
      selectedSubtitleTrack: selectedSubtitleTrack ?? this.selectedSubtitleTrack,
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
        // Reset retry attempts on successful buffer/play
        if (state.retryAttempts > 0) {
          state = state.copyWith(retryAttempts: 0);
        }
      }
    });

    _playingSub = player.stream.playing.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });

    _errorSub = player.stream.error.listen((err) {
      debugPrint('MediaKit error: $err');
      // On iOS Simulator, coreaudio frequently logs "Could not open/initialize audio device -> no sound."
      // This is a simulator audio output warning and NOT a fatal stream network failure.
      if (err.contains('audio device') || err.contains('no sound')) {
        return;
      }
      _handleStreamFailure();
    });

    // Listen to tracks (audio & subtitles)
    player.stream.tracks.listen((tracks) {
      final audios = tracks.audio.map((a) => a.title?.isNotEmpty == true ? a.title! : (a.language ?? 'Audio ${a.id}')).toList();
      final subs = tracks.subtitle.map((s) => s.title?.isNotEmpty == true ? s.title! : (s.language ?? 'Subtitle ${s.id}')).toList();
      state = state.copyWith(
        audioTracks: audios,
        subtitleTracks: subs,
      );
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
      retryAttempts: 0,
    );

    await _playStream(channel.streams[safeIndex]);
  }

  Future<void> _playStream(StreamSource stream) async {
    try {
      final isYouTube = stream.url.contains('googlevideo.com') || stream.channel == 'youtube';
      final headers = <String, String>{};

      if (!isYouTube && stream.userAgent != 'NONE') {
        headers['User-Agent'] = stream.userAgent != null && stream.userAgent!.isNotEmpty
            ? stream.userAgent!
            : 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1';

        if (stream.referrer != null && stream.referrer!.isNotEmpty) {
          headers['Referer'] = stream.referrer!;
        }
      }

      final media = Media(
        stream.url,
        httpHeaders: headers.isNotEmpty ? headers : null,
      );

      await player.open(media, play: true);

      // 14s timeout for mobile streams before failover
      _frameTimeoutTimer?.cancel();
      _frameTimeoutTimer = Timer(ApiConstants.playerStreamTimeout, () {
        if (state.isBuffering && state.currentChannel != null) {
          debugPrint('Stream timeout exceeded on mobile, attempting silent retry or auto-failover...');
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

    // 1. Silent Retry: Try the exact same stream once more with a 1.2s delay before giving up or failing over
    if (state.retryAttempts < 1) {
      state = state.copyWith(
        retryAttempts: state.retryAttempts + 1,
        isBuffering: true,
      );
      Timer(const Duration(milliseconds: 1200), () {
        if (state.currentChannel != null) {
          _playStream(ch.streams[state.currentStreamIndex]);
        }
      });
      return;
    }

    // 2. Next source failover if available
    final nextIndex = state.currentStreamIndex + 1;
    if (nextIndex < ch.streams.length) {
      final total = ch.streams.length;
      state = state.copyWith(
        currentStreamIndex: nextIndex,
        retryAttempts: 0,
        isBuffering: true,
        statusMessage: 'Source ${nextIndex + 1} of $total — switching…',
      );
      _playStream(ch.streams[nextIndex]);
    } else {
      // 3. Final error if all sources failed
      state = state.copyWith(
        isBuffering: false,
        errorMessage: 'Offline, geo-blocked or unsupported stream source.',
        statusMessage: null,
      );
    }
  }

  void toggleAudioOnly() {
    state = state.copyWith(isAudioOnly: !state.isAudioOnly);
  }

  void setAudioPreset(AudioPreset preset) {
    state = state.copyWith(audioPreset: preset);
    // Adjust software volume gain or normalization based on preset
    if (preset == AudioPreset.vocalBoost) {
      player.setVolume((state.volume * 1.15).clamp(0.0, 1.0) * 100);
    } else if (preset == AudioPreset.bassBoost) {
      player.setVolume((state.volume * 1.08).clamp(0.0, 1.0) * 100);
    } else {
      player.setVolume(state.volume * 100);
    }
  }

  void selectAudioTrack(int index) {
    player.setAudioTrack(player.state.tracks.audio[index]);
    if (index < state.audioTracks.length) {
      state = state.copyWith(selectedAudioTrack: state.audioTracks[index]);
    }
  }

  void selectSubtitleTrack(int index) {
    if (index < 0) {
      player.setSubtitleTrack(SubtitleTrack.no());
      state = state.copyWith(selectedSubtitleTrack: null);
    } else {
      player.setSubtitleTrack(player.state.tracks.subtitle[index]);
      if (index < state.subtitleTracks.length) {
        state = state.copyWith(selectedSubtitleTrack: state.subtitleTracks[index]);
      }
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

  void minimizePlayer() {
    state = state.copyWith(isMiniPlayer: true);
  }

  void expandPlayer() {
    state = state.copyWith(isMiniPlayer: false);
  }

  void closePlayer() {
    _frameTimeoutTimer?.cancel();
    _sleepTimer?.cancel();
    player.stop();
    WakelockPlus.disable().ignore();
    state = const PlayerViewState();
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
