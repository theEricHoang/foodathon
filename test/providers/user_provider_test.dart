import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:foodathon/models/user.dart';
import 'package:foodathon/providers/user_provider.dart';
import 'package:foodathon/repositories/user_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([UserRepository])
import 'user_provider_test.mocks.dart';

UserModel _testUser({
  String id = 'uid1',
  String name = 'Test User',
  String email = 'test@example.com',
}) {
  return UserModel(
    id: id,
    name: name,
    email: email,
    role: UserRole.customer,
    createdAt: DateTime(2026),
  );
}

void main() {
  late MockUserRepository mockRepo;
  late UserProvider provider;

  setUp(() {
    mockRepo = MockUserRepository();
    when(mockRepo.streamUser(any)).thenAnswer((_) => const Stream.empty());
    provider = UserProvider(userRepository: mockRepo);
  });

  tearDown(() {
    provider.dispose();
  });

  test('initial state', () {
    expect(provider.currentUser, isNull);
    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNull);
    expect(provider.hasUser, isFalse);
  });

  test('setUser sets currentUser and starts stream', () {
    final user = _testUser();
    provider.setUser(user);

    expect(provider.currentUser, equals(user));
    expect(provider.hasUser, isTrue);
    expect(provider.errorMessage, isNull);
    verify(mockRepo.streamUser('uid1')).called(1);
  });

  test('clearUser resets all state and cancels stream', () {
    final user = _testUser();
    provider.setUser(user);
    provider.clearUser();

    expect(provider.currentUser, isNull);
    expect(provider.hasUser, isFalse);
    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNull);
  });

  test('fetchUser success sets currentUser', () async {
    final user = _testUser();
    when(mockRepo.fetchUser('uid1')).thenAnswer((_) async => user);

    await provider.fetchUser('uid1');

    expect(provider.currentUser, equals(user));
    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNull);
    verify(mockRepo.streamUser('uid1')).called(1);
  });

  test('fetchUser failure sets errorMessage', () async {
    when(mockRepo.fetchUser('uid1')).thenThrow(Exception('Network error'));

    await provider.fetchUser('uid1');

    expect(provider.currentUser, isNull);
    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, contains('Network error'));
  });

  test('fetchUser returns null — no error, currentUser null', () async {
    when(mockRepo.fetchUser('uid1')).thenAnswer((_) async => null);

    await provider.fetchUser('uid1');

    expect(provider.currentUser, isNull);
    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNull);
  });

  test('updateUser success — isLoading transitions, no error', () async {
    final user = _testUser();
    provider.setUser(user);
    when(
      mockRepo.updateUser(uid: 'uid1', name: 'New Name', email: null),
    ).thenAnswer((_) async {});

    await provider.updateUser(name: 'New Name');

    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNull);
    verify(mockRepo.updateUser(uid: 'uid1', name: 'New Name', email: null))
        .called(1);
  });

  test('updateUser failure sets errorMessage', () async {
    final user = _testUser();
    provider.setUser(user);
    when(
      mockRepo.updateUser(uid: 'uid1', name: 'New Name', email: null),
    ).thenThrow(Exception('Update failed'));

    await provider.updateUser(name: 'New Name');

    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, contains('Update failed'));
  });

  test('updateUser with no current user — early return, no repo call', () async {
    await provider.updateUser(name: 'New Name');

    verifyNever(
      mockRepo.updateUser(uid: anyNamed('uid'), name: anyNamed('name'), email: anyNamed('email')),
    );
  });

  test('clearError resets errorMessage', () async {
    when(mockRepo.fetchUser('uid1')).thenThrow(Exception('error'));
    await provider.fetchUser('uid1');
    expect(provider.errorMessage, isNotNull);

    provider.clearError();

    expect(provider.errorMessage, isNull);
  });

  test('stream updates currentUser when new value emitted', () async {
    final controller = StreamController<UserModel?>();
    when(mockRepo.streamUser('uid1')).thenAnswer((_) => controller.stream);

    final user1 = _testUser(name: 'First');
    provider.setUser(user1);

    final user2 = _testUser(name: 'Updated');
    controller.add(user2);
    await Future<void>.delayed(Duration.zero);

    expect(provider.currentUser?.name, equals('Updated'));

    await controller.close();
  });

  test('dispose cancels subscription without error', () {
    final localRepo = MockUserRepository();
    final controller = StreamController<UserModel?>();
    when(localRepo.streamUser('uid1')).thenAnswer((_) => controller.stream);

    final localProvider = UserProvider(userRepository: localRepo);
    localProvider.setUser(_testUser());
    localProvider.dispose();

    expect(controller.hasListener, isFalse);
    controller.close();
  });
}
