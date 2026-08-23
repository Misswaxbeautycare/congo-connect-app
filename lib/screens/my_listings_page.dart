import 'package:flutter/material.dart';
import '../main.dart';
import '../models/shop.dart';
import '../models/community_listing.dart';
import '../services/shop_service.dart';
import '../services/community_listing_service.dart';
import '../services/my_listings_store.dart';
import 'shop_profile_page.dart';
import 'edit_shop_page.dart';
import 'listing_detail_page.dart';
import 'login_page.dart';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  late Future<List<Shop>> _shopsFuture;
  late Future<List<CommunityListing>> _listingsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _shopsFuture = ShopService.getMyShops();
    _listingsFuture = MyListingsStore.getListingIds()
        .then((ids) => CommunityListingService.getListingsByIds(ids));
  }

  Future<void> _refresh() async {
    setState(_load);
    await Future.wait([_shopsFuture, _listingsFuture]);
  }

  Future<void> _deleteShop(Shop shop) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette boutique ?'),
        content: Text('"${shop.name}" sera définitivement supprimée.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ShopService.deleteShop(shop.id);
      _refresh();
    }
  }

  Future<void> _deleteListing(CommunityListing item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette annonce ?'),
        content: Text('"${item.title}" sera définitivement supprimée.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await CommunityListingService.deleteListing(item.id);
      await MyListingsStore.removeListingId(item.id);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = supabase.auth.currentUser != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Mes annonces')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Mes boutiques', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            if (!isLoggedIn)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Connecte-toi pour voir tes boutiques'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ),
                ),
              )
            else
              FutureBuilder<List<Shop>>(
                future: _shopsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final shops = snapshot.data ?? [];
                  if (shops.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Tu n\'as pas encore de boutique.', style: TextStyle(color: Colors.black54)),
                    );
                  }
                  return Column(
                    children: shops.map((shop) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(shop.name),
                          subtitle: Text(_statusLabel(shop.verificationStatus)),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ShopProfilePage(shop: shop)),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Color(0xFF0057B8)),
                                onPressed: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => EditShopPage(shop: shop)),
                                  );
                                  _refresh();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _deleteShop(shop),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            const SizedBox(height: 24),
            const Text('Mes dons & annonces troc', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            FutureBuilder<List<CommunityListing>>(
              future: _listingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Aucune annonce publiée depuis cet appareil.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }
                return Column(
                  children: items.map((item) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(item.title),
                        subtitle: Text(item.type == 'don' ? 'Don' : 'Troc/Vente'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ListingDetailPage(listing: item)),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteListing(item),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'verified':
        return 'Vérifiée ✅';
      case 'rejected':
        return 'Rejetée';
      default:
        return 'En attente de validation';
    }
  }
}
