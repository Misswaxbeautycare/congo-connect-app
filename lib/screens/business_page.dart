import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/payment_links.dart';

class BusinessPage extends StatelessWidget {
  const BusinessPage({super.key});

  Future<void> _openPayment(BuildContext context) async {
    final uri = Uri.parse(PaymentLinks.business);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir la page de paiement')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compte Business')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.apartment, color: Color(0xFF0057B8), size: 48),
            const SizedBox(height: 16),
            const Text(
              'Pour grossistes, entreprises et immobilier',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Location d\'appartements, vente de parcelles et de maisons, grossistes multi-produits — une visibilité maximale sur toute l\'application.',
              style: TextStyle(fontSize: 13.5, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 16),
            const _Benefit(text: 'Mise en avant sur toute l\'application, toutes catégories confondues'),
            const _Benefit(text: 'Badge "Compte Vérifié" — renforce la confiance de tes clients'),
            const _Benefit(text: 'Galerie photo illimitée'),
            const _Benefit(text: 'Support prioritaire'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0057B8).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Après ton paiement, indique le nom exact de ta boutique — notre équipe l\'active sous 24h.',
                style: TextStyle(fontSize: 12.5, height: 1.4),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openPayment(context),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0057B8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.lock_outline),
                label: const Text('Payer et devenir Business'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final String text;
  const _Benefit({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF0057B8), size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
