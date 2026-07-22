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
