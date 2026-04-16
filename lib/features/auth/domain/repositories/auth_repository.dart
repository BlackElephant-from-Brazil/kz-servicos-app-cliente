import 'package:kz_servicos_app/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
