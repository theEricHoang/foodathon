import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getDocument(String collection, String docId) async {
    // Returns the document data map, or null if it doesn't exist.
    final doc = await _firestore.collection(collection).doc(docId).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    }
    return null;
  }

  Future<void> setDocument(String collection, String docId, Map<String, dynamic> data) {
    // Uses set with merge to avoid overwriting existing data.
    return _firestore.collection(collection).doc(docId).set(data, SetOptions(merge: true));
  }

  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) {
    // Uses update to only update specified fields, will fail if document doesn't exist.
    return _firestore.collection(collection).doc(docId).update(data);
  }

  Future<void> deleteDocument(String collection, String docId) {
    // Deletes the entire document.
    return _firestore.collection(collection).doc(docId).delete();
  }

  Future<List<Map<String, dynamic>>> getCollection(String collection) {
    // Returns all documents in the collection, each map includes the document ID under the key 'id'.
    return _firestore.collection(collection).get().then((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<List<Map<String, dynamic>>> queryCollection(String collection, {required String field, required dynamic value})
  // Returns documents where the specified field matches the given value, each map includes the document ID under the key 'id'.
  {
    return _firestore.collection(collection).where(field, isEqualTo: value).get().then((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Stream<Map<String, dynamic>?> streamDocument(String collection, String docId) {
    // Returns a stream that emist the document data (or null) on every change.
    return _firestore.collection(collection).doc(docId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        data['id'] = snapshot.id;
        return data;
      }
      return null;
    });
  }

  Stream<List<Map<String, dynamic>>> streamCollection(String collection, {String? field, dynamic value}) {
    // If `field` and `value` are provided, applies a `where` clause. Otherwise streams the entire collection. Each map in the list should include `'id'`.
    Query query = _firestore.collection(collection);

    if (field != null && value != null) {
      query = query.where(field, isEqualTo: value);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> setSubcollectionDocument(String collection, String docId, String subcollection, String subDocId, Map<String, dynamic> data) {
    // Writes to collection/docId/subcollection/subDocId.
    return _firestore.collection(collection).doc(docId).collection(subcollection).doc(subDocId).set(data, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getSubcollection(String collection, String docId, String subcollection) {
    // Returns all documents in the subcollection, each with 'id'.
    return _firestore.collection(collection).doc(docId).collection(subcollection).get().then((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}