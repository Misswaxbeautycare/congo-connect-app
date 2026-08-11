import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/community_listing.dart';
import '../services/community_listing_service.dart';
import '../widgets/pulsing_action_button.dart';
import 'create_listing_page.dart';
import 'listing_detail_page.dart';

class ListingsPage extends StatefulWidget {
  final String type; // 'don' ou 'troc'

  const ListingsPage({super.key, required this.type});

  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  late Future<List<CommunityListing>> _future;

  bool get _isDon => widget.type == 'don';

  @override
  void initState() {
    super.initState();
    _future = CommunityListingService.getListings(widget.type);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = CommunityListingService.getListings(widget.type);
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isDon ? 'Dons gratuits' : 'Troc & Vente rapide')),
      floatingActionButton: PulsingActionButton(
        icon: Icons.add,
        label: _isDon ? 'Donner un objet' : 'Proposer',
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CreateListingPage(type: widget.type)),
          );
          _refresh();
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<CommunityListing>>(
          future: _future,
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
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  Icon(
                    _isDon ? Icons.volunteer_activism_outlined : Icons.swap_horiz,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isDon ? 'Aucun don disponible pour le moment.' : 'Aucune annonce pour le moment.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              );
            }
            // Grille 2 colonnes façon Marketplace : image carrée, prix en gros, titre en dessous
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _MarketplaceStyleCard(
                  item: item,
                  isDon: _isDon,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ListingDetailPage(listing: item)),
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

class _MarketplaceStyleCard extends StatelessWidget {
  final CommunityListing item;
  final bool isDon;
  final VoidCallback onTap;

  const _MarketplaceStyleCard({
    required this.item,
    required this.isDon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carrée, recadrée automatiquement au centre pour un rendu net et uniforme
            AspectRatio(
              aspectRatio: 1,
              child: item.imageUrls.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrls.first,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.price != null)
                    Text(
                      '${item.price!.toStringAsFixed(0)} FC',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFF39C12)),
                    )
                  else if (isDon)
                    const Text(
                      'GRATUIT',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2E8B57)),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, color: Colors.black87),
                  ),
                  if (item.pickupLocation != null && item.pickupLocation!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: Colors.black38),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            item.pickupLocation!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10.5, color: Colors.black38),
                          ),
                        ),
                      ],
                    ),
                  ],
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
      color: (isDon ? Colors.green : Colors.orange).withOpacity(0.08),
      alignment: Alignment.center,
      child: Icon(
        isDon ? Icons.volunteer_activism_outlined : Icons.swap_horiz,
        color: isDon ? Colors.green : Colors.orange,
        size: 28,
      ),
    );
  }
}
