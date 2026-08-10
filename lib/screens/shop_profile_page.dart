import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/shop.dart';
import '../widgets/location_row.dart';
import 'appointment_page.dart';

class ShopProfilePage extends StatelessWidget {
  final Shop shop;

  const ShopProfilePage({super.key, required this.shop});

  String _paymentLabel(String key) {
    const labels = {
      'especes': 'Espèces',
      'mobile_money': 'Mobile Money',
      'virement': 'Virement bancaire',
      'especes_mobile_money': 'Espèces & Mobile Money',
    };
    return labels[key] ?? key;
  }

  Future<void> _launch(BuildContext context, Uri uri) async {
    final ok = await canLaunchUrl(uri);
    if (ok) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir cette action sur cet appareil')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(shop.name, style: const TextStyle(fontSize: 16)),
              background: shop.coverUrl != null && shop.coverUrl!.isNotEmpty
                  ? CachedNetworkImage(imageUrl: shop.coverUrl!, fit: BoxFit.cover)
                  : Container(color: const Color(0xFF0057B8).withOpacity(0.15)),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            shop.name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (shop.verificationStatus == 'verified')
                          const Icon(Icons.verified, color: Color(0xFF0057B8), size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shop.subcategory?.isNotEmpty == true ? shop.subcategory! : shop.category,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 18, color: Color(0xFFF39C12)),
                        const SizedBox(width: 4),
                        Text(shop.ratingAvg.toStringAsFixed(1)),
                        const SizedBox(width: 4),
                        Text('(${shop.ratingCount} avis)', style: const TextStyle(color: Colors.black45)),
                      ],
                    ),
                    if ((shop.bio ?? shop.description)?.isNotEmpty == true) ...[
                      const SizedBox(height: 16),
                      Text(
                        shop.bio ?? shop.description!,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ],
                    if (shop.specialties.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: shop.specialties
                            .map((s) => Chip(label: Text(s, style: const TextStyle(fontSize: 12))))
                            .toList(),
                      ),
                    ],
                    if (shop.galleryPhotos.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text('Galerie', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: shop.galleryPhotos.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) => ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: shop.galleryPhotos[i],
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (shop.address != null && shop.address!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: LocationRow(location: shop.address!, fontSize: 13),
                      ),
                    if (shop.phone != null && shop.phone!.isNotEmpty)
                      _InfoRow(icon: Icons.phone_outlined, text: shop.phone!),
                    if (shop.email != null && shop.email!.isNotEmpty)
                      _InfoRow(icon: Icons.email_outlined, text: shop.email!),
                    if (shop.stockQuantity != null)
                      _InfoRow(icon: Icons.inventory_2_outlined, text: 'Stock disponible : ${shop.stockQuantity}'),
                    if (shop.paymentMethod != null && shop.paymentMethod!.isNotEmpty)
                      _InfoRow(icon: Icons.payments_outlined, text: 'Paiement : ${_paymentLabel(shop.paymentMethod!)}'),
                    const SizedBox(height: 24),
                    if (shop.phone != null && shop.phone!.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _launch(context, Uri.parse('tel:${shop.phone}')),
                          icon: const Icon(Icons.call_outlined),
                          label: const Text('Contacter'),
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                    if (shop.acceptsAppointments) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => AppointmentPage(shop: shop)),
                            );
                          },
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: const Text('Prendre rendez-vous'),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
