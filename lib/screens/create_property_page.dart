import 'package:flutter/material.dart';
import '../services/property_service.dart';
import '../services/image_upload_service.dart';

class CreatePropertyPage extends StatefulWidget {
  const CreatePropertyPage({super.key});

  @override
  State<CreatePropertyPage> createState() => _CreatePropertyPageState();
}

class _CreatePropertyPageState extends State<CreatePropertyPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _roomsController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  String _propertyType = 'appartement';
  String _priceUnit = 'nuit';
  final List<String> _photoUrls = [];
  bool _uploadingPhoto = false;
  bool _isLoading = false;
  String? _errorMessage;

  final Map<String, String> _propertyTypes = const {
    'appartement': 'Appartement',
    'maison': 'Maison',
    'studio': 'Studio',
    'terrain': 'Terrain',
    'chambre': 'Chambre',
    'bureau_commerce': 'Bureau / Commerce',
  };

  final Map<String, String> _priceUnits = const {
    'nuit': 'Par nuit',
    'mois': 'Par mois',
    'vente': 'Prix de vente',
  };

  Future<void> _addPhoto() async {
    if (_photoUrls.length >= 10) return;
    final file = await ImageUploadService.pickImage();
    if (file == null) return;
    setState(() => _uploadingPhoto = true);
    try {
      final url = await ImageUploadService.uploadImage(file, folder: 'properties');
      if (url != null) setState(() => _photoUrls.add(url));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec de l\'envoi de la photo')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await PropertyService.createProperty(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        propertyType: _propertyType,
        price: double.tryParse(_priceController.text.trim().replaceAll(',', '.')),
        priceUnit: _priceUnit,
        rooms: int.tryParse(_roomsController.text.trim()),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        photos: _photoUrls,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Annonce envoyée ! Elle sera visible après validation.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _errorMessage = 'Une erreur est survenue : $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _roomsController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publier un bien (Immobilier/Airbnb)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Photos (jusqu\'à 10)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._photoUrls.map((url) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(url, width: 90, height: 90, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 2, right: 2,
                                child: GestureDetector(
                                  onTap: () => setState(() => _photoUrls.remove(url)),
                                  child: const CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.black54,
                                    child: Icon(Icons.close, size: 13, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    if (_photoUrls.length < 10)
                      InkWell(
                        onTap: _uploadingPhoto ? null : _addPhoto,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 90, height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: _uploadingPhoto
                              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre de l\'annonce'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Titre requis' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _propertyType,
                decoration: const InputDecoration(labelText: 'Type de bien'),
                items: _propertyTypes.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (v) => setState(() => _propertyType = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Prix'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _priceUnit,
                      decoration: const InputDecoration(labelText: 'Unité'),
                      items: _priceUnits.entries
                          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                          .toList(),
                      onChanged: (v) => setState(() => _priceUnit = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomsController,
                decoration: const InputDecoration(labelText: 'Nombre de chambres (optionnel)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Adresse / Quartier'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Téléphone de contact'),
                keyboardType: TextInputType.phone,
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
                      child: const Text('Publier l\'annonce'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
