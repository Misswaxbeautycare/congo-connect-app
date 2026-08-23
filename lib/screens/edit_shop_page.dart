import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/shop.dart';
import '../services/shop_service.dart';
import '../widgets/photo_picker_field.dart';

/// Reprend le même formulaire que CreateShopPage, mais pré-rempli avec les
/// données de la boutique existante, et enregistre via updateShop() au lieu
/// de createShop().
class EditShopPage extends StatefulWidget {
  final Shop shop;

  const EditShopPage({super.key, required this.shop});

  @override
  State<EditShopPage> createState() => _EditShopPageState();
}

class _EditShopPageState extends State<EditShopPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.shop.name);
  late final _bioController = TextEditingController(text: widget.shop.bio ?? '');
  late final _phoneController = TextEditingController(text: widget.shop.phone ?? '');
  late final _emailController = TextEditingController(text: widget.shop.email ?? '');
  late final _addressController = TextEditingController(text: widget.shop.address ?? '');
  late final _stockController =
      TextEditingController(text: widget.shop.stockQuantity?.toString() ?? '');

  String? _coverUrl;
  late String _category;
  String? _subcategory;
  late String _paymentMethod;
  late bool _acceptsAppointments;
  bool _isLoading = false;
  String? _errorMessage;

  final Map<String, String> _categories = {
    for (final m in appModules) m.key: m.label,
  };

  final Map<String, String> _paymentMethods = const {
    'especes': 'Espèces',
    'mobile_money': 'Mobile Money',
    'virement': 'Virement bancaire',
    'especes_mobile_money': 'Espèces & Mobile Money',
  };

  @override
  void initState() {
    super.initState();
    _coverUrl = widget.shop.coverUrl;
    _category = widget.shop.category;
    _subcategory = widget.shop.subcategory;
    _paymentMethod = widget.shop.paymentMethod ?? 'especes';
    _acceptsAppointments = widget.shop.acceptsAppointments;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  List<String> get _subcategoryOptions => moduleSubcategories[_category] ?? const [];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ShopService.updateShop(
        shopId: widget.shop.id,
        name: _nameController.text.trim(),
        category: _category,
        subcategory: _subcategory,
        bio: _bioController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        acceptsAppointments: _acceptsAppointments,
        coverUrl: _coverUrl,
        stockQuantity: int.tryParse(_stockController.text.trim()),
        paymentMethod: _paymentMethod,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Boutique mise à jour ! Elle repasse en attente de validation.'),
        ),
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
      appBar: AppBar(title: const Text('Modifier ma boutique')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              PhotoPickerField(
                folder: 'shops',
                label: 'Photo de couverture de la boutique',
                onImageUploaded: (url) => setState(() => _coverUrl = url),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom de la boutique'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Nom requis' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                items: _categories.entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (value) => setState(() {
                  _category = value!;
                  _subcategory = null;
                }),
              ),
              if (_subcategoryOptions.isNotEmpty) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _subcategory,
                  decoration: const InputDecoration(labelText: 'Sous-catégorie (optionnel)'),
                  items: _subcategoryOptions
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) => setState(() => _subcategory = value),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Adresse'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock / quantité disponible (optionnel)',
                  hintText: 'Ex : 25',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Moyen de paiement accepté'),
                items: _paymentMethods.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (value) => setState(() => _paymentMethod = value!),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Accepte les rendez-vous'),
                value: _acceptsAppointments,
                onChanged: (value) => setState(() => _acceptsAppointments = value),
              ),
              const SizedBox(height: 16),
              const Text(
                'La boutique repassera en attente de validation après modification.',
                style: TextStyle(color: Colors.black54, fontSize: 12.5),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Enregistrer les modifications'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
