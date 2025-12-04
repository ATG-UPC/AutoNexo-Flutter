import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/preferences_service.dart';
import 'core/ui/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar dependencias
  final di = InjectionContainer();
  di.init();

  runApp(MainApp(di: di));
}

class MainApp extends StatefulWidget {
  final InjectionContainer di;

  const MainApp({super.key, required this.di});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final PreferencesService _prefs = PreferencesService();
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final isDark = await _prefs.isDarkMode();
    if (mounted) {
      setState(() {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      });
    }
  }

  void _updateThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    _prefs.setDarkMode(mode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.di.authBloc),
        BlocProvider.value(value: widget.di.forgotPasswordCubit),
        BlocProvider.value(value: widget.di.homeCubit),
        BlocProvider.value(value: widget.di.profileCubit),
        BlocProvider.value(value: widget.di.vehiclesCubit),
      ],
      child: MaterialApp(
        title: 'AutoNexo Owner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: _themeMode,
        initialRoute: AppRouter.login,
        onGenerateRoute: AppRouter.onGenerateRoute,
        builder: (context, child) {
          // Proporcionar un callback para cambiar el tema desde cualquier parte de la app
          return ThemeModeProvider(
            updateThemeMode: _updateThemeMode,
            child: child!,
          );
        },
      ),
    );
  }
}

/// Provider para permitir cambiar el tema desde cualquier parte de la app
class ThemeModeProvider extends InheritedWidget {
  final void Function(ThemeMode) updateThemeMode;

  const ThemeModeProvider({
    super.key,
    required this.updateThemeMode,
    required super.child,
  });

  static ThemeModeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeModeProvider>();
  }

  @override
  bool updateShouldNotify(ThemeModeProvider oldWidget) {
    return updateThemeMode != oldWidget.updateThemeMode;
  }
}
