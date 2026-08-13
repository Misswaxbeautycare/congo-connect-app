import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/shop.dart';
import '../models/ad_request.dart';
import '../services/shop_service.dart';
import '../services/advertisement_service.dart';
import '../services/notification_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Shop>> _pendingShopsFuture;
  late Future<List<AdRequest>> _pendingAdsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  void _load() {
    _pendingShopsFuture = ShopService.getPendingShops();
    _pendingAdsFuture = AdvertisementService.getPendingAdRequests();
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
          tabs: const [
            Tab(text: 'Boutiques'),
            Tab(text: 'Publicités'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PendingShopsTab(future: _pendingShopsFuture, onChanged: _refresh),
          _PendingAdsTab(future: _pendingAdsFuture, onChanged: _refresh),
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
                    if (shop.phone != null) Text('Tél : ${shop.phone}', style: const TextStyle(fontSize: 12.5)),
                    if (shop.address != null) Text('Adresse : ${shop.address}', style: const TextStyle(fontSize: 12.5)),
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
