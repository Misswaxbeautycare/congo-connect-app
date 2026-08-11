import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/community_listing.dart';
import '../widgets/location_row.dart';

class ListingDetailPage extends StatefulWidget {
  final CommunityListing listing;

  const ListingDetailPage({super.key, required this.listing});

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  int _page = 0;

  bool get _isDon => widget.listing.type == 'don';

  Future<void> _call() async {
    final uri = Uri.parse('tel:${widget.listing.contactPhone}');
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
    final item = widget.listing;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: item.imageUrls.isEmpty
                  ? Container(
                      color: (_isDon ? Colors.green : Colors.orange).withOpacity(0.08),
                      alignment: Alignment.center,
                      child: Icon(
                        _isDon ? Icons.volunteer_activism_outlined : Icons.swap_horiz,
                        color: _isDon ? Colors.green : Colors.orange,
                        size: 48,
                      ),
                    )
                  : Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        PageView.builder(
                          itemCount: item.imageUrls.length,
                          onPageChanged: (i) => setState(() => _page = i),
                          itemBuilder: (context, i) => CachedNetworkImage(
                            imageUrl: item.imageUrls[i],
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (item.imageUrls.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                item.imageUrls.length,
                                (i) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: i == _page ? Colors.white : Colors.white54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.price != null)
                      Text(
                        '${item.price!.toStringAsFixed(0)} FC',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFF39C12)),
                      )
                    else if (_isDon)
                      const Text(
                        'GRATUIT',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E8B57)),
                      ),
                    const SizedBox(height: 6),
                    Text(item.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    if (item.description != null && item.description!.isNotEmpty) ...[
                      const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 6),
                      Text(item.description!, style: const TextStyle(fontSize: 14, height: 1.4)),
                      const SizedBox(height: 16),
                    ],
                    if (item.pickupLocation != null && item.pickupLocation!.isNotEmpty) ...[
                      const Text('Lieu de remise', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 6),
                      LocationRow(location: item.pickupLocation!, fontSize: 14),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 18, color: Colors.black54),
                        const SizedBox(width: 6),
                        Text(item.contactName, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _call,
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        icon: const Icon(Icons.call_outlined),
                        label: const Text('Contacter'),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
