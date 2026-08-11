import 'dart:async';
import 'package:flutter/material.dart';
import '../models/shop.dart';
import '../models/community_listing.dart';
import '../services/shop_service.dart';
import '../services/community_listing_service.dart';
import 'shop_profile_page.dart';
import 'listing_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Shop> _shops = [];
  List<CommunityListing> _listings = [];
  bool _loading = false;
  bool _searched = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _shops = [];
        _listings = [];
        _searched = false;
      });
      return;
    }
    setState(() => _loading = true);
    final results = await Future.wait([
      ShopService.searchShops(query),
      CommunityListingService.searchListings(query),
    ]);
    if (!mounted) return;
    setState(() {
      _shops = results[0] as List<Shop>;
      _listings = results[1] as List<CommunityListing>;
      _loading = false;
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChanged,
          decoration: const InputDecoration(
            hintText: 'Rechercher une boutique, un service, un objet...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_searched
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Tape au moins 2 lettres pour chercher parmi les boutiques, dons et annonces.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black45),
                    ),
                  ),
                )
              : (_shops.isEmpty && _listings.isEmpty)
                  ? const Center(child: Text('Aucun résultat trouvé.', style: TextStyle(color: Colors.black54)))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_shops.isNotEmpty) ...[
                          const Text('Boutiques', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ..._shops.map((shop) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const Icon(Icons.storefront_outlined, color: Color(0xFF0057B8)),
                                  title: Text(shop.name),
                                  subtitle: Text(shop.subcategory?.isNotEmpty == true ? shop.subcategory! : shop.category),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => ShopProfilePage(shop: shop)),
                                  ),
                                ),
                              )),
                          const SizedBox(height: 16),
                        ],
                        if (_listings.isNotEmpty) ...[
                          const Text('Dons & Troc', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ..._listings.map((item) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Icon(
                                    item.type == 'don' ? Icons.volunteer_activism_outlined : Icons.swap_horiz,
                                    color: item.type == 'don' ? Colors.green : Colors.orange,
                                  ),
                                  title: Text(item.title),
                                  subtitle: item.price != null ? Text('${item.price!.toStringAsFixed(0)} FC') : null,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => ListingDetailPage(listing: item)),
                                  ),
                                ),
                              )),
                        ],
                      ],
                    ),
    );
  }
}
