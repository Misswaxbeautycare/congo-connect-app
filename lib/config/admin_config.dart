/// Configuration de l'accès administrateur.
///
/// Remplace l'adresse ci-dessous par TON email de connexion (celui que tu
/// utilises pour te connecter dans l'app). Seuls les comptes listés ici
/// pourront accéder au panneau d'administration (validation des boutiques
/// et des publicités).
class AdminConfig {
  static const List<String> adminEmails = [
    'REMPLACE_MOI@exemple.com',
  ];

  static bool isAdmin(String? email) {
    if (email == null) return false;
    return adminEmails.contains(email.toLowerCase());
  }
}
