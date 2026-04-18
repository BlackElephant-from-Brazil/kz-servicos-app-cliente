import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kz_servicos_app/core/theme/app_theme.dart';
import 'package:kz_servicos_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kz_servicos_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kz_servicos_app/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:kz_servicos_app/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:kz_servicos_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:kz_servicos_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:kz_servicos_app/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wmlsiwjrgjygqdjtsayt.supabase.co',
    anonKey: 'sb_publishable_Uczyit6MEzgq3grhCVqmaA_vT0m5EVS',
  );

  runApp(const KzServicosApp());
}

class KzServicosApp extends StatelessWidget {
  const KzServicosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseClient = Supabase.instance.client;
    final dataSource = AuthRemoteDataSourceImpl(supabaseClient);
    final repository = AuthRepositoryImpl(dataSource);
    final signInWithEmail = SignInWithEmail(repository);
    final signUpWithEmail = SignUpWithEmail(repository);
    final authCubit = AuthCubit(
      signInWithEmail: signInWithEmail,
      signUpWithEmail: signUpWithEmail,
      repository: repository,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authCubit),
        BlocProvider(
          create: (_) => ProfileCubit(client: supabaseClient),
        ),
      ],
      child: MaterialApp.router(
        title: 'KZ Serviços',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.createRouter(authCubit),
      ),
    );
  }
}
