import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import '../../../core/constants/app_colors.dart';
import '../../catalog/domain/models/channel.dart';
import '../../catalog/domain/models/stream_source.dart';
import '../../catalog/presentation/controllers/catalog_controller.dart';
import '../../catalog/presentation/widgets/channel_card.dart';
import '../../player/presentation/controllers/player_controller.dart';

class MyListView extends ConsumerStatefulWidget {
  const MyListView({super.key});

  @override
  ConsumerState<MyListView> createState() => _MyListViewState();
}

class _MyListViewState extends ConsumerState<MyListView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _customNameCtrl = TextEditingController();
  final _customUrlCtrl = TextEditingController();
  bool _isExtracting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customNameCtrl.dispose();
    _customUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoritesAsync = ref.watch(favoritesNotifierProvider);
    final historyAsync = ref.watch(historyNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Library',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.liveRed,
          labelColor: AppColors.liveRed,
          unselectedLabelColor: AppColors.textSecondaryDark,
          tabs: const [
            Tab(text: 'My List'),
            Tab(text: 'History'),
            Tab(text: 'Custom M3U'),
          ],
        ),
        actions: [
          if (_tabController.index == 1)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.textSecondaryDark),
              tooltip: 'Clear History',
              onPressed: () {
                ref.read(historyNotifierProvider.notifier).clearAll();
              },
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Favorites Tab
          favoritesAsync.when(
            data: (favs) {
              if (favs.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: 'Your list is empty',
                  subtitle: 'Save channels to your list to quickly watch them anytime.',
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: favs.length,
                itemBuilder: (context, index) {
                  final ch = favs[index];
                  return Dismissible(
                    key: Key(ch.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: AppColors.liveRed,
                      child: const Icon(Icons.delete_rounded, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      ref.read(favoritesNotifierProvider.notifier).toggleFavorite(ch.id);
                    },
                    child: ChannelCard(
                      channel: ch,
                      onTap: () => context.push('/player/${ch.id}'),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.liveRed)),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
          // History Tab
          historyAsync.when(
            data: (hist) {
              if (hist.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.history_rounded,
                  title: 'No watch history yet',
                  subtitle: 'Channels you play will appear here for fast resuming.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: hist.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.darkBorder),
                itemBuilder: (context, index) {
                  final ch = hist[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.darkSurface,
                      child: Text(
                        ch.initials,
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(ch.name, style: const TextStyle(color: AppColors.textPrimaryDark)),
                    subtitle: Text(
                      ch.categories.join(' • '),
                      style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                    ),
                    trailing: const Icon(Icons.play_arrow_rounded, color: AppColors.liveRed),
                    onTap: () => context.push('/player/${ch.id}'),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.liveRed)),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
          // Custom M3U / M3U8 Playlist Tab (Feature #2)
          _buildCustomM3uTab(),
        ],
      ),
    );
  }

  Widget _buildCustomM3uTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.add_link_rounded, color: AppColors.neonCyan),
                    SizedBox(width: 8),
                    Text(
                      'Play Any M3U8 / IPTV Stream',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Paste your custom live stream link (.m3u8, .ts) or any YouTube video link to play with Ad-Free playback & background audio support.',
                  style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _customNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Channel / Video Title (Optional)',
                    hintText: 'e.g. My News / Podcast',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _customUrlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Stream URL or YouTube Link',
                    hintText: 'https://youtube.com/watch?v=... or .m3u8',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 16),
                if (_isExtracting)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.liveRed.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.liveRed.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.liveRed),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Extracting Ad-Free YouTube Stream...',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () async {
                      final input = _customUrlCtrl.text.trim();
                      if (input.isEmpty || !input.startsWith('http')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid HTTP/HTTPS URL or YouTube link')),
                        );
                        return;
                      }

                      final name = _customNameCtrl.text.trim().isEmpty ? 'Stream' : _customNameCtrl.text.trim();
                      final isYouTube = input.contains('youtube.com') || input.contains('youtu.be');

                      if (isYouTube) {
                        setState(() => _isExtracting = true);

                        try {
                          final ytExplode = yt.YoutubeExplode();
                          final video = await ytExplode.videos.get(input);
                          final manifest = await ytExplode.videos.streamsClient.getManifest(video.id);

                          final streamSources = <StreamSource>[];

                          // Best Video+Audio muxed stream (Audio + Video interleaved together)
                          if (manifest.muxed.isNotEmpty) {
                            final bestMuxed = manifest.muxed.withHighestBitrate();
                            streamSources.add(
                              StreamSource(
                                url: bestMuxed.url.toString(),
                                channel: 'youtube',
                                title: 'YouTube Video (${bestMuxed.videoQuality.name})',
                                quality: bestMuxed.videoQuality.name,
                                userAgent: 'NONE', // Special token so player doesn't inject mobile Safari header
                              ),
                            );
                          }

                          // Best High Quality Audio-Only stream (ideal for background listening / podcast)
                          if (manifest.audioOnly.isNotEmpty) {
                            final bestAudio = manifest.audioOnly.withHighestBitrate();
                            streamSources.add(
                              StreamSource(
                                url: bestAudio.url.toString(),
                                channel: 'youtube',
                                title: 'YouTube Audio-Only (${bestAudio.bitrate})',
                                quality: 'Audio',
                                userAgent: 'NONE',
                              ),
                            );
                          }

                          ytExplode.close();

                          if (!mounted) return;
                          setState(() => _isExtracting = false);

                          if (streamSources.isEmpty) {
                            throw Exception('No playable stream found for this YouTube video.');
                          }

                          final ytChannel = Channel(
                            id: 'yt_${video.id.value}',
                            name: video.title,
                            logoUrl: video.thumbnails.highResUrl,
                            streams: streamSources,
                          );

                          ref.read(playerControllerProvider.notifier).loadChannel(ytChannel);
                          context.push('/player/${ytChannel.id}');
                        } catch (e) {
                          if (mounted) {
                            setState(() => _isExtracting = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to extract YouTube stream: $e')),
                            );
                          }
                        }
                      } else {
                        // Standard M3U8 / Live TV stream
                        final customChannel = Channel(
                          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          streams: [StreamSource(url: input, channel: 'custom')],
                        );
                        ref.read(playerControllerProvider.notifier).loadChannel(customChannel);
                        context.push('/player/${customChannel.id}');
                      }
                    },
                    icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white),
                    label: const Text('Play Stream / YouTube Video', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.liveRed,
                      minimumSize: const Size.fromHeight(44),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Supported Formats & Links:',
            style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            '• 🎬 YouTube Video Links (Ad-Free + Background Audio)\n• 📺 HLS (.m3u8) Live TV Streams\n• ⚡ Transport Streams (.ts) & Direct Media URLs\n• 📻 Online Web Radio Streams',
            style: TextStyle(color: AppColors.textTertiaryDark, fontSize: 12, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.textTertiaryDark),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondaryDark),
            ),
          ],
        ),
      ),
    );
  }
}
