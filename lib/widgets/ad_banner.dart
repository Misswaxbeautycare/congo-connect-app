import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/advertisement.dart';
import '../services/advertisement_service.dart';

/// Bandeau de publicités "à la une" — cartes qui défilent horizontalement
/// avec le titre en superposition et un bouton "Découvrir", façon Leboncoin.
/// Chaque carte correspond à une ligne ajoutée manuellement dans la table
/// `advertisements` de Supabase (pour les commerçants qui ont payé).
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  late Future<List<Advertisement>> _future;

  @override
  void initState() {
    super.initState();
    _future = AdvertisementService.getActiveAds();
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

        return SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: ads.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final ad = ads[i];
              return _FeaturedCard(ad: ad, onTap: () => _openAd(ad));
            },
          ),
        );
      },
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Advertisement ad;
  final VoidCallback onTap;

  const _FeaturedCard({required this.ad, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 150,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          fit: StackFit.expand,
          children: [
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
                child: const Text('Publicité', style: TextStyle(color: Colors.white, fontSize: 9)),
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
