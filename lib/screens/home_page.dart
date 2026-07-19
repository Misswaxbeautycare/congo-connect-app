import 'package:flutter/material.dart';
import '../main.dart';
import 'create_shop_page.dart';
import 'login_page.dart';
import '../models/shop.dart';
import '../services/shop_service.dart';
import '../widgets/category_grid.dart';
import '../widgets/shop_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Shop>> _featuredShopsFuture;

  @override
  void initState() {
    super.initState();
    _featuredShopsFuture = ShopService.getFeaturedShops();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Congo Connect',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business_outlined),
            tooltip: 'Créer ma boutique',
            onPressed: () {
              if (supabase.auth.currentUser != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateShopPage()),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _featuredShopsFuture = ShopService.getFeaturedShops();
          });
        },
        child: ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 32),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un service, une boutique...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Explorer par catégorie',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            CategoryGrid(
              onTapModule: (moduleKey) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Module sélectionné : $moduleKey')),
                );
              },
            ),
            const SizedBox(height: 28),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Recommandés près de vous',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: FutureBuilder<List<Shop>>(
                future: _featuredShopsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}'));
                  }
                  final shops = snapshot.data ?? [];
                  if (shops.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucune boutique pour le moment.\nAjoute des boutiques dans Supabase pour les voir ici.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: shops.length,
                    itemBuilder: (context, index) {
                      return ShopCard(shop: shops[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
