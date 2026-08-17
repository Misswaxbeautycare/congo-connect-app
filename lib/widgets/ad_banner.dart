import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/advertisement.dart';
import '../services/advertisement_service.dart';

/// Bandeau de publicités "à la une" — cartes qui défilent automatiquement
/// et horizontalement, avec le titre en superposition et un bouton
/// "Découvrir", façon Leboncoin. Supporte les photos ET les petites
/// vidéos (lecture automatique, muette, en boucle).
/// Chaque carte correspond à une ligne ajoutée manuellement dans la table
/// `advertisements` de Supabase (pour les commerçants qui ont payé).
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  late Future<List<Advertisement>> _future;
  final PageController _pageController = PageController(viewportFraction: 0.42);
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  int _itemCount = 0;

  @override
  void initState() {
    super.initState();
    _future = AdvertisementService.getActiveAds();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll(int count) {
    if (_autoScrollTimer != null || count <= 1) return;
    _itemCount = count;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      _currentPage = (_currentPage + 1) % _itemCount;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _openAd(Advertisement ad) async {
    if (ad.linkUrl != null && ad.linkUrl!.isNotEmpty) {
      final uri = Uri.tryParse(ad.linkUrl!);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    if (ad.contactPhone != null && ad.contactPhone!.isNotEmpty) {
      final uri = Uri.parse('tel:${ad.contactPhone}');
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Advertisement>>(
      future: _future,
      builder: (context, snapshot) {
        final ads = snapshot.data ?? [];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (ads.isEmpty) return const SizedBox.shrink();

        WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll(ads.length));

        return SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _pageController,
            padEnds: false,
            itemCount: ads.length,
            onPageChanged: (i) => _currentPage = i,
            itemBuilder: (context, i) {
              final ad = ads[i];
              return Padding(
                padding: const EdgeInsets.only(left: 16, right: 4),
                child: _FeaturedCard(ad: ad, onTap: () => _openAd(ad)),
              );
            },
          ),
        );
      },
    );
  }
}

class _FeaturedCard extends StatefulWidget {
  final Advertisement ad;
  final VoidCallback onTap;

  const _FeaturedCard({required this.ad, required this.onTap});

  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.ad.isVideo) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.ad.videoUrl!))
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() {});
          _videoController!
            ..setVolume(0)
            ..setLooping(true)
            ..play();
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (ad.isVideo && _videoController != null && _videoController!.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              )
            else
              CachedNetworkImage(
                imageUrl: ad.imageUrl,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            // Dégradé sombre pour lire le texte, comme sur Leboncoin
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ad.isVideo ? 'Vidéo · Publicité' : 'Publicité',
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Découvrir',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
