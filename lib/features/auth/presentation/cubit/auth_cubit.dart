import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kz_servicos_app/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:kz_servicos_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required SignInWithEmail signInWithEmail})
      : _signInWithEmail = signInWithEmail,
        super(const AuthInitial());

  final SignInWithEmail _signInWithEmail;

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      emit(const AuthError('Preencha todos os campos'));
      return;
    }

    if (!_emailRegex.hasMatch(email)) {
      emit(const AuthError('Informe um e-mail válido'));
      return;
    }

    emit(const AuthLoading());

    try {
      final user = await _signInWithEmail(
        email: email,
        password: password,
      );
      emit(AuthSuccess(user));
    } on NotClientException {
      emit(const AuthError('Este aplicativo é exclusivo para clientes'));
    } on AuthException catch (e) {
      emit(AuthError(_mapAuthError(e.message)));
    } on Exception {
      emit(const AuthError('Erro ao fazer login. Tente novamente.'));
    }
  }

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'E-mail ou senha incorretos';
    }
    if (message.contains('Email not confirmed')) {
      return 'E-mail não confirmado. Verifique sua caixa de entrada.';
    }
    return 'Erro ao fazer login. Tente novamente.';
  }
}
