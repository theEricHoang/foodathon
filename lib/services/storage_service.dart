import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(String path, File file) {
    // Uploads the file and returns the download URL string.
    return _storage.ref(path).putFile(file).then((snapshot) => snapshot.ref.getDownloadURL());
  }

  Future<String> uploadBytes(String path, Uint8List bytes, {String? contentType}) {
    // For cases where the caller has in-memory bytes rather than a 'File'. Should set the metadata with the provided content type. Returns the download URL string.
    final metadata = contentType != null ? SettableMetadata(contentType: contentType) : null;
    return _storage.ref(path).putData(bytes, metadata).then((snapshot) => snapshot.ref.getDownloadURL());
  }

  Future<String> getDownloadUrl(String path) {
    // Returns the download URL for a file already in storage.
    return _storage.ref(path).getDownloadURL();
  }

  Future<void> deleteFile(String path) {
    // Deletes the file at the given path.
    return _storage.ref(path).delete();
  }

  Future<void> deleteFolder(String path) {
    // Lists all items under the given path and deletes each one. Used when deleting a restaurant and all its associated images.
    final ref = _storage.ref(path);

    return ref.listAll().then((result) async {
      final fileDeletes = result.items.map((file) => file.delete());
      final folderDeletes =
          result.prefixes.map((folder) => deleteFolder(folder.fullPath));

      await Future.wait([
        ...fileDeletes,
        ...folderDeletes,
      ]);
    });
  }
}