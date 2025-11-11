import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/ui/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'core/di/injection_container.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

void main() {
  // Inicializar dependencias
  final di = InjectionContainer();
  di.init();

  runApp(MainApp(di: di));
}

class MainApp extends StatelessWidget {
  final InjectionContainer di;

  const MainApp({super.key, required this.di});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: di.authBloc..add(const AuthCheckRequested())),
        BlocProvider.value(value: di.forgotPasswordCubit),
        BlocProvider.value(value: di.homeCubit),
        BlocProvider.value(value: di.profileCubit),
      ],
      child: MaterialApp(
        title: 'AutoNexo Owner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        initialRoute: AppRouter.initial,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
