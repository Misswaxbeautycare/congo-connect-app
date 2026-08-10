import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/image_upload_service.dart';

/// Sélecteur de photo uniforme : même taille et même style partout
/// (boutique, don, troc). Retourne l'URL publique une fois uploadée.
class PhotoPickerField extends StatefulWidget {
  final String folder;
  final ValueChanged<String?> onImageUploaded;
  final String label;

  const PhotoPickerField({
    super.key,
    required this.folder,
    required this.onImageUploaded,
    this.label = 'Ajouter une photo',
  });

  @override
  State<PhotoPickerField> createState() => _PhotoPickerFieldState();
}

class _PhotoPickerFieldState extends State<PhotoPickerField> {
  Uint8List? _previewBytes;
  bool _uploading = false;
  String? _error;

  Future<void> _pick() async {
    final file = await ImageUploadService.pickImage();
    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() {
      _previewBytes = bytes;
      _uploading = true;
      _error = null;
    });

    try {
      final url = await ImageUploadService.uploadImage(file, folder: widget.folder);
      widget.onImageUploaded(url);
    } catch (e) {
      setState(() => _error = 'Échec de l\'envoi de la photo');
      widget.onImageUploaded(null);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _uploading ? null : _pick,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_previewBytes != null)
                  Image.memory(_previewBytes!, fit: BoxFit.cover),
                if (_uploading)
                  Container(
                    color: Colors.black26,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(color: Colors.white),
                  ),
                if (_previewBytes == null && !_uploading)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade500, size: 28),
                        const SizedBox(height: 6),
                        Text(widget.label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
      ],
    );
  }
}
