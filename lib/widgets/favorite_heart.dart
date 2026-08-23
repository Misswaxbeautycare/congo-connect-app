import 'package:flutter/material.dart';
import '../main.dart';
import '../services/favorite_service.dart';
import 'login_page.dart';

/// Bouton cœur façon Leboncoin, superposable en overlay sur une carte.
/// Gère lui-même son état (chargement initial + toggle).
class FavoriteHeart extends StatefulWidget {
  final String itemType; // 'shop' | 'property'
  final String itemId;
  final double size;

  const FavoriteHeart({
    super.key,
    required this.itemType,
    required this.itemId,
    this.size = 20,
  });

  @override
  State<FavoriteHeart> createState() => _FavoriteHeartState();
}

class _FavoriteHeartState extends State<FavoriteHeart> {
  bool _isFavorite = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final fav = await FavoriteService.isFavorite(widget.itemType, widget.itemId);
    if (mounted) setState(() {
      _isFavorite = fav;
      _loading = false;
    });
  }

  Future<void> _toggle() async {
    if (supabase.auth.currentUser == null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }
    setState(() => _isFavorite = !_isFavorite);
    await FavoriteService.toggleFavorite(widget.itemType, widget.itemId, _isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _toggle,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Colors.black38,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: _isFavorite ? const Color(0xFFE53935) : Colors.white,
          size: widget.size,
        ),
      ),
    );
  }
}
