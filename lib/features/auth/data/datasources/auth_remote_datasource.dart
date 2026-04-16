import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final userId = response.user?.id;
    if (userId == null) {
      throw Exception('Falha na autenticação');
    }

    final userData =
        await _client.from('users').select().eq('id', userId).single();
    return userData;
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
