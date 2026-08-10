import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

/// Service partagé pour choisir une photo depuis la galerie/caméra et
/// l'envoyer sur le bucket Supabase Storage "listings". Utilisé pour les
/// boutiques, les dons et les annonces de troc/vente, afin que toutes les
/// images de l'application soient stockées et affichées de la même façon.
class ImageUploadService {
  static const String bucket = 'listings';
  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pickImage({bool fromCamera = false}) async {
    return _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 80,
    );
  }

  static Future<String?> uploadImage(XFile file, {required String folder}) async {
    final bytes = await file.readAsBytes();
    final ext = file.path.split('.').last.toLowerCase();
    final fileName = '$folder/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await supabase.storage.from(bucket).uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(
            contentType: 'image/$ext',
            upsert: false,
          ),
        );

    return supabase.storage.from(bucket).getPublicUrl(fileName);
  }
}
