import 'package:flutter/material.dart';
import '../main.dart';
import 'create_shop_page.dart';
import 'login_page.dart';
import 'category_page.dart';
import 'shop_profile_page.dart';
import 'listings_page.dart';
import '../models/shop.dart';
import '../models/category.dart';
import '../services/shop_service.dart';
import '../widgets/shop_card.dart';
import '../widgets/pulsing_quick_action.dart';
import '../widgets/ad_banner.dart';
import '../widgets/sell_banner.dart';
import 'ad_request_page.dart';
import 'premium_page.dart';
import 'business_page.dart';
import 'my_listings_page.dart';
import 'search_page.dart';
import 'admin_page.dart';
import 'about_page.dart';
import '../config/admin_config.dart';
import 'notifications_page.dart';
import '../services/notification_service.dart';
import 'my_appointments_page.dart';
import 'properties_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Shop>> _featuredShopsFuture;
  late Future<int> _unreadCountFuture;

  @override
  void initState() {
    super.initState();
    _featuredShopsFuture = ShopService.getFeaturedShops();
    _unreadCountFuture = NotificationService.getUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: const Text(
                  'Catégories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: appModules.length,
                  itemBuilder: (context, index) {
                    final module = appModules[index];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0057B8).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(module.emoji, style: const TextStyle(fontSize: 20)),
                      ),
                      title: Text(module.label),
                      onTap: () {
                        Navigator.of(context).pop();
                        if (module.key == 'immobilier') {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const PropertiesPage()),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => CategoryPage(moduleKey: module.key)),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
            icon: const Icon(Icons.list_alt_outlined),
            tooltip: 'Mes annonces',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyListingsPage()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'premium') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PremiumPage()),
                );
              } else if (value == 'business') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BusinessPage()),
                );
              } else if (value == 'ad') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdRequestPage()),
                );
              } else if (value == 'my_appointments') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyAppointmentsPage()),
                );
              } else if (value == 'admin') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminPage()),
                );
              } else if (value == 'about') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'premium',
                child: ListTile(
                  leading: Icon(Icons.workspace_premium_outlined),
                  title: Text('Boutique Premium'),
                ),
              ),
              PopupMenuItem(
                value: 'business',
                child: ListTile(
                  leading: Icon(Icons.apartment),
                  title: Text('Compte Business'),
                ),
              ),
              PopupMenuItem(
                value: 'ad',
                child: ListTile(
                  leading: Icon(Icons.campaign_outlined),
                  title: Text('Demander une publicité'),
                ),
              ),
              PopupMenuItem(
                value: 'my_appointments',
                child: ListTile(
                  leading: Icon(Icons.event_note_outlined),
                  title: Text('Mes rendez-vous'),
                ),
              ),
              if (AdminConfig.isAdmin(supabase.auth.currentUser?.email))
                const PopupMenuItem(
                  value: 'admin',
                  child: ListTile(
                    leading: Icon(Icons.admin_panel_settings_outlined),
                    title: Text('Administration'),
                  ),
                ),
              const PopupMenuItem(
                value: 'about',
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('À propos'),
                ),
              ),
            ],
          ),
          FutureBuilder<int>(
            future: _unreadCountFuture,
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return IconButton(
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: const Icon(Icons.notifications_none),
                ),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationsPage()),
                  );
                  setState(() {
                    _unreadCountFuture = NotificationService.getUnreadCount();
                  });
                },
              );
            },
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
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SearchPage()),
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Rechercher un service, une boutique...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF0057B8)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SearchPage()),
                      );
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0057B8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SellBanner(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: PulsingQuickAction(
                      icon: Icons.volunteer_activism_outlined,
                      label: 'Dons gratuits',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ListingsPage(type: 'don')),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PulsingQuickAction(
                      icon: Icons.swap_horiz,
                      label: 'Troc & Vente rapide',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ListingsPage(type: 'troc')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const AdBanner(),
            const SizedBox(height: 24),
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
                      final shop = shops[index];
                      return ShopCard(
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
          ],
        ),
      ),
    );
  }
}
