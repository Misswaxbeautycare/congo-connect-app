import 'package:flutter/material.dart';
import '../services/shop_service.dart';

/// Écran pour le propriétaire d'une boutique : liste des demandes de
/// rendez-vous reçues, avec possibilité de confirmer ou annuler.
class MyAppointmentsPage extends StatefulWidget {
  const MyAppointmentsPage({super.key});

  @override
  State<MyAppointmentsPage> createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ShopService.getMyShopAppointments();
  }

  Future<void> _updateStatus(String id, String status) async {
    await ShopService.setAppointmentStatus(id, status);
    setState(_load);
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} à $h:$m';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return const Color(0xFF2E8B57);
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmé';
      case 'cancelled':
        return 'Annulé';
      default:
        return 'En attente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes rendez-vous')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final appointments = snapshot.data ?? [];
          if (appointments.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aucun rendez-vous pour le moment.',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final a = appointments[i];
              final status = a['status'] as String? ?? 'pending';
              final shopName = (a['shops'] as Map?)?['name'] as String? ?? '';
              final mode = switch (a['appointment_mode']) {
                'telephonique' => 'Téléphonique',
                'en_ligne' => 'En ligne (Meet/Zoom)',
                _ => 'Sur place',
              };
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(shopName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusColor(status).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _statusLabel(status),
                            style: TextStyle(color: _statusColor(status), fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('${_formatDate(a['appointment_time'] as String?)} · $mode'),
                    if ((a['motif'] as String?)?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(a['motif'] as String, style: const TextStyle(color: Colors.black54)),
                    ],
                    if (status == 'pending') ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _updateStatus(a['id'] as String, 'cancelled'),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Annuler'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => _updateStatus(a['id'] as String, 'confirmed'),
                              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2E8B57)),
                              child: const Text('Confirmer'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
