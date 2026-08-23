import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/property.dart';
import '../services/property_service.dart';
import 'create_property_page.dart';
import 'property_detail_page.dart';
import '../widgets/favorite_heart.dart';

class PropertiesPage extends StatefulWidget {
  const PropertiesPage({super.key});

  @override
  State<PropertiesPage> createState() => _PropertiesPageState();
}

class _PropertiesPageState extends State<PropertiesPage> {
  late Future<List<Property>> _future;

  @override
  void initState() {
    super.initState();
    _future = PropertyService.getApprovedProperties();
  }

  String _priceLabel(Property p) {
    if (p.price == null) return '';
    final unit = switch (p.priceUnit) {
      'mois' => '/mois',
      'vente' => '',
      _ => '/nuit',
    };
    return '${p.price!.toStringAsFixed(0)} €$unit';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Immobilier & Airbnb'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_home_outlined),
            tooltip: 'Publier un bien',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreatePropertyPage()),
              );
              setState(() => _future = PropertyService.getApprovedProperties());
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Property>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final properties = snapshot.data ?? [];
          if (properties.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Aucun bien disponible pour le moment.',
                    style: TextStyle(color: Colors.black54)),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: properties.length,
            itemBuilder: (context, i) {
              final p = properties[i];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PropertyDetailPage(property: p)),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            p.photos.isNotEmpty
                                ? CachedNetworkImage(imageUrl: p.photos.first, fit: BoxFit.cover)
                                : Container(color: Colors.grey.shade100),
                            if (!p.isAvailable)
                              Container(
                                color: Colors.black45,
                                alignment: Alignment.center,
                                child: const Text('Indisponible',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: FavoriteHeart(itemType: 'property', itemId: p.id, size: 16),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            if (p.rooms != null)
                              Text('${p.rooms} chambre(s)',
                                  style: const TextStyle(fontSize: 11.5, color: Colors.black54)),
                            if (p.price != null)
                              Text(_priceLabel(p),
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0057B8))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
