import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/payment_links.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  Future<void> _openPayment(BuildContext context) async {
    final uri = Uri.parse(PaymentLinks.premiumShop);
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
      appBar: AppBar(title: const Text('Boutique Premium')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.workspace_premium, color: Color(0xFFF39C12), size: 48),
            const SizedBox(height: 16),
            const Text(
              'Mets ta boutique en avant',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const _Benefit(text: 'Ta boutique apparaît en premier dans sa catégorie'),
            const _Benefit(text: 'Badge "Premium" visible sur ton profil'),
            const _Benefit(text: 'Plus de photos et de visibilité auprès des clients'),
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
                  backgroundColor: const Color(0xFFF39C12),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.lock_outline),
                label: const Text('Payer et devenir Premium'),
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
          const Icon(Icons.check_circle, color: Color(0xFF2E8B57), size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
