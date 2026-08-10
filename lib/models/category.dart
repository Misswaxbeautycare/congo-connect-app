class ServiceCategory {
  final String id;
  final String name;
  final String module;
  final String? icon;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.module,
    this.icon,
  });
}

class AppModule {
  final String key;
  final String label;
  final String emoji;

  const AppModule({
    required this.key,
    required this.label,
    required this.emoji,
  });
}

const List<AppModule> appModules = [
  AppModule(key: 'sante', label: 'Santé', emoji: '🏥'),
  AppModule(key: 'beaute', label: 'Beauté', emoji: '💄'),
  AppModule(key: 'mode_couture', label: 'Mode & Couture', emoji: '👗'),
  AppModule(key: 'restaurants_alimentation', label: 'Restaurants & Alimentation', emoji: '🍽️'),
  AppModule(key: 'transport', label: 'Transport', emoji: '🚌'),
  AppModule(key: 'immobilier', label: 'Immobilier', emoji: '🏠'),
  AppModule(key: 'electronique_reparation', label: 'Électronique & Réparation', emoji: '📱'),
  AppModule(key: 'energie', label: 'Énergie', emoji: '🔋'),
  AppModule(key: 'eau', label: 'Eau', emoji: '💧'),
  AppModule(key: 'agriculture_elevage', label: 'Agriculture & Élevage', emoji: '🌾'),
  AppModule(key: 'mines_negoce', label: 'Mines & Négoce minier', emoji: '⛏️'),
  AppModule(key: 'artisanat', label: 'Artisanat', emoji: '🔨'),
  AppModule(key: 'finance_mobile_money', label: 'Finance & Mobile Money', emoji: '💰'),
  AppModule(key: 'education', label: 'Éducation', emoji: '📚'),
  AppModule(key: 'securite', label: 'Sécurité', emoji: '🛡️'),
  AppModule(key: 'evenementiel', label: 'Événementiel', emoji: '🎉'),
  AppModule(key: 'recrutement_emploi', label: 'Recrutement & Emploi', emoji: '💼'),
  AppModule(key: 'equipement_quincaillerie', label: 'Équipement & Quincaillerie', emoji: '🧰'),
  AppModule(key: 'grossiste_fournisseur', label: 'Grossiste / Fournisseur', emoji: '📦'),
];

/// Sous-catégories proposées pour chaque module, utilisées dans le
/// formulaire de création de boutique pour affiner la classification.
const Map<String, List<String>> moduleSubcategories = {
  'sante': ['Médecin généraliste', 'Dentiste', 'Pharmacie', 'Clinique', 'Laboratoire d\'analyses', 'Matériel médical', 'Sage-femme', 'Kinésithérapeute', 'Opticien'],
  'beaute': ['Salon de coiffure', 'Institut de beauté', 'Onglerie', 'Barbier', 'Maquilleuse', 'Spa & Massage', 'Produits cosmétiques'],
  'mode_couture': ['Couturier / Tailleur', 'Boutique de vêtements', 'Chaussures', 'Bijoux & Accessoires', 'Tissus (Wax, etc.)', 'Sacs & Maroquinerie'],
  'restaurants_alimentation': ['Restaurant', 'Fast-food', 'Traiteur', 'Boulangerie / Pâtisserie', 'Épicerie', 'Boisson & Bar', 'Livraison de repas'],
  'transport': ['Taxi / VTC', 'Bus / Minibus', 'Location de véhicule', 'Moto-taxi', 'Transport de marchandises', 'Déménagement'],
  'immobilier': ['Vente de maison/terrain', 'Location', 'Agence immobilière', 'Construction & BTP', 'Architecte'],
  'electronique_reparation': ['Vente de téléphones', 'Réparation téléphone', 'Ordinateurs', 'Électroménager', 'Accessoires électroniques'],
  'energie': ['Panneaux solaires', 'Groupe électrogène', 'Installation électrique', 'Vente de gaz'],
  'eau': ['Vente d\'eau', 'Forage & Puits', 'Traitement d\'eau', 'Livraison d\'eau'],
  'agriculture_elevage': ['Vente de produits agricoles', 'Élevage', 'Semences & Intrants', 'Matériel agricole', 'Vétérinaire'],
  'mines_negoce': ['Négoce minier', 'Équipement minier', 'Transport minier', 'Consultance minière'],
  'artisanat': ['Menuiserie', 'Sculpture', 'Poterie', 'Décoration', 'Maroquinerie artisanale'],
  'finance_mobile_money': ['Agence Mobile Money', 'Micro-finance', 'Change de devises', 'Transfert d\'argent', 'Assurance'],
  'education': ['École primaire/secondaire', 'Université / Institut', 'Cours particuliers', 'Formation professionnelle', 'Librairie scolaire', 'Garderie / Crèche'],
  'securite': ['Agence de gardiennage', 'Vidéosurveillance', 'Alarme & Sécurité', 'Serrurerie'],
  'evenementiel': ['Organisation de mariage', 'Location de salle', 'Traiteur événementiel', 'DJ / Sonorisation', 'Photographe / Vidéaste', 'Décoration événementielle'],
  'recrutement_emploi': ['Agence de recrutement', 'Offres d\'emploi', 'Formation professionnelle', 'Freelance / Services'],
  'equipement_quincaillerie': ['Quincaillerie', 'Matériaux de construction', 'Outillage', 'Peinture'],
  'grossiste_fournisseur': ['Grossiste alimentaire', 'Grossiste textile', 'Import/Export', 'Fournisseur de matériel'],
};
