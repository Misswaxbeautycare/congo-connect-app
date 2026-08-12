import 'package:flutter/material.dart';

class LegalNoticePage extends StatelessWidget {
  const LegalNoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mentions légales')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            'Mentions légales',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _Section(
            title: 'Éditeur de l\'application',
            body:
                'Congo Connect est édité par Miss Nyunge Digital Services, entreprise individuelle basée en Belgique.\nContact : contact@missnyungedigitalservices.com',
          ),
          _Section(
            title: 'Hébergement',
            body:
                'Les données de l\'application (comptes, boutiques, annonces, photos) sont hébergées par Supabase Inc. Les paiements sont traités par Stripe, Inc.',
          ),
          _Section(
            title: 'Protection des données (RGPD)',
            body:
                'Conformément au Règlement Général sur la Protection des Données (RGPD), tout utilisateur dispose d\'un droit d\'accès, de rectification, de suppression et d\'opposition concernant ses données personnelles. Pour exercer ces droits, contacte-nous à l\'adresse ci-dessus. Le détail du traitement des données est disponible dans la Politique de confidentialité.',
          ),
          _Section(
            title: 'Cookies et traceurs',
            body:
                'L\'application ne dépose pas de cookies publicitaires tiers. Seules les données strictement nécessaires au fonctionnement (connexion, préférences) sont conservées.',
          ),
          _Section(
            title: 'Propriété intellectuelle',
            body:
                'Le nom "Congo Connect", le logo et l\'interface de l\'application sont la propriété de Miss Nyunge Digital Services. Le contenu publié par les utilisateurs (photos, descriptions) reste leur propriété.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(fontSize: 13.5, height: 1.5)),
        ],
      ),
    );
  }
}
