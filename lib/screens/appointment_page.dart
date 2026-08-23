import 'package:flutter/material.dart';
import '../main.dart';
import '../models/shop.dart';
import '../services/notification_service.dart';

class AppointmentPage extends StatefulWidget {
  final Shop shop;

  const AppointmentPage({super.key, required this.shop});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final _motifController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _appointmentMode = 'sur_place';
  bool _saving = false;

  @override
  void dispose() {
    _motifController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _submit() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisis une date et une heure')),
      );
      return;
    }
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecte-toi pour prendre rendez-vous')),
      );
      return;
    }

    setState(() => _saving = true);
    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    try {
      await supabase.from('appointments').insert({
        'shop_id': widget.shop.id,
        'client_id': user.id,
        'appointment_time': dateTime.toIso8601String(),
        'motif': _motifController.text.trim(),
        'appointment_mode': _appointmentMode,
        'status': 'pending',
      });
      if (widget.shop.ownerId != null) {
        final modeLabel = switch (_appointmentMode) {
          'telephonique' => 'téléphonique',
          'en_ligne' => 'en ligne (Meet/Zoom)',
          _ => 'sur place',
        };
        await NotificationService.notifyUser(
          userId: widget.shop.ownerId!,
          title: 'Nouvelle demande de rendez-vous 📅',
          body: 'Un client souhaite un rendez-vous $modeLabel le '
              '${dateTime.day}/${dateTime.month}/${dateTime.year} à '
              '${_selectedTime!.format(context)} pour "${_motifController.text.trim()}".',
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande de rendez-vous envoyée !')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : impossible d\'enregistrer le rendez-vous ($e)')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rendez-vous — ${widget.shop.name}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(_selectedDate == null
                ? 'Choisir une date'
                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickDate,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time),
            title: Text(_selectedTime == null
                ? 'Choisir une heure'
                : _selectedTime!.format(context)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickTime,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Type de rendez-vous', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Sur place'),
                selected: _appointmentMode == 'sur_place',
                onSelected: (_) => setState(() => _appointmentMode = 'sur_place'),
              ),
              ChoiceChip(
                label: const Text('Téléphonique'),
                selected: _appointmentMode == 'telephonique',
                onSelected: (_) => setState(() => _appointmentMode = 'telephonique'),
              ),
              ChoiceChip(
                label: const Text('En ligne (Meet/Zoom)'),
                selected: _appointmentMode == 'en_ligne',
                onSelected: (_) => setState(() => _appointmentMode = 'en_ligne'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _motifController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Motif de la visite',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _submit,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _saving
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Confirmer le rendez-vous'),
          ),
        ],
      ),
    );
  }
}
