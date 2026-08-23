import 'package:flutter/material.dart';
import '../models/shop.dart';
import '../models/property.dart';
import '../services/favorite_service.dart';
import '../services/shop_service.dart';
import '../services/property_service.dart';
import '../widgets/shop_card.dart';
import 'shop_profile_page.dart';
import 'property_detail_page.dart';
import 'properties_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<Shop>> _shopsFuture;
  late Future<List<Property>> _propertiesFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _shopsFuture = FavoriteService.getFavoriteShopIds().then(ShopService.getShopsByIds);
    _propertiesFuture = FavoriteService.getFavoritePropertyIds().then(PropertyService.getPropertiesByIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(_load);
          await Future.wait([_shopsFuture, _propertiesFuture]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Boutiques', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            FutureBuilder<List<Shop>>(
              future: _shopsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final shops = snapshot.data ?? [];
                if (shops.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Aucune boutique en favori.', style: TextStyle(color: Colors.black54)),
                  );
                }
                return SizedBox(
                  height: 170,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: shops
                        .map((shop) => ShopCard(
                              shop: shop,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => ShopProfilePage(shop: shop)),
                              ),
                            ))
                        .toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Immobilier & Airbnb', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            FutureBuilder<List<Property>>(
              future: _propertiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final properties = snapshot.data ?? [];
                if (properties.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Aucun bien en favori.', style: TextStyle(color: Colors.black54)),
                  );
                }
                return Column(
                  children: properties
                      .map((p) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(p.title),
                              subtitle: Text(p.address ?? ''),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => PropertyDetailPage(property: p)),
                              ),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
