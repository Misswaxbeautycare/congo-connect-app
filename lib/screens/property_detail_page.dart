import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/property.dart';

class PropertyDetailPage extends StatelessWidget {
  final Property property;

  const PropertyDetailPage({super.key, required this.property});

  String _priceLabel() {
    if (property.price == null) return '';
    final unit = switch (property.priceUnit) {
      'mois' => '/mois',
      'vente' => '',
      _ => '/nuit',
    };
    return '${property.price!.toStringAsFixed(0)} €$unit';
  }

  Future<void> _call(BuildContext context) async {
    if (property.phone == null || property.phone!.isEmpty) return;
    final uri = Uri.parse('tel:${property.phone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de lancer l\'appel')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: property.photos.isNotEmpty
                  ? PageView(
                      children: property.photos
                          .map((url) => CachedNetworkImage(imageUrl: url, fit: BoxFit.cover))
                          .toList(),
                    )
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
                    Text(property.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    if (property.price != null)
                      Text(_priceLabel(),
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0057B8))),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        if (property.propertyType != null)
                          _Tag(icon: Icons.home_outlined, text: property.propertyType!),
                        if (property.rooms != null)
                          _Tag(icon: Icons.bed_outlined, text: '${property.rooms} chambre(s)'),
                        _Tag(
                          icon: property.isAvailable ? Icons.check_circle_outline : Icons.cancel_outlined,
                          text: property.isAvailable ? 'Disponible' : 'Indisponible',
                        ),
                      ],
                    ),
                    if (property.description != null && property.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(property.description!, style: const TextStyle(fontSize: 14, height: 1.4)),
                    ],
                    if (property.address != null && property.address!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 18, color: Colors.black54),
                          const SizedBox(width: 6),
                          Expanded(child: Text(property.address!, style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (property.phone != null && property.phone!.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _call(context),
                          icon: const Icon(Icons.call_outlined),
                          label: const Text('Contacter le propriétaire'),
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
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

class _Tag extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Tag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12.5)),
      ],
    );
  }
}
