/// Liens de paiement Stripe (Payment Links) utilisés dans l'app.
///
/// COMMENT LES CRÉER (dans dashboard.stripe.com) :
/// 1. Product catalog > Add product > donne un nom + un prix
/// 2. Une fois créé, clique "Create payment link"
/// 3. Active "Collect additional information > Add custom field"
///    et ajoute un champ texte "Nom de la boutique" (pour savoir qui activer)
/// 4. Copie l'URL (ex: https://buy.stripe.com/xxxxx) et colle-la ci-dessous
///
/// Après paiement, l'activation reste manuelle et volontaire :
/// va dans Supabase > Table Editor et passe le champ correspondant
/// (is_premium pour une boutique, status='active' pour une pub) à vrai.
class PaymentLinks {
  /// Lien de paiement pour qu'une boutique devienne "Premium / mise en avant".
  static const String premiumShop = 'https://buy.stripe.com/7sY3cveeH5p72FhfEgaEE0d';

  /// Lien de paiement pour une publicité / annonce sponsorisée en tête d'accueil.
  static const String advertisement = 'https://buy.stripe.com/REMPLACE_MOI_PUB';
}
