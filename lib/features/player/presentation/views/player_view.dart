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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initChannel();
    });
  }

  void _initChannel() {
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
                  // Video Surface (Top in Portrait)
                  SizedBox(
                    height: 240,
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
          // Video Player
          Video(
            controller: notifier.videoController,
            fit: state.aspectRatio == PlayerAspectRatio.fill ? BoxFit.cover : BoxFit.contain,
            controls: NoVideoControls,
          ),
          // Brightness Overlay
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
      color: Colors.black.withOpacity(0.85),
      padding: const EdgeInsets.all(24),
      child: Center(
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
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
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
            IconButton(
              icon: const Icon(Icons.share_rounded, color: Colors.white),
              onPressed: () {
                Share.share('Watch ${channel.name} live on Airwave! airwave://channel/${channel.id}');
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
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
}
