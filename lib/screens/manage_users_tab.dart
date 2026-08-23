import 'package:flutter/material.dart';
import '../services/user_management_service.dart';

class ManageUsersTab extends StatefulWidget {
  const ManageUsersTab({super.key});

  @override
  State<ManageUsersTab> createState() => _ManageUsersTabState();
}

class _ManageUsersTabState extends State<ManageUsersTab> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = UserManagementService.getAllUsers();
  }

  Future<void> _toggleBan(Map<String, dynamic> user) async {
    final isBanned = user['is_banned'] as bool? ?? false;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isBanned ? 'Réactiver ce compte ?' : 'Suspendre ce compte ?'),
        content: Text(
          isBanned
              ? '${user['email']} pourra à nouveau se connecter.'
              : '${user['email']} sera déconnecté et ne pourra plus se connecter.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isBanned ? 'Réactiver' : 'Suspendre',
                style: TextStyle(color: isBanned ? const Color(0xFF2E8B57) : Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await UserManagementService.setBanned(user['id'] as String, !isBanned);
      setState(_load);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return const Center(child: Text('Aucun utilisateur.', style: TextStyle(color: Colors.black54)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, i) {
            final user = users[i];
            final isBanned = user['is_banned'] as bool? ?? false;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isBanned ? Colors.red.withOpacity(0.12) : Colors.grey.shade200,
                  child: Icon(
                    isBanned ? Icons.block : Icons.person_outline,
                    color: isBanned ? Colors.red : Colors.black54,
                  ),
                ),
                title: Text(user['email'] as String? ?? '—'),
                subtitle: Text(
                  '${user['shop_count']} boutique(s)${isBanned ? ' · Compte suspendu' : ''}',
                  style: TextStyle(fontSize: 12.5, color: isBanned ? Colors.red : Colors.black54),
                ),
                trailing: TextButton(
                  onPressed: () => _toggleBan(user),
                  child: Text(
                    isBanned ? 'Réactiver' : 'Suspendre',
                    style: TextStyle(color: isBanned ? const Color(0xFF2E8B57) : Colors.red),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
