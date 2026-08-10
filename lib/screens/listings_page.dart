import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/community_listing.dart';
import '../services/community_listing_service.dart';
import 'create_listing_page.dart';

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

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de lancer l\'appel')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isDon ? 'Dons gratuits' : 'Troc & Vente rapide')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CreateListingPage(type: widget.type)),
          );
          _refresh();
        },
        icon: const Icon(Icons.add),
        label: Text(_isDon ? 'Donner un objet' : 'Proposer'),
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
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Toutes les photos gardent la même taille/format pour un rendu uniforme
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: item.imageUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => _imagePlaceholder(),
                              )
                            : _imagePlaceholder(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                ),
                                if (item.price != null)
                                  Text(
                                    '${item.price!.toStringAsFixed(0)} FC',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFF39C12)),
                                  ),
                              ],
                            ),
                            if (item.description != null && item.description!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(item.description!, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                            ],
                            const SizedBox(height: 10),
                            if (item.pickupLocation != null && item.pickupLocation!.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.black54),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item.pickupLocation!,
                                      style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 16, color: Colors.black45),
                                const SizedBox(width: 4),
                                Text(item.contactName, style: const TextStyle(fontSize: 12.5, color: Colors.black45)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _call(item.contactPhone),
                                icon: const Icon(Icons.call_outlined, size: 18),
                                label: const Text('Contacter'),
                              ),
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
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: (_isDon ? Colors.green : Colors.orange).withOpacity(0.08),
      alignment: Alignment.center,
      child: Icon(
        _isDon ? Icons.volunteer_activism_outlined : Icons.swap_horiz,
        color: _isDon ? Colors.green : Colors.orange,
        size: 32,
      ),
    );
  }
}
