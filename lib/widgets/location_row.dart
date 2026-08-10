import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Affiche un lieu (texte) de façon cliquable : au tap, ouvre Google Maps
/// pour voir l'endroit en direct (recherche par nom/adresse).
class LocationRow extends StatelessWidget {
  final String location;
  final Color? iconColor;
  final double fontSize;

  const LocationRow({
    super.key,
    required this.location,
    this.iconColor,
    this.fontSize = 12.5,
  });

  Future<void> _openMap(BuildContext context) async {
    final query = Uri.encodeComponent(location);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir la carte')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openMap(context),
      borderRadius: BorderRadius.circular(6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on_outlined, size: 16, color: iconColor ?? Colors.black54),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              location,
              style: TextStyle(
                fontSize: fontSize,
                color: const Color(0xFF0057B8),
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFF0057B8),
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.map_outlined, size: 15, color: Color(0xFF0057B8)),
        ],
      ),
    );
  }
}
