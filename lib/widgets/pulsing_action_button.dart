import 'package:flutter/material.dart';

/// Bouton d'appel à l'action utilisé partout dans l'app (créer boutique,
/// donner un objet, proposer un troc) pour garder la même couleur, la
/// même taille, et un léger effet de pulsation qui attire l'œil.
class PulsingActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const PulsingActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  State<PulsingActionButton> createState() => _PulsingActionButtonState();
}

class _PulsingActionButtonState extends State<PulsingActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: SizedBox(
        height: 52,
        child: FilledButton.icon(
          onPressed: widget.onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0057B8),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          icon: Icon(widget.icon, size: 20),
          label: Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
