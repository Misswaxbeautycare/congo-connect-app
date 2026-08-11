import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/advertisement_service.dart';
import '../widgets/photo_picker_field.dart';
import '../config/payment_links.dart';

class AdRequestPage extends StatefulWidget {
  const AdRequestPage({super.key});

  @override
  State<AdRequestPage> createState() => _AdRequestPageState();
}

class _AdRequestPageState extends State<AdRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _businessController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _imageUrl;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _businessController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _openPayment() async {
    final uri = Uri.parse(PaymentLinks.advertisement);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AdvertisementService.createAdRequest(
        businessName: _businessController.text.trim(),
        contactPhone: _phoneController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrl,
      );
      if (!mounted) return;
      // Ouvre directement le paiement Stripe après l'envoi de la demande
      await _openPayment();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande envoyée ! Finalise le paiement pour activer ta publicité.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _errorMessage = 'Une erreur est survenue : $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demander une publicité')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0057B8).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF0057B8).withOpacity(0.25)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.campaign_outlined, color: Color(0xFF0057B8), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fais la promotion de ta boutique ou de ton service en tête de l\'accueil. Remplis le formulaire, puis finalise le paiement Stripe qui s\'ouvrira automatiquement — ta pub est activée sous 24h après vérification.',
                        style: TextStyle(fontSize: 12.5, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PhotoPickerField(
                folder: 'ad_requests',
                label: 'Visuel de la publicité',
                onImageUploaded: (url) => setState(() => _imageUrl = url),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _businessController,
                decoration: const InputDecoration(labelText: 'Nom de ta boutique / entreprise'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Numéro de téléphone'),
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Téléphone requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Que veux-tu promouvoir ?'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Envoyer et payer'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
