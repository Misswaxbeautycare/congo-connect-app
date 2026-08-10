import 'package:flutter/material.dart';
import '../services/community_listing_service.dart';
import '../widgets/photo_picker_field.dart';

class CreateListingPage extends StatefulWidget {
  final String type; // 'don' ou 'troc'

  const CreateListingPage({super.key, required this.type});

  @override
  State<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  String? _imageUrl;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isDon => widget.type == 'don';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await CommunityListingService.createListing(
        type: widget.type,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrl,
        price: _isDon ? null : double.tryParse(_priceController.text.trim()),
        contactName: _nameController.text.trim(),
        contactPhone: _phoneController.text.trim(),
        pickupLocation: _locationController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isDon ? 'Ton don a été publié !' : 'Ton annonce a été publiée !')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur est survenue : $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isDon ? 'Proposer un don' : 'Proposer un troc / une vente')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_isDon ? Colors.green : Colors.orange).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (_isDon ? Colors.green : Colors.orange).withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: _isDon ? Colors.green.shade700 : Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isDon
                            ? 'Pas besoin de compte. Pour la sécurité de tous, la remise de l\'objet doit obligatoirement se faire dans un lieu public (marché, église, arrêt de bus...) — jamais à domicile avec un inconnu.'
                            : 'Pas besoin de compte. Pour la sécurité de tous, privilégie un lieu public pour l\'échange ou la remise en main propre.',
                        style: const TextStyle(fontSize: 12.5, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PhotoPickerField(
                folder: widget.type,
                label: 'Ajouter une photo de l\'objet',
                onImageUploaded: (url) => setState(() => _imageUrl = url),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: _isDon ? 'Quel objet donnes-tu ?' : 'Que proposes-tu (vente/troc) ?',
                ),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Titre requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (état, détails...)'),
                maxLines: 3,
              ),
              if (!_isDon) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Prix souhaité (optionnel, laisser vide si troc pur)',
                    hintText: 'Ex : 20000',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Ton nom'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Nom requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Ton numéro de téléphone'),
                keyboardType: TextInputType.phone,
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Téléphone requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: _isDon ? 'Lieu public de remise (obligatoire)' : 'Lieu de rencontre souhaité',
                  hintText: 'Ex : Marché central, devant l\'église Saint-...',
                ),
                validator: (value) {
                  if (_isDon && (value == null || value.trim().isEmpty)) {
                    return 'Un lieu public est obligatoire pour un don';
                  }
                  return null;
                },
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
                      child: Text(_isDon ? 'Publier le don' : 'Publier l\'annonce'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
