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
  AppModule(key: 'beaute', label: 'Beauté', emoji: '💇'),
  AppModule(key: 'restaurant', label: 'Restaurants', emoji: '🍽️'),
  AppModule(key: 'hebergement', label: 'Hébergement', emoji: '🏨'),
  AppModule(key: 'transport', label: 'Transport', emoji: '🚌'),
  AppModule(key: 'immobilier', label: 'Immobilier', emoji: '🏠'),
  AppModule(key: 'artisan', label: 'Artisans', emoji: '🔧'),
];
