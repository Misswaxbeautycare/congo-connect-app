import 'package:flutter/material.dart';
import '../models/shop.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/photo_picker_field.dart';

class ManageCatalogPage extends StatefulWidget {
  final Shop shop;

  const ManageCatalogPage({super.key, required this.shop});

  @override
  State<ManageCatalogPage> createState() => _ManageCatalogPageState();
}

class _ManageCatalogPageState extends State<ManageCatalogPage> {
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ProductService.getProductsForShop(widget.shop.id);
  }

  Future<void> _deleteProduct(Product product) async {
    await ProductService.deleteProduct(product.id);
    setState(_load);
  }

  Future<void> _openAddProductSheet(int currentCount) async {
    final isPremium = widget.shop.isPremium;
    if (!isPremium && currentCount >= ProductService.freeLimit) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Limite atteinte'),
          content: const Text(
            'Les boutiques gratuites peuvent ajouter jusqu\'à 5 produits. '
            'Passe en Premium pour un catalogue illimité.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    String? photoUrl;

    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ajouter un produit',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    PhotoPickerField(
                      folder: 'products',
                      label: 'Photo du produit',
                      onImageUploaded: (url) => setSheetState(() => photoUrl = url),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nom du produit'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Prix (optionnel)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Description (optionnel)'),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) return;
                        await ProductService.addProduct(
                          shopId: widget.shop.id,
                          name: nameController.text.trim(),
                          price: double.tryParse(priceController.text.trim().replaceAll(',', '.')),
                          photoUrl: photoUrl,
                          description: descController.text.trim(),
                        );
                        if (context.mounted) Navigator.pop(context, true);
                      },
                      child: const Text('Ajouter au catalogue'),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (added == true) setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = widget.shop.isPremium;
    return Scaffold(
      appBar: AppBar(title: Text('Catalogue — ${widget.shop.name}')),
      body: FutureBuilder<List<Product>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data ?? [];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isPremium
                            ? '${products.length} produit(s) · Catalogue illimité (Premium)'
                            : '${products.length} / ${ProductService.freeLimit} produits utilisés',
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _openAddProductSheet(products.length),
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: products.isEmpty
                    ? const Center(
                        child: Text('Aucun produit pour le moment.',
                            style: TextStyle(color: Colors.black54)),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, i) {
                          final p = products[i];
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: p.photoUrl != null
                                      ? Image.network(p.photoUrl!, fit: BoxFit.cover, width: double.infinity)
                                      : Container(color: Colors.grey.shade100),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                      if (p.price != null)
                                        Text('${p.price!.toStringAsFixed(0)} €',
                                            style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                          onPressed: () => _deleteProduct(p),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
