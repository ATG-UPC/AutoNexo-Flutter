import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/cubit/cubit.dart';
import '../../features/home/data/repositories/home_repository.dart';
import '../../features/home/presentation/cubit/cubit.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/presentation/cubit/cubit.dart';
import '../../features/vehicles/data/repositories/vehicle_repository.dart';
import '../../features/vehicles/presentation/cubit/cubit.dart';

/// Contenedor de inyección de dependencias
/// Aquí se configuran todas las dependencias de la aplicación
class InjectionContainer {
  // Singleton
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  // Repositorios
  late final AuthRepository authRepository;
  late final HomeRepository homeRepository;
  late final ProfileRepository profileRepository;
  late final VehicleRepository vehicleRepository;

  // BLoCs
  late final AuthBloc authBloc;

  // Cubits
  late final ForgotPasswordCubit forgotPasswordCubit;
  late final HomeCubit homeCubit;
  late final ProfileCubit profileCubit;
  late final VehiclesCubit vehiclesCubit;

  /// Inicializar dependencias
  void init() {
    // Repositorios
    authRepository = AuthRepository();
    homeRepository = HomeRepository();
    profileRepository = ProfileRepository();
    vehicleRepository = VehicleRepository();

    // BLoCs
    authBloc = AuthBloc(authRepository: authRepository);

    // Cubits
    forgotPasswordCubit = ForgotPasswordCubit(authRepository);
    homeCubit = HomeCubit(homeRepository);
    profileCubit = ProfileCubit(profileRepository);
    vehiclesCubit = VehiclesCubit(vehicleRepository);
  }

  /// Limpiar recursos
  void dispose() {
    authBloc.close();
    forgotPasswordCubit.close();
    homeCubit.close();
    profileCubit.close();
    vehiclesCubit.close();
  }
}
