import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../catalog/domain/models/channel.dart';
import '../../../catalog/presentation/controllers/catalog_controller.dart';
import '../../../catalog/presentation/widgets/channel_card.dart';
import '../controllers/player_controller.dart';

class PlayerView extends ConsumerStatefulWidget {
  final String channelId;

  const PlayerView({super.key, required this.channelId});

  @override
  ConsumerState<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends ConsumerState<PlayerView> {
  bool _isFullscreen = false;
  bool _showSwipeHint = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initChannel();
    });
    // Auto-hide the swipe hint pill after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showSwipeHint = false);
    });
  }

  void _initChannel() {
    final current = ref.read(playerControllerProvider).currentChannel;
    if (current != null && current.id == widget.channelId) {
      // Channel is already loaded into player controller (e.g. from Custom M3U / YouTube / Deep link)
      return;
    }

    final catalog = ref.read(filteredChannelsProvider);
    final ch = catalog.where((c) => c.id == widget.channelId).firstOrNull;
    if (ch != null) {
      ref.read(playerControllerProvider.notifier).loadChannel(ch);
    } else {
      ref.read(catalogRepositoryProvider).getChannelById(widget.channelId).then((found) {
        if (found != null && mounted) {
          ref.read(playerControllerProvider.notifier).loadChannel(found);
        }
      });
    }
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerControllerProvider);
    final playerNotifier = ref.read(playerControllerProvider.notifier);
    final allChannels = ref.watch(filteredChannelsProvider);
    final channel = playerState.currentChannel;

    final relatedChannels = channel != null
        ? allChannels
            .where((c) =>
                c.id != channel.id &&
                (c.categories.any((cat) => channel.categories.contains(cat)) ||
                    c.countryCode == channel.countryCode))
            .take(12)
            .toList()
        : <Channel>[];

    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape || _isFullscreen;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          playerNotifier.minimizePlayer();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          top: !isLandscape,
          bottom: !isLandscape,
        child: isLandscape
            ? _buildVideoSurface(playerState, playerNotifier, allChannels, isLandscape)
            : Column(
                children: [
                  // Video Surface with Ambient Cinema Glow Effect (Feature #4)
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.liveRed.withOpacity(0.18),
                          blurRadius: 36,
                          spreadRadius: 8,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: AppColors.neonCyan.withOpacity(0.12),
                          blurRadius: 48,
                          spreadRadius: 4,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: _buildVideoSurface(playerState, playerNotifier, allChannels, false),
                  ),
                  // Channel Info & More Like This
                  Expanded(
                    child: channel != null
                        ? _buildPortraitDetails(channel, relatedChannels)
                        : const Center(
                            child: CircularProgressIndicator(color: AppColors.liveRed),
                          ),
                  ),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildVideoSurface(
    PlayerViewState state,
    PlayerNotifier notifier,
    List<Channel> channels,
    bool isLandscape,
  ) {
    return GestureDetector(
      onTap: notifier.toggleControls,
      onDoubleTap: notifier.toggleMute,
      onVerticalDragEnd: (details) {
        if (state.isLocked) return;
        // Channel Zapping (Vertical swipe like TikTok/Shorts to switch live channels)
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -400) {
          // Swiped Up -> Next Channel
          notifier.zapChannel(channels, 1);
        } else if (velocity > 400) {
          // Swiped Down -> Previous Channel
          notifier.zapChannel(channels, -1);
        }
      },
      onVerticalDragUpdate: (details) {
        if (state.isLocked) return;
        final screenWidth = MediaQuery.of(context).size.width;
        final isRightSide = details.globalPosition.dx > screenWidth / 2;
        final delta = -details.primaryDelta! / 200.0;
        if (isRightSide) {
          notifier.setVolume(state.volume + delta);
        } else {
          notifier.setBrightness(state.brightness + delta);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player or Radio/Audio-Only Mode
          if (state.isAudioOnly)
            Container(
              color: AppColors.cinemaBlack,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.darkCard,
                        border: Border.all(color: AppColors.neonCyan.withOpacity(0.5), width: 2),
                      ),
                      child: const Icon(Icons.radio_rounded, size: 64, color: AppColors.neonCyan),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.currentChannel?.name ?? 'Live Audio',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Radio / Background Audio Mode (Screen Saver)',
                      style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            Video(
              controller: notifier.videoController,
              fit: state.aspectRatio == PlayerAspectRatio.fill ? BoxFit.cover : BoxFit.contain,
              controls: NoVideoControls,
            ),
          // Brightness Overlay (when not in audio-only)
          if (!state.isAudioOnly)
            IgnorePointer(
              child: Container(
                color: Colors.black.withOpacity(1.0 - state.brightness),
              ),
            ),
          // Buffering Indicator
          if (state.isBuffering && state.errorMessage == null)
            const Center(
              child: CircularProgressIndicator(color: AppColors.liveRed),
            ),
          // Auto-failover Status Toast
          if (state.statusMessage != null)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.neonCyan.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neonCyan),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        state.statusMessage!,
                        style: const TextStyle(color: AppColors.neonCyan, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // User Discovery: Floating Swipe Up/Down Gesture Hint Pill
          if (_showSwipeHint && !state.isLocked && state.errorMessage == null)
            Positioned(
              right: 16,
              top: 70,
              child: AnimatedOpacity(
                opacity: _showSwipeHint ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.neonCyan.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.swap_vert_rounded, size: 16, color: AppColors.neonCyan),
                      SizedBox(width: 4),
                      Text(
                        'Swipe ↕ to Zap TV',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Error State
          if (state.errorMessage != null)
            _buildErrorOverlay(state, notifier),
          // On-Screen Controls Overlay
          if (state.showControls && state.errorMessage == null)
            _buildControlsOverlay(state, notifier, channels, isLandscape),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay(
    PlayerViewState state,
    PlayerNotifier notifier,
    List<Channel> channels,
    bool isLandscape,
  ) {
    final ch = state.currentChannel;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x99000000),
            Colors.transparent,
            Color(0xCC000000),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 28),
                  tooltip: 'Minimize',
                  onPressed: () {
                    if (_isFullscreen) {
                      _toggleFullscreen();
                    } else {
                      notifier.minimizePlayer();
                      context.pop();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  tooltip: 'Close Stream',
                  onPressed: () {
                    notifier.closePlayer();
                    if (_isFullscreen) {
                      _toggleFullscreen();
                    }
                    context.pop();
                  },
                ),
                if (ch != null) ...[
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ch.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Source ${state.currentStreamIndex + 1} of ${ch.streams.length}',
                          style: const TextStyle(color: AppColors.neonCyan, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
                // Radio / Audio-Only Mode toggle
                IconButton(
                  icon: Icon(
                    state.isAudioOnly ? Icons.videocam_rounded : Icons.radio_rounded,
                    color: state.isAudioOnly ? AppColors.neonCyan : Colors.white,
                  ),
                  tooltip: state.isAudioOnly ? 'Switch to Video' : 'Radio / Audio-Only Mode',
                  onPressed: notifier.toggleAudioOnly,
                ),
                // Lock toggle
                IconButton(
                  icon: Icon(
                    state.isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                    color: state.isLocked ? AppColors.neonCyan : Colors.white,
                  ),
                  onPressed: notifier.toggleLock,
                ),
                // Sleep Timer
                IconButton(
                  icon: Icon(
                    Icons.timer_outlined,
                    color: state.sleepTimerMinutes > 0 ? AppColors.neonCyan : Colors.white,
                  ),
                  onPressed: () => _showSleepTimerDialog(notifier),
                ),
                // Aspect Ratio
                IconButton(
                  icon: const Icon(Icons.aspect_ratio_rounded, color: Colors.white),
                  onPressed: notifier.cycleAspectRatio,
                ),
              ],
            ),
          ),
          // Middle Bar: Zap Left / Play-Pause / Zap Right
          if (!state.isLocked)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                  onPressed: () => notifier.zapChannel(channels, -1),
                ),
                const SizedBox(width: 24),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.liveRed,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    iconSize: 44,
                    icon: Icon(
                      state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                    onPressed: notifier.togglePlayPause,
                  ),
                ),
                const SizedBox(width: 24),
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                  onPressed: () => notifier.zapChannel(channels, 1),
                ),
              ],
            ),
          // Bottom Bar: Source Selector / Mute / Fullscreen
          if (!state.isLocked)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Quality / Source picker chip
                  InkWell(
                    onTap: () => _showSourceSelector(state, notifier),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.neonCyan.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.settings_outlined, size: 14, color: AppColors.neonCyan),
                          const SizedBox(width: 6),
                          Text(
                            _getCurrentQualityLabel(state),
                            style: const TextStyle(
                              color: AppColors.neonCyan,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Multi-Language Audio / Subtitles Switcher
                  if (state.audioTracks.isNotEmpty || state.subtitleTracks.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.subtitles_outlined, color: Colors.white),
                      tooltip: 'Audio & Subtitles',
                      onPressed: () => _showTrackSelector(state, notifier),
                    ),
                  // Mute toggle
                  IconButton(
                    icon: Icon(
                      state.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                      color: Colors.white,
                    ),
                    onPressed: notifier.toggleMute,
                  ),
                  // Fullscreen toggle
                  IconButton(
                    icon: Icon(
                      isLandscape ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                      color: Colors.white,
                    ),
                    onPressed: _toggleFullscreen,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorOverlay(PlayerViewState state, PlayerNotifier notifier) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          // Close / Back button in top-left so user is never stuck
          Positioned(
            top: 0,
            left: 0,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
                  tooltip: 'Go Back',
                  onPressed: () {
                    notifier.closePlayer();
                    if (_isFullscreen) _toggleFullscreen();
                    context.pop();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 28),
                  tooltip: 'Minimize',
                  onPressed: () {
                    if (_isFullscreen) _toggleFullscreen();
                    notifier.minimizePlayer();
                    context.pop();
                  },
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.liveRed),
                const SizedBox(height: 12),
                Text(
                  state.errorMessage ?? 'Playback Error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'The broadcast server is temporarily down or offline.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: notifier.retryCurrent,
                      icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                      label: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.liveRed,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showSourceSelector(state, notifier),
                      icon: const Icon(Icons.tune_rounded, size: 16, color: Colors.white),
                      label: const Text('Try Another Source', style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.darkBorder),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitDetails(Channel channel, List<Channel> related) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (channel.countryFlag.isNotEmpty) channel.countryFlag,
                      if (channel.countryName.isNotEmpty) channel.countryName,
                      if (channel.network != null) channel.network,
                    ].join(' • '),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.share_rounded, color: Colors.white),
                  onPressed: () {
                    Share.share('Watch ${channel.name} live on Airwave! airwave://channel/${channel.id}');
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Live Program Guide (EPG Timeline & Remind Me)
        _buildEpgScheduleCard(channel),
        const SizedBox(height: 16),
        const Divider(color: AppColors.darkBorder),
        const SizedBox(height: 12),
        // More like this
        const Text(
          'More Like This',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: related.length,
          itemBuilder: (context, index) {
            final rel = related[index];
            return ChannelCard(
              channel: rel,
              onTap: () {
                ref.read(playerControllerProvider.notifier).loadChannel(rel);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEpgScheduleCard(Channel channel) {
    final now = DateTime.now();
    final hour = now.hour;
    final currentSlot = '${hour.toString().padLeft(2, '0')}:00 - ${(hour + 1).toString().padLeft(2, '0')}:00';
    final nextSlot = '${(hour + 1).toString().padLeft(2, '0')}:00 - ${(hour + 2).toString().padLeft(2, '0')}:00';

    final category = channel.categories.isNotEmpty ? channel.categories.first : 'Live';
    final currentShow = '${channel.name} $category Broadcast';
    final upcomingShow = '${channel.name} Prime Time Special';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.neonCyan),
              const SizedBox(width: 6),
              const Text(
                'LIVE TV GUIDE (EPG)',
                style: TextStyle(
                  color: AppColors.neonCyan,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.liveRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'NOW PLAYING',
                  style: TextStyle(color: AppColors.liveRed, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            currentShow,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            currentSlot,
            style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
          ),
          const SizedBox(height: 8),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (now.minute / 60.0).clamp(0.05, 0.95),
              backgroundColor: AppColors.darkBorder,
              color: AppColors.neonCyan,
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.darkBorder),
          const SizedBox(height: 10),
          // Up Next
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('UP NEXT', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                      upcomingShow,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Text(nextSlot, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11)),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Reminder set for $upcomingShow!'),
                      backgroundColor: AppColors.darkCard,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_active_outlined, size: 14, color: AppColors.neonCyan),
                label: const Text('Remind', style: TextStyle(color: AppColors.neonCyan, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.neonCyan),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrentQualityLabel(PlayerViewState state) {
    final ch = state.currentChannel;
    if (ch == null || ch.streams.isEmpty) return 'Auto';
    final s = ch.streams[state.currentStreamIndex];
    return s.quality ?? (s.height > 0 ? '${s.height}p' : 'Source ${state.currentStreamIndex + 1}');
  }

  void _showSourceSelector(PlayerViewState state, PlayerNotifier notifier) {
    final ch = state.currentChannel;
    if (ch == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Stream Source',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 12),
              ...List.generate(ch.streams.length, (idx) {
                final s = ch.streams[idx];
                final isSelected = idx == state.currentStreamIndex;
                return ListTile(
                  dense: true,
                  leading: Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                    color: isSelected ? AppColors.neonCyan : AppColors.textSecondaryDark,
                  ),
                  title: Text(
                    s.title ?? 'Source #${idx + 1}',
                    style: TextStyle(
                      color: isSelected ? AppColors.neonCyan : Colors.white,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    s.labels.join(', '),
                    style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11),
                  ),
                  trailing: Text(
                    s.quality ?? (s.height > 0 ? '${s.height}p' : ''),
                    style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    notifier.switchStream(idx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSleepTimerDialog(PlayerNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.darkCard,
          title: const Text('Sleep Timer', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...[15, 30, 45, 60].map((mins) {
                return ListTile(
                  title: Text('$mins Minutes', style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(ctx);
                    notifier.setSleepTimer(mins);
                  },
                );
              }),
              ListTile(
                title: const Text('Turn Off Timer', style: TextStyle(color: AppColors.liveRed)),
                onTap: () {
                  Navigator.pop(ctx);
                  notifier.setSleepTimer(0);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTrackSelector(PlayerViewState state, PlayerNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Audio & Sound Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 12),
              // Audio Equalizer Presets (Feature #5)
              const Text(
                'Sound Equalizer Mode',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.neonCyan),
              ),
              const SizedBox(height: 4),
              Row(
                children: AudioPreset.values.map((preset) {
                  final isSel = state.audioPreset == preset;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        preset == AudioPreset.standard
                            ? 'Standard'
                            : (preset == AudioPreset.vocalBoost ? '🗣️ Vocal Boost' : '🎵 Bass Boost'),
                        style: TextStyle(
                          color: isSel ? Colors.black : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      selected: isSel,
                      selectedColor: AppColors.neonCyan,
                      backgroundColor: AppColors.darkCard,
                      onSelected: (_) {
                        notifier.setAudioPreset(preset);
                        Navigator.pop(ctx);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              if (state.audioTracks.isNotEmpty) ...[
                const Text(
                  'Audio Language Track',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.neonCyan),
                ),
                ...List.generate(state.audioTracks.length, (idx) {
                  final track = state.audioTracks[idx];
                  final isSelected = state.selectedAudioTrack == track;
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                      color: isSelected ? AppColors.neonCyan : AppColors.textSecondaryDark,
                    ),
                    title: Text(track, style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      notifier.selectAudioTrack(idx);
                      Navigator.pop(ctx);
                    },
                  );
                }),
                const SizedBox(height: 12),
              ],
              if (state.subtitleTracks.isNotEmpty) ...[
                const Text(
                  'Subtitles',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.neonCyan),
                ),
                ListTile(
                  dense: true,
                  leading: Icon(
                    state.selectedSubtitleTrack == null ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                    color: state.selectedSubtitleTrack == null ? AppColors.neonCyan : AppColors.textSecondaryDark,
                  ),
                  title: const Text('Off', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    notifier.selectSubtitleTrack(-1);
                    Navigator.pop(ctx);
                  },
                ),
                ...List.generate(state.subtitleTracks.length, (idx) {
                  final track = state.subtitleTracks[idx];
                  final isSelected = state.selectedSubtitleTrack == track;
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                      color: isSelected ? AppColors.neonCyan : AppColors.textSecondaryDark,
                    ),
                    title: Text(track, style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      notifier.selectSubtitleTrack(idx);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}
