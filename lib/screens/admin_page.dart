import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/shop.dart';
import '../models/ad_request.dart';
import '../models/community_listing.dart';
import '../services/shop_service.dart';
import '../services/advertisement_service.dart';
import '../services/notification_service.dart';
import '../services/community_listing_service.dart';
import '../models/property.dart';
import '../services/property_service.dart';
import 'manage_users_tab.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Shop>> _pendingShopsFuture;
  late Future<List<AdRequest>> _pendingAdsFuture;
  late Future<List<Shop>> _allShopsFuture;
  late Future<List<CommunityListing>> _allListingsFuture;
  late Future<List<Property>> _pendingPropertiesFuture;
  late Future<_Stats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _load();
  }

  void _load() {
    _pendingShopsFuture = ShopService.getPendingShops();
    _pendingAdsFuture = AdvertisementService.getPendingAdRequests();
    _allShopsFuture = ShopService.getAllShopsForAdmin();
    _allListingsFuture = CommunityListingService.getAllListingsForAdmin();
    _pendingPropertiesFuture = PropertyService.getPendingProperties();
    _statsFuture = _loadStats();
  }

  Future<_Stats> _loadStats() async {
    final results = await Future.wait([
      ShopService.countShops(),
      ShopService.countShops(status: 'approved'),
      ShopService.countShops(status: 'pending'),
      CommunityListingService.countListings(type: 'don'),
      CommunityListingService.countListings(type: 'troc'),
      AdvertisementService.getPendingAdRequests(),
    ]);
    return _Stats(
      totalShops: results[0] as int,
      approvedShops: results[1] as int,
      pendingShops: results[2] as int,
      dons: results[3] as int,
      trocs: results[4] as int,
      pendingAds: (results[5] as List).length,
    );
  }

  Future<void> _refresh() async {
    setState(_load);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Statistiques'),
            Tab(text: 'À valider'),
            Tab(text: 'Boutiques'),
            Tab(text: 'Dons/Troc'),
            Tab(text: 'Publicités'),
            Tab(text: 'Immobilier'),
            Tab(text: 'Utilisateurs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StatsTab(future: _statsFuture),
          _PendingShopsTab(future: _pendingShopsFuture, onChanged: _refresh),
          _AllShopsTab(future: _allShopsFuture, onChanged: _refresh),
          _AllListingsTab(future: _allListingsFuture, onChanged: _refresh),
          _PendingAdsTab(future: _pendingAdsFuture, onChanged: _refresh),
          _PendingPropertiesTab(future: _pendingPropertiesFuture, onChanged: _refresh),
          const ManageUsersTab(),
        ],
      ),
    );
  }
}

class _PendingPropertiesTab extends StatelessWidget {
  final Future<List<Property>> future;
  final VoidCallback onChanged;

  const _PendingPropertiesTab({required this.future, required this.onChanged});

  Future<void> _act(BuildContext context, Property property, String status) async {
    await PropertyService.setPropertyStatus(property.id, status);
    onChanged();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(status == 'approved' ? 'Bien validé' : 'Bien rejeté')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Property>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final properties = snapshot.data ?? [];
        if (properties.isEmpty) {
          return const Center(child: Text('Aucun bien en attente.', style: TextStyle(color: Colors.black54)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: properties.length,
          itemBuilder: (context, i) {
            final p = properties[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    if (p.propertyType != null)
                      Text(p.propertyType!, style: const TextStyle(color: Colors.black54, fontSize: 12.5)),
                    if (p.price != null)
                      Text('Prix : ${p.price!.toStringAsFixed(0)} € (${p.priceUnit})', style: const TextStyle(fontSize: 12.5)),
                    if (p.rooms != null)
                      Text('Chambres : ${p.rooms}', style: const TextStyle(fontSize: 12.5)),
                    if (p.address != null) Text('Adresse : ${p.address}', style: const TextStyle(fontSize: 12.5)),
                    if (p.phone != null) Text('Tél : ${p.phone}', style: const TextStyle(fontSize: 12.5)),
                    Text('${p.photos.length} photo(s)', style: const TextStyle(fontSize: 12.5)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _act(context, p, 'rejected'),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Rejeter'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => _act(context, p, 'approved'),
                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2E8B57)),
                            child: const Text('Valider'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Stats {
  final int totalShops;
  final int approvedShops;
  final int pendingShops;
  final int dons;
  final int trocs;
  final int pendingAds;

  _Stats({
    required this.totalShops,
    required this.approvedShops,
    required this.pendingShops,
    required this.dons,
    required this.trocs,
    required this.pendingAds,
  });
}

class _StatsTab extends StatelessWidget {
  final Future<_Stats> future;
  const _StatsTab({required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Stats>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur : ${snapshot.error}'));
        }
        final s = snapshot.data!;
        final cards = [
          _StatCard(label: 'Boutiques au total', value: s.totalShops, color: const Color(0xFF0057B8), icon: Icons.storefront_outlined),
          _StatCard(label: 'Boutiques approuvées', value: s.approvedShops, color: const Color(0xFF2E8B57), icon: Icons.verified_outlined),
          _StatCard(label: 'Boutiques en attente', value: s.pendingShops, color: Colors.orange, icon: Icons.hourglass_empty),
          _StatCard(label: 'Dons actifs', value: s.dons, color: Colors.green, icon: Icons.volunteer_activism_outlined),
          _StatCard(label: 'Troc actifs', value: s.trocs, color: Colors.deepOrange, icon: Icons.swap_horiz),
          _StatCard(label: 'Publicités en attente', value: s.pendingAds, color: Colors.purple, icon: Icons.campaign_outlined),
        ];
        return GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: cards,
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color),
          Text('$value', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
        ],
      ),
    );
  }
}

class _PendingShopsTab extends StatelessWidget {
  final Future<List<Shop>> future;
  final VoidCallback onChanged;

  const _PendingShopsTab({required this.future, required this.onChanged});

  Future<void> _act(BuildContext context, Shop shop, String status) async {
    await ShopService.setShopVerification(shop.id, status);
    if (shop.ownerId != null) {
      await NotificationService.notifyUser(
        userId: shop.ownerId!,
        title: status == 'verified' ? 'Boutique validée ✅' : 'Boutique rejetée',
        body: status == 'verified'
            ? 'Ta boutique "${shop.name}" est maintenant visible dans l\'application !'
            : 'Ta boutique "${shop.name}" n\'a pas été validée. Contacte-nous pour en savoir plus.',
      );
    }
    onChanged();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(status == 'verified' ? 'Boutique validée' : 'Boutique rejetée')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Shop>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final shops = snapshot.data ?? [];
        if (shops.isEmpty) {
          return const Center(child: Text('Aucune boutique en attente.', style: TextStyle(color: Colors.black54)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: shops.length,
          itemBuilder: (context, i) {
            final shop = shops[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('${shop.category}${shop.subcategory != null ? " · ${shop.subcategory}" : ""}',
                        style: const TextStyle(color: Colors.black54, fontSize: 12.5)),
                    if (shop.bio != null && shop.bio!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(shop.bio!, style: const TextStyle(fontSize: 12.5)),
                      ),
                    if (shop.phone != null) Text('Tél : ${shop.phone}', style: const TextStyle(fontSize: 12.5)),
                    if (shop.email != null) Text('Email : ${shop.email}', style: const TextStyle(fontSize: 12.5)),
                    if (shop.address != null) Text('Adresse : ${shop.address}', style: const TextStyle(fontSize: 12.5)),
                    if (shop.stockQuantity != null)
                      Text('Stock : ${shop.stockQuantity}', style: const TextStyle(fontSize: 12.5)),
                    if (shop.paymentMethod != null)
                      Text('Paiement accepté : ${shop.paymentMethod}', style: const TextStyle(fontSize: 12.5)),
                    Text(
                      shop.acceptsAppointments ? 'Accepte les rendez-vous' : "N'accepte pas les rendez-vous",
                      style: const TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic),
                    ),
                    if (shop.certificationDocumentUrl != null) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            child: InteractiveViewer(
                              child: Image.network(shop.certificationDocumentUrl!),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(shop.certificationDocumentUrl!,
                                  width: 44, height: 44, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 8),
                            const Text('Document de vérification (toucher pour agrandir)',
                                style: TextStyle(fontSize: 12.5, color: Color(0xFF0057B8))),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _act(context, shop, 'rejected'),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Rejeter'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => _act(context, shop, 'verified'),
                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2E8B57)),
                            child: const Text('Valider'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AllShopsTab extends StatelessWidget {
  final Future<List<Shop>> future;
  final VoidCallback onChanged;

  const _AllShopsTab({required this.future, required this.onChanged});

  Future<void> _confirmDelete(BuildContext context, Shop shop) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette boutique ?'),
        content: Text('"${shop.name}" sera définitivement supprimée.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ShopService.adminDeleteShop(shop.id);
      onChanged();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Boutique supprimée')));
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'verified':
        return const Color(0xFF2E8B57);
      case 'pending':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Shop>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur : ${snapshot.error}'));
        }
        final shops = snapshot.data ?? [];
        if (shops.isEmpty) {
          return const Center(child: Text('Aucune boutique.', style: TextStyle(color: Colors.black54)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: shops.length,
          itemBuilder: (context, i) {
            final shop = shops[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _statusColor(shop.verificationStatus).withOpacity(0.15),
                  child: Icon(Icons.storefront_outlined, color: _statusColor(shop.verificationStatus), size: 20),
                ),
                title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  '${shop.category}${shop.subcategory != null ? " · ${shop.subcategory}" : ""}\nStatut : ${shop.verificationStatus}',
                  style: const TextStyle(fontSize: 12.5),
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        shop.isPremium ? Icons.star : Icons.star_border,
                        color: shop.isPremium ? const Color(0xFFF39C12) : Colors.grey,
                      ),
                      tooltip: shop.isPremium ? 'Retirer Premium' : 'Passer Premium',
                      onPressed: () async {
                        await ShopService.setShopPremium(shop.id, !shop.isPremium);
                        onChanged();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDelete(context, shop),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AllListingsTab extends StatelessWidget {
  final Future<List<CommunityListing>> future;
  final VoidCallback onChanged;

  const _AllListingsTab({required this.future, required this.onChanged});

  Future<void> _confirmDelete(BuildContext context, CommunityListing item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette annonce ?'),
        content: Text('"${item.title}" sera définitivement supprimée.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await CommunityListingService.deleteListing(item.id);
      onChanged();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Annonce supprimée')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CommunityListing>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur : ${snapshot.error}'));
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('Aucune annonce.', style: TextStyle(color: Colors.black54)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Icon(
                  item.type == 'don' ? Icons.volunteer_activism_outlined : Icons.swap_horiz,
                  color: item.type == 'don' ? Colors.green : Colors.deepOrange,
                ),
                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  '${item.type == 'don' ? 'Don' : 'Troc'}${item.price != null ? " · ${item.price!.toStringAsFixed(0)} FC" : ""} · ${item.status}',
                  style: const TextStyle(fontSize: 12.5),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context, item),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PendingAdsTab extends StatelessWidget {
  final Future<List<AdRequest>> future;
  final VoidCallback onChanged;

  const _PendingAdsTab({required this.future, required this.onChanged});

  Future<void> _approve(BuildContext context, AdRequest req) async {
    try {
      await AdvertisementService.approveAdRequest(req);
      onChanged();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publicité publiée !')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  Future<void> _reject(BuildContext context, AdRequest req) async {
    await AdvertisementService.rejectAdRequest(req.id);
    onChanged();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demande rejetée')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AdRequest>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final ads = snapshot.data ?? [];
        if (ads.isEmpty) {
          return const Center(child: Text('Aucune demande en attente.', style: TextStyle(color: Colors.black54)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ads.length,
          itemBuilder: (context, i) {
            final ad = ads[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ad.imageUrl != null && ad.imageUrl!.isNotEmpty)
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(imageUrl: ad.imageUrl!, fit: BoxFit.cover),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ad.businessName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('Tél : ${ad.contactPhone}', style: const TextStyle(fontSize: 12.5)),
                        if (ad.description != null && ad.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(ad.description!, style: const TextStyle(fontSize: 13)),
                          ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _reject(context, ad),
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Rejeter'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                onPressed: () => _approve(context, ad),
                                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0057B8)),
                                child: const Text('Publier'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
