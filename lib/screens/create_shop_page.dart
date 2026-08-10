import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/shop_service.dart';

class CreateShopPage extends StatefulWidget {
  final String? initialCategory;

  const CreateShopPage({super.key, this.initialCategory});

  @override
  State<CreateShopPage> createState() => _CreateShopPageState();
}

class _CreateShopPageState extends State<CreateShopPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  late String _category;
  String? _subcategory;
  bool _acceptsAppointments = false;
  bool _isLoading = false;
  String? _errorMessage;

  final Map<String, String> _categories = {
    for (final m in appModules) m.key: m.label,
  };

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory ?? appModules.first.key;
  }

  List<String> get _subcategoryOptions => moduleSubcategories[_category] ?? const [];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ShopService.createShop(
        name: _nameController.text.trim(),
        category: _category,
        subcategory: _subcategory,
        bio: _bioController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        acceptsAppointments: _acceptsAppointments,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boutique créée ! Elle sera visible après validation.')),
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
      appBar: AppBar(title: const Text('Créer ma boutique')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Accepte les rendez-vous'),
                value: _acceptsAppointments,
                onChanged: (value) => setState(() => _acceptsAppointments = value),
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
                      child: const Text('Créer ma boutique'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
