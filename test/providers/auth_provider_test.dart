import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_test/flutter_test.dart';
import 'package:foodathon/models/user.dart';
import 'package:foodathon/providers/auth_provider.dart';
import 'package:foodathon/providers/user_provider.dart';
import 'package:foodathon/repositories/user_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([UserRepository, UserProvider])
import 'auth_provider_test.mocks.dart';

class MockFirebaseUser extends Mock implements User {
  final String _uid;
  MockFirebaseUser(this._uid);

  @override
  String get uid => _uid;
}

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
  late MockUserProvider mockUserProvider;
  late AuthProvider provider;

  setUp(() {
    mockRepo = MockUserRepository();
    mockUserProvider = MockUserProvider();
    provider = AuthProvider(
      userRepository: mockRepo,
      userProvider: mockUserProvider,
    );
  });

  test('initial state', () {
    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNull);
  });

  group('signIn', () {
    test('success calls setUser with returned user', () async {
      final user = _testUser();
      when(mockRepo.signIn(email: 'test@example.com', password: 'pass123'))
          .thenAnswer((_) async => user);

      await provider.signIn(email: 'test@example.com', password: 'pass123');

      verify(mockUserProvider.setUser(user)).called(1);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('failure sets errorMessage and does not call setUser', () async {
      when(mockRepo.signIn(email: 'test@example.com', password: 'wrong'))
          .thenThrow(Exception('Invalid credentials'));

      await provider.signIn(email: 'test@example.com', password: 'wrong');

      verifyNever(mockUserProvider.setUser(any));
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, contains('Invalid credentials'));
    });
  });

  group('signUp', () {
    test('success calls setUser with returned user', () async {
      final user = _testUser();
      when(mockRepo.signUp(
        email: 'test@example.com',
        password: 'pass123',
        name: 'Test User',
        role: UserRole.customer,
      )).thenAnswer((_) async => user);

      await provider.signUp(
        email: 'test@example.com',
        password: 'pass123',
        name: 'Test User',
        role: UserRole.customer,
      );

      verify(mockUserProvider.setUser(user)).called(1);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('failure sets errorMessage and does not call setUser', () async {
      when(mockRepo.signUp(
        email: 'test@example.com',
        password: 'pass123',
        name: 'Test User',
        role: UserRole.customer,
      )).thenThrow(Exception('Email already in use'));

      await provider.signUp(
        email: 'test@example.com',
        password: 'pass123',
        name: 'Test User',
        role: UserRole.customer,
      );

      verifyNever(mockUserProvider.setUser(any));
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, contains('Email already in use'));
    });
  });

  group('signOut', () {
    test('success calls clearUser', () async {
      when(mockRepo.signOut()).thenAnswer((_) async {});

      await provider.signOut();

      verify(mockUserProvider.clearUser()).called(1);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('failure sets errorMessage and does not call clearUser', () async {
      when(mockRepo.signOut()).thenThrow(Exception('Sign out failed'));

      await provider.signOut();

      verifyNever(mockUserProvider.clearUser());
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, contains('Sign out failed'));
    });
  });

  group('checkAuthState', () {
    test('with existing Firebase user and Firestore profile calls setUser',
        () async {
      final firebaseUser = MockFirebaseUser('uid1');
      final user = _testUser();
      when(mockRepo.currentUser).thenReturn(firebaseUser);
      when(mockRepo.fetchUser('uid1')).thenAnswer((_) async => user);

      await provider.checkAuthState();

      verify(mockUserProvider.setUser(user)).called(1);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('with no Firebase user does not call fetchUser or setUser', () async {
      when(mockRepo.currentUser).thenReturn(null);

      await provider.checkAuthState();

      verifyNever(mockRepo.fetchUser(any));
      verifyNever(mockUserProvider.setUser(any));
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('with Firebase user but no Firestore profile does not call setUser',
        () async {
      final firebaseUser = MockFirebaseUser('uid1');
      when(mockRepo.currentUser).thenReturn(firebaseUser);
      when(mockRepo.fetchUser('uid1')).thenAnswer((_) async => null);

      await provider.checkAuthState();

      verifyNever(mockUserProvider.setUser(any));
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('failure sets errorMessage', () async {
      final firebaseUser = MockFirebaseUser('uid1');
      when(mockRepo.currentUser).thenReturn(firebaseUser);
      when(mockRepo.fetchUser('uid1')).thenThrow(Exception('Network error'));

      await provider.checkAuthState();

      verifyNever(mockUserProvider.setUser(any));
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, contains('Network error'));
    });
  });

  test('clearError resets errorMessage', () async {
    when(mockRepo.signIn(email: 'a@b.com', password: 'x'))
        .thenThrow(Exception('error'));
    await provider.signIn(email: 'a@b.com', password: 'x');
    expect(provider.errorMessage, isNotNull);

    provider.clearError();

    expect(provider.errorMessage, isNull);
  });
}
