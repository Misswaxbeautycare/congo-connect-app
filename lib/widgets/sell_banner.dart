import 'package:flutter/material.dart';
import '../main.dart';
import '../screens/create_shop_page.dart';
import '../screens/login_page.dart';
import '../screens/create_listing_page.dart';
import '../screens/ad_request_page.dart';

/// Bandeau incitatif coloré "C'est le moment de vendre / Déposer une
/// annonce", inspiré de Leboncoin. Au tap, propose de choisir le type
/// d'annonce à publier (boutique, don ou troc/vente).
class SellBanner extends StatelessWidget {
  const SellBanner({super.key});

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Que veux-tu déposer ?',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.storefront_outlined, color: Color(0xFF0057B8)),
                  title: const Text('Créer ma boutique'),
                  subtitle: const Text('Vends tes produits ou services durablement'),
                  onTap: () {
                    Navigator.of(context).pop();
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
                ListTile(
                  leading: const Icon(Icons.swap_horiz, color: Color(0xFFE8531D)),
                  title: const Text('Troc & Vente rapide'),
                  subtitle: const Text('Vends ou échange un objet, sans compte'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CreateListingPage(type: 'troc')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.volunteer_activism_outlined, color: Color(0xFF2E8B57)),
                  title: const Text('Faire un don'),
                  subtitle: const Text('Donne un objet gratuitement, sans compte'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CreateListingPage(type: 'don')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.campaign_outlined, color: Color(0xFFF39C12)),
                  title: const Text('Demander votre publicité'),
                  subtitle: const Text('Souscris à une publicité pour mettre tes produits à la une'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdRequestPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0057B8), Color(0xFF2E8BE0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            const Text(
              "C'est le moment de vendre",
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _showOptions(context),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE8531D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Déposer une annonce', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
