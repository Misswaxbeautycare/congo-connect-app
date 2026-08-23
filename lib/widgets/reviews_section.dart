import 'package:flutter/material.dart';
import '../main.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../screens/login_page.dart';

class ReviewsSection extends StatefulWidget {
  final String shopId;

  const ReviewsSection({super.key, required this.shopId});

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  late Future<List<Review>> _future;

  @override
  void initState() {
    super.initState();
    _future = ReviewService.getReviewsForShop(widget.shopId);
  }

  void _reload() => setState(() {
        _future = ReviewService.getReviewsForShop(widget.shopId);
      });

  Future<void> _openReviewSheet() async {
    if (supabase.auth.currentUser == null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }
    final existing = await ReviewService.getMyReview(widget.shopId);
    int rating = existing?.rating ?? 5;
    final commentController = TextEditingController(text: existing?.comment ?? '');

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(existing != null ? 'Modifier mon avis' : 'Laisser un avis',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final star = i + 1;
                        return IconButton(
                          onPressed: () => setSheetState(() => rating = star),
                          icon: Icon(
                            star <= rating ? Icons.star : Icons.star_border,
                            color: const Color(0xFFF39C12),
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Commentaire (optionnel)'),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        await ReviewService.submitReview(
                          shopId: widget.shopId,
                          rating: rating,
                          comment: commentController.text.trim(),
                        );
                        if (context.mounted) Navigator.pop(context, true);
                      },
                      child: const Text('Publier'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (submitted == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: _future,
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Avis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                TextButton.icon(
                  onPressed: _openReviewSheet,
                  icon: const Icon(Icons.star_border, size: 18),
                  label: const Text('Laisser un avis'),
                ),
              ],
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Aucun avis pour le moment. Sois le premier à en laisser un !',
                    style: TextStyle(color: Colors.black54, fontSize: 13)),
              )
            else
              ...reviews.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < r.rating ? Icons.star : Icons.star_border,
                              size: 15,
                              color: const Color(0xFFF39C12),
                            ),
                          ),
                        ),
                        if (r.comment != null && r.comment!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(r.comment!, style: const TextStyle(fontSize: 13)),
                          ),
                      ],
                    ),
                  )),
          ],
        );
      },
    );
  }
}
