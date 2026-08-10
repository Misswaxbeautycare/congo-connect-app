import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/image_upload_service.dart';

/// Sélecteur de plusieurs photos (jusqu'à [maxImages]), utilisé pour les
/// annonces (dons, troc) et les boutiques. Toutes les vignettes ont la
/// même taille pour un rendu uniforme dans toute l'application.
class MultiPhotoPickerField extends StatefulWidget {
  final String folder;
  final ValueChanged<List<String>> onImagesChanged;
  final int maxImages;

  const MultiPhotoPickerField({
    super.key,
    required this.folder,
    required this.onImagesChanged,
    this.maxImages = 4,
  });

  @override
  State<MultiPhotoPickerField> createState() => _MultiPhotoPickerFieldState();
}

class _MultiPhotoPickerFieldState extends State<MultiPhotoPickerField> {
  final List<Uint8List> _previews = [];
  final List<String> _urls = [];
  bool _uploading = false;
  String? _error;

  Future<void> _pick() async {
    if (_urls.length >= widget.maxImages) return;
    final file = await ImageUploadService.pickImage();
    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() {
      _previews.add(bytes);
      _uploading = true;
      _error = null;
    });

    try {
      final url = await ImageUploadService.uploadImage(file, folder: widget.folder);
      if (url != null) {
        _urls.add(url);
        widget.onImagesChanged(List.of(_urls));
      }
    } catch (e) {
      setState(() {
        _previews.removeLast();
        _error = 'Échec de l\'envoi d\'une photo';
      });
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _remove(int index) {
    setState(() {
      _previews.removeAt(index);
      if (index < _urls.length) _urls.removeAt(index);
    });
    widget.onImagesChanged(List.of(_urls));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos (jusqu\'à ${widget.maxImages}) — ajoute plusieurs angles pour rassurer l\'acheteur',
          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (int i = 0; i < _previews.length; i++)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _previews[i],
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: InkWell(
                      onTap: () => _remove(i),
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        padding: const EdgeInsets.all(3),
                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            if (_previews.length < widget.maxImages)
              InkWell(
                onTap: _uploading ? null : _pick,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  alignment: Alignment.center,
                  child: _uploading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade500, size: 24),
                ),
              ),
          ],
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
      ],
    );
  }
}
