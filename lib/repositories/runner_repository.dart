import '../services/firestore_service.dart';
import '../models/runner.dart';
import 'package:uuid/uuid.dart';

class RunnerRepository {
  final FirestoreService _firestoreService;

  static const _collection = 'runners';

  RunnerRepository({
    required FirestoreService firestoreService,
  }) : _firestoreService = firestoreService;
  
  Future<Runner> createRunner({required String userId}) async {
    final runnerId = Uuid().v4();
    final runner = Runner(
      id: runnerId,
      userId: userId,
      isOnline: false,
      latitude: null,
      longitude: null,
    );

    await _firestoreService.setDocument(_collection, runnerId, runner.toJson());
    return runner;
  }

  Future<Runner?> fetchRunner(String runnerId) async {
    final data = await _firestoreService.getDocument(_collection, runnerId);
    if (data == null) return null;
    return Runner.fromJson(data);
  }

  Future<Runner?> fetchRunnerByUserId(String userId) async {
    final querySnapshot = await _firestoreService.queryCollection(
      _collection,
      field: 'userId',
      value: userId,
    );

    if (querySnapshot.isEmpty) return null;
    return Runner.fromJson(querySnapshot.first);
  }

  Future<void> goOnline(String runnerId) async{
    await _firestoreService.updateDocument(
      _collection,
      runnerId,
      {'isOnline': true},
    );
  }

  Future<void> goOffline(String runnerId) async {
    await _firestoreService.updateDocument(
      _collection,
      runnerId,
      {'isOnline': false},
    );
  }

  Future<void> updateLocation({required String runnerId, required double latitude, required double longitude}) async {
    await _firestoreService.updateDocument(
      _collection,
      runnerId,
      {
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  Stream<Runner?> streamRunner(String runnerId) {
    return _firestoreService.streamDocument(_collection, runnerId).map((data) {
      if (data == null) return null;
      return Runner.fromJson(data);
    });
  }

  Stream<List<Runner>> streamAvailableRunners() {
    return _firestoreService.streamCollection(
      _collection,
      field: 'isOnline',
      value: true,
    ).map((snapshot) {
      return snapshot.map((doc) => Runner.fromJson(doc)).toList();
    });
  }

  Future<void> deleteRunner(String runnerId) async {
    await _firestoreService.deleteDocument(_collection, runnerId);
  }
}