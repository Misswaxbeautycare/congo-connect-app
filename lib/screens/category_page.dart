import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../main.dart';
import '../models/category.dart';
import '../models/shop.dart';
import '../services/shop_service.dart';
import '../widgets/pulsing_action_button.dart';
import 'shop_profile_page.dart';
import 'create_shop_page.dart';
import 'login_page.dart';

class CategoryPage extends StatefulWidget {
  final String moduleKey;

  const CategoryPage({super.key, required this.moduleKey});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<Shop>> _shopsFuture;

  AppModule get _module => appModules.firstWhere(
        (m) => m.key == widget.moduleKey,
        orElse: () => AppModule(key: widget.moduleKey, label: widget.moduleKey, emoji: '📦'),
      );

  @override
  void initState() {
    super.initState();
    _shopsFuture = ShopService.getShopsByCategory(widget.moduleKey);
  }

  Future<void> _refresh() async {
    setState(() {
      _shopsFuture = ShopService.getShopsByCategory(widget.moduleKey);
    });
    await _shopsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_module.emoji}  ${_module.label}'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Shop>>(
          future: _shopsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(child: Text('Erreur : ${snapshot.error}')),
                ],
              );
            }
            final shops = snapshot.data ?? [];
            if (shops.isEmpty) {
              return ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  Icon(Icons.storefront_outlined, size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'Aucune boutique dans "${_module.label}" pour le moment.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sois le premier à ajouter ta boutique !',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black38, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: PulsingActionButton(
                      icon: Icons.add_business_outlined,
                      label: 'Créer ma boutique ici',
                      onPressed: () {
                        if (supabase.auth.currentUser != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CreateShopPage(initialCategory: widget.moduleKey),
                            ),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          );
                        }
                      },
                    ),
                  ),
                ],
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemCount: shops.length,
              itemBuilder: (context, index) {
                final shop = shops[index];
                return _CategoryShopCard(
                  shop: shop,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ShopProfilePage(shop: shop)),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CategoryShopCard extends StatelessWidget {
  final Shop shop;
  final VoidCallback onTap;

  const _CategoryShopCard({required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: shop.coverUrl != null && shop.coverUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: shop.coverUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  if (shop.subcategory != null && shop.subcategory!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      shop.subcategory!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.black45),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Color(0xFFF39C12)),
                      const SizedBox(width: 2),
                      Text(
                        shop.ratingAvg.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${shop.ratingCount})',
                        style: const TextStyle(fontSize: 11, color: Colors.black38),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF0057B8).withOpacity(0.08),
      alignment: Alignment.center,
      child: const Icon(Icons.storefront, color: Color(0xFF0057B8), size: 28),
    );
  }
}
