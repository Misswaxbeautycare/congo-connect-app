import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conditions d\'utilisation')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            'Conditions Générales d\'Utilisation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _Section(
            title: '1. Objet',
            body:
                'Congo Connect est une plateforme mettant en relation des utilisateurs proposant des services, boutiques, dons ou objets à échanger/vendre, et des personnes intéressées. L\'application n\'est pas partie aux transactions conclues entre utilisateurs.',
          ),
          _Section(
            title: '2. Responsabilité des utilisateurs',
            body:
                'Chaque utilisateur est seul responsable des informations, photos et annonces qu\'il publie, ainsi que des échanges, ventes, dons ou rendez-vous convenus avec d\'autres utilisateurs. Congo Connect ne vérifie pas systématiquement l\'exactitude des annonces ni l\'identité des utilisateurs.',
          ),
          _Section(
            title: '3. Sécurité des transactions',
            body:
                'Pour les dons et échanges, il est fortement recommandé de se rencontrer dans un lieu public. Congo Connect décline toute responsabilité en cas de litige, perte, vol ou dommage survenant lors d\'une rencontre ou d\'une transaction entre utilisateurs.',
          ),
          _Section(
            title: '4. Contenu interdit',
            body:
                'Il est interdit de publier du contenu illégal, frauduleux, offensant, ou portant atteinte aux droits d\'autrui. Congo Connect se réserve le droit de supprimer tout contenu ne respectant pas ces règles, sans préavis.',
          ),
          _Section(
            title: '5. Paiements et publicités',
            body:
                'Les boutiques Premium et les publicités sont soumises à un paiement. Les modalités de remboursement sont traitées au cas par cas, en contactant l\'équipe de l\'application.',
          ),
          _Section(
            title: '6. Modification des conditions',
            body:
                'Ces conditions peuvent être modifiées à tout moment. La poursuite de l\'utilisation de l\'application après modification vaut acceptation des nouvelles conditions.',
          ),
          _Section(
            title: '7. Contact',
            body: 'Pour toute question, contacte l\'équipe via les coordonnées disponibles dans l\'application.',
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
