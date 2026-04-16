import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kz_servicos_app/features/auth/domain/entities/app_user.dart';
import 'package:kz_servicos_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:kz_servicos_app/features/auth/domain/usecases/sign_in_with_email.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInWithEmail useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInWithEmail(mockRepository);
  });

  const clientUser = AppUser(
    id: '123',
    fullName: 'Ana Carolina',
    email: 'ana@email.com',
    role: 'client',
  );

  const providerUser = AppUser(
    id: '456',
    fullName: 'João Silva',
    email: 'joao@email.com',
    role: 'provider',
  );

  group('SignInWithEmail', () {
    test('returns AppUser when role is client', () async {
      when(() => mockRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => clientUser);

      final result = await useCase(
        email: 'ana@email.com',
        password: '123456',
      );

      expect(result, equals(clientUser));
      verify(() => mockRepository.signInWithEmail(
            email: 'ana@email.com',
            password: '123456',
          )).called(1);
    });

    test('throws NotClientException and signs out when role is not client',
        () async {
      when(() => mockRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => providerUser);
      when(() => mockRepository.signOut()).thenAnswer((_) async {});

      expect(
        () => useCase(email: 'joao@email.com', password: '123456'),
        throwsA(isA<NotClientException>()),
      );

      await Future.delayed(Duration.zero);
      verify(() => mockRepository.signOut()).called(1);
    });

    test('rethrows exception from repository', () async {
      when(() => mockRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Network error'));

      expect(
        () => useCase(email: 'test@email.com', password: '123456'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
