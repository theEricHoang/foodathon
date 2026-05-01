import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(String path, File file) {
    return _storage.ref(path).putFile(file).then((snapshot) => snapshot.ref.getDownloadURL());
  }

  Future<String> uploadBytes(String path, Uint8List bytes, {String? contentType}) {
    final metadata = contentType != null ? SettableMetadata(contentType: contentType) : null;
    return _storage.ref(path).putData(bytes, metadata).then((snapshot) => snapshot.ref.getDownloadURL());
  }

  Future<String> getDownloadUrl(String path) {
    return _storage.ref(path).getDownloadURL();
  }

  Future<void> deleteFile(String path) {
    return _storage.ref(path).delete();
  }

  Future<void> deleteFolder(String path) {
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