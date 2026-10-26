import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/player_controller.dart';

class MiniPlayerOverlay extends ConsumerWidget {
  const MiniPlayerOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerControllerProvider);
    final playerNotifier = ref.read(playerControllerProvider.notifier);
    final channel = playerState.currentChannel;

    // Only show mini player if a channel is active and minimized
    if (channel == null || !playerState.isMiniPlayer) {
      return const SizedBox.shrink();
    }

    return Positioned(
      right: 12,
      bottom: 72, // Position right above bottom navigation bar
      child: GestureDetector(
        onTap: () {
          playerNotifier.expandPlayer();
          context.push('/player/${channel.id}');
        },
        child: Material(
          elevation: 12,
          borderRadius: BorderRadius.circular(12),
          color: AppColors.darkCard,
          child: Container(
            width: 260,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkBorder, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                // Small Video Screen
                SizedBox(
                  width: 90,
                  height: 68,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Video(
                        controller: playerNotifier.videoController,
                        fit: BoxFit.cover,
                        controls: NoVideoControls,
                      ),
                      if (playerState.isBuffering)
                        const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.liveRed),
                          ),
                        ),
                    ],
                  ),
                ),
                // Channel Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          channel.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.liveRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'LIVE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.liveRed,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Play / Pause Button
                IconButton(
                  iconSize: 22,
                  icon: Icon(
                    playerState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                  onPressed: playerNotifier.togglePlayPause,
                ),
                // Close Button (Completely stops stream and closes audio)
                IconButton(
                  iconSize: 20,
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondaryDark),
                  onPressed: playerNotifier.closePlayer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
