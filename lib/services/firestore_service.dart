import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String docId,
  ) async {
    final doc = await _firestore.collection(collection).doc(docId).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    }
    return null;
  }

  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) {
    return _firestore.collection(collection).doc(docId).set(data);
  }

  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) {
    return _firestore.collection(collection).doc(docId).update(data);
  }

  Future<void> deleteDocument(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).delete();
  }

  Future<List<Map<String, dynamic>>> getCollection(String collection) {
    return _firestore.collection(collection).get().then((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<List<Map<String, dynamic>>> queryCollection(
    String collection, {
    required String field,
    required dynamic value,
  }) {
    return _firestore
        .collection(collection)
        .where(field, isEqualTo: value)
        .get()
        .then((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  Stream<Map<String, dynamic>?> streamDocument(
    String collection,
    String docId,
  ) {
    return _firestore.collection(collection).doc(docId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        data['id'] = snapshot.id;
        return data;
      }
      return null;
    });
  }

  Stream<List<Map<String, dynamic>>> streamCollection(
    String collection, {
    String? field,
    dynamic value,
    bool isNull = false,
  }) {
    Query query = _firestore.collection(collection);

    if (field != null && isNull) {
      query = query.where(field, isNull: true);
    } else if (field != null && value != null) {
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

  Future<void> setSubcollectionDocument(
    String collection,
    String docId,
    String subcollection,
    String subDocId,
    Map<String, dynamic> data,
  ) {
    return _firestore
        .collection(collection)
        .doc(docId)
        .collection(subcollection)
        .doc(subDocId)
        .set(data);
  }

  Future<List<Map<String, dynamic>>> getSubcollection(
    String collection,
    String docId,
    String subcollection,
  ) {
    return _firestore
        .collection(collection)
        .doc(docId)
        .collection(subcollection)
        .get()
        .then((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  DocumentReference docRef(String collection, String docId) {
    return _firestore.collection(collection).doc(docId);
  }

  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) handler,
  ) {
    return _firestore.runTransaction(handler);
  }
}
