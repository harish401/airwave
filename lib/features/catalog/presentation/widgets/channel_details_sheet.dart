import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/channel.dart';
import '../controllers/catalog_controller.dart';

class ChannelDetailsSheet extends ConsumerWidget {
  final Channel channel;
  final ValueChanged<Channel> onPlay;

  const ChannelDetailsSheet({
    super.key,
    required this.channel,
    required this.onPlay,
  });

  static Future<void> show(BuildContext context, Channel channel, ValueChanged<Channel> onPlay) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChannelDetailsSheet(channel: channel, onPlay: onPlay),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesNotifierProvider);
    final isFav = favoritesAsync.maybeWhen(
      data: (favs) => favs.any((f) => f.id == channel.id),
      orElse: () => false,
    );

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.darkBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Channel Header: Logo, Name, Network
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                padding: const EdgeInsets.all(8),
                child: Center(child: _buildLogo(channel.logoUrl, channel.initials)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      style: const TextStyle(
                        fontSize: 20,
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
            ],
          ),
          const SizedBox(height: 16),
          // Categories & Languages Chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...channel.categories.map((c) => _buildChip(c.toUpperCase(), AppColors.neonCyan)),
              ...channel.languages.map((l) => _buildChip(l.toUpperCase(), AppColors.gold)),
              if (channel.launched != null)
                _buildChip('Launched ${channel.launched}', AppColors.textSecondaryDark),
            ],
          ),
          const SizedBox(height: 20),
          // Action Buttons: Watch Now, My List, Share, Website
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onPlay(channel);
                  },
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                  label: const Text(
                    'Watch Now',
                    style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.liveRed,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Favorite Toggle
              IconButton.filledTonal(
                onPressed: () {
                  ref.read(favoritesNotifierProvider.notifier).toggleFavorite(channel.id);
                },
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? AppColors.liveRed : AppColors.textPrimaryDark,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.darkSurface,
                  padding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(width: 8),
              // Share
              IconButton.filledTonal(
                onPressed: () {
                  Share.share(
                    'Watch ${channel.name} live on Airwave! airwave://channel/${channel.id}',
                    subject: 'Watch ${channel.name} on Airwave',
                  );
                },
                icon: const Icon(Icons.share_rounded, color: AppColors.textPrimaryDark),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.darkSurface,
                  padding: const EdgeInsets.all(12),
                ),
              ),
              // Website Link
              if (channel.website != null && channel.website!.isNotEmpty) ...[
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () async {
                    final uri = Uri.tryParse(channel.website!);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.language_rounded, color: AppColors.neonCyan),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.darkSurface,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          // Stream Sources Breakdown
          Text(
            'Available Stream Sources (${channel.streams.length})',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: channel.streams.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.darkBorder),
              itemBuilder: (context, index) {
                final s = channel.streams[index];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.darkSurface,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(fontSize: 11, color: AppColors.neonCyan),
                    ),
                  ),
                  title: Text(
                    s.title ?? (s.quality != null ? 'Stream (${s.quality})' : 'Stream #${index + 1}'),
                    style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 13),
                  ),
                  subtitle: Text(
                    s.labels.isNotEmpty ? s.labels.join(', ') : (s.isGeoBlocked ? 'Geo-blocked' : 'Global 24/7'),
                    style: TextStyle(
                      color: s.isGeoBlocked ? AppColors.liveRed : AppColors.textSecondaryDark,
                      fontSize: 11,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceHigh,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      s.quality ?? (s.height > 0 ? '${s.height}p' : 'Auto'),
                      style: const TextStyle(color: AppColors.neonCyan, fontSize: 11),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildLogo(String? url, String initials) {
    if (url == null || url.isEmpty) {
      return Text(
        initials,
        style: const TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.w800),
      );
    }
    if (url.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(url, fit: BoxFit.contain);
    }
    return CachedNetworkImage(imageUrl: url, fit: BoxFit.contain);
  }
}
