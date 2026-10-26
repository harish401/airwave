import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/channel.dart';

class HeroCarousel extends ConsumerStatefulWidget {
  final List<Channel> channels;
  final ValueChanged<Channel> onWatchLive;
  final ValueChanged<Channel> onDetails;

  const HeroCarousel({
    super.key,
    required this.channels,
    required this.onWatchLive,
    required this.onDetails,
  });

  @override
  ConsumerState<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends ConsumerState<HeroCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || widget.channels.isEmpty) return;
      final nextIndex = (_currentIndex + 1) % widget.channels.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.channels.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 380,
      child: Stack(
        children: [
          // Background PageView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.channels.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final channel = widget.channels[index];
              return _buildHeroSlide(channel);
            },
          ),
          // Page Indicators
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.channels.length, (index) {
                final isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 20 : 6,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.liveRed : AppColors.darkBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSlide(Channel channel) {
    final stream = channel.primaryStream;
    final qualityStr = stream?.quality ?? (stream != null && stream.height > 0 ? '${stream.height}p' : 'HD');

    return Stack(
      fit: StackFit.expand,
      children: [
        // Backdrop Image / Logo blurred backdrop
        Container(
          color: AppColors.darkSurface,
          child: channel.logoUrl != null && channel.logoUrl!.isNotEmpty
              ? Opacity(
                  opacity: 0.15,
                  child: Center(
                    child: Transform.scale(
                      scale: 2.5,
                      child: _buildImage(channel.logoUrl!),
                    ),
                  ),
                )
              : null,
        ),
        // Dark Cinema Vignette Gradient Fade
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Color(0x80080B10),
                AppColors.cinemaBlack,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Slide Content
        Positioned(
          left: 20,
          right: 20,
          bottom: 36,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.darkCard.withOpacity(0.9),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.neonCyan.withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withOpacity(0.2),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: channel.logoUrl != null
                      ? _buildImage(channel.logoUrl!)
                      : Text(
                          channel.initials,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.neonCyan,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              // Channel Name
              Text(
                channel.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              // Badges: Live, Category, Flag, Quality
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.liveRed,
                      borderRadius: BorderRadius.circular(4),
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
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (channel.countryFlag.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(channel.countryFlag, style: const TextStyle(fontSize: 14)),
                  ],
                  if (channel.categories.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      '•  ${channel.categories.first.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceHigh,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      qualityStr,
                      style: const TextStyle(
                        color: AppColors.neonCyan,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // CTA Buttons: "Watch Live" & "Details"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => widget.onWatchLive(channel),
                    icon: const Icon(Icons.play_arrow_rounded, size: 24, color: Colors.white),
                    label: const Text(
                      'Watch Live',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.liveRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 6,
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => widget.onDetails(channel),
                    icon: const Icon(Icons.info_outline_rounded, size: 20, color: Colors.white),
                    label: const Text(
                      'Details',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.darkBorder),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String url) {
    if (url.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(url, fit: BoxFit.contain);
    }
    return CachedNetworkImage(imageUrl: url, fit: BoxFit.contain);
  }
}
