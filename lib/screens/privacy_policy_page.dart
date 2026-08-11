import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Politique de confidentialité')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            'Politique de confidentialité',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _Section(
            title: 'Données collectées',
            body:
                'Lors de la création d\'un compte ou d\'une boutique, nous collectons : email, mot de passe (chiffré), nom de boutique, téléphone, adresse, et les photos que tu choisis d\'ajouter. Pour les dons et annonces de troc/vente, aucun compte n\'est requis : seuls le nom, le téléphone et le lieu de remise que tu indiques sont enregistrés.',
          ),
          _Section(
            title: 'Utilisation des données',
            body:
                'Les données servent uniquement à faire fonctionner l\'application : afficher les boutiques et annonces, permettre le contact entre utilisateurs, et gérer les rendez-vous. Nous ne vendons aucune donnée à des tiers.',
          ),
          _Section(
            title: 'Stockage',
            body:
                'Les données sont hébergées via Supabase (base de données et stockage de fichiers). Les photos sont stockées dans un espace public accessible par lien direct.',
          ),
          _Section(
            title: 'Localisation',
            body:
                'L\'application n\'accède pas à ta position GPS. Les adresses affichées sont celles que tu saisis toi-même, et servent uniquement à générer un lien vers Google Maps si tu choisis de l\'ouvrir.',
          ),
          _Section(
            title: 'Suppression des données',
            body:
                'Tu peux supprimer tes boutiques et annonces à tout moment depuis "Mes annonces". Pour supprimer complètement ton compte et tes données personnelles, contacte l\'équipe de l\'application.',
          ),
          _Section(
            title: 'Paiements',
            body:
                'Les paiements (boutique Premium, publicités) sont traités par Stripe, un prestataire de paiement tiers sécurisé. Congo Connect ne stocke aucune donnée bancaire.',
          ),
          _Section(
            title: 'Contact',
            body: 'Pour toute question relative à tes données personnelles, contacte l\'équipe via les coordonnées disponibles dans l\'application.',
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
