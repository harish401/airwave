import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/channel.dart';
import '../../domain/models/filter_state.dart';

class ChannelCard extends StatelessWidget {
  final Channel channel;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final ViewMode viewMode;

  const ChannelCard({
    super.key,
    required this.channel,
    required this.onTap,
    this.onLongPress,
    this.viewMode = ViewMode.grid,
  });

  @override
  Widget build(BuildContext context) {
    if (viewMode == ViewMode.list) {
      return _buildListTile(context);
    } else if (viewMode == ViewMode.compact) {
      return _buildCompactTile(context);
    }
    return _buildGridCard(context);
  }

  Widget _buildGridCard(BuildContext context) {
    final stream = channel.primaryStream;
    final qualityStr = stream?.quality ?? (stream != null && stream.height > 0 ? '${stream.height}p' : null);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkBorder, width: 0.8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top: Logo container with Live Tag
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppColors.darkSurface,
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: _buildLogo(channel.logoUrl, channel.initials),
                    ),
                  ),
                  // LIVE Tag
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.liveRed,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.liveRedGlow,
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 6, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Quality Badge
                  if (qualityStr != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.darkBorder, width: 0.5),
                        ),
                        child: Text(
                          qualityStr,
                          style: const TextStyle(
                            color: AppColors.neonCyan,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Bottom Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        // Live Health indicator dot
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(
                            color: channel.streams.isNotEmpty
                                ? ((stream?.height ?? 0) >= 720 ? const Color(0xFF00E676) : const Color(0xFFFFB300))
                                : const Color(0xFF757575),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (channel.streams.isNotEmpty ? const Color(0xFF00E676) : Colors.transparent).withOpacity(0.5),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            channel.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (channel.countryFlag.isNotEmpty) ...[
                          Text(
                            channel.countryFlag,
                            style: const TextStyle(fontSize: 11),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            channel.categories.isNotEmpty
                                ? channel.categories.first
                                : (channel.network ?? channel.countryCode),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(6),
        child: Center(
          child: _buildLogo(channel.logoUrl, channel.initials),
        ),
      ),
      title: Text(
        channel.name,
        style: const TextStyle(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Row(
        children: [
          if (channel.countryFlag.isNotEmpty) ...[
            Text(channel.countryFlag),
            const SizedBox(width: 6),
          ],
          Text(
            channel.categories.join(' • '),
            style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
          ),
        ],
      ),
      trailing: const Icon(Icons.play_circle_fill, color: AppColors.liveRed),
    );
  }

  Widget _buildCompactTile(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.darkBorder, width: 0.5),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: _buildLogo(channel.logoUrl, channel.initials),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                channel.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(String? url, String initials) {
    if (url == null || url.isEmpty) {
      return _buildInitialsTile(initials);
    }

    if (url.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        url,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => _buildInitialsTile(initials),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      errorWidget: (_, __, ___) => _buildInitialsTile(initials),
      placeholder: (_, __) => _buildInitialsTile(initials),
    );
  }

  Widget _buildInitialsTile(String initials) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceHigh,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: AppColors.neonCyan,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
