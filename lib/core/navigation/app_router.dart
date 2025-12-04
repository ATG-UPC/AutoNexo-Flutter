import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password/forgot_password_pages.dart';
import '../../features/bookings/bookings.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/offers/offers.dart';
import '../../features/profile/presentation/pages/pages.dart';
import 'auth_wrapper.dart';

/// Clase que maneja las rutas de la aplicación
class AppRouter {
  // Nombres de las rutas
  static const String initial = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordOtp = '/forgot-password-otp';
  static const String forgotPasswordNewPassword =
      '/forgot-password-new-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String bookings = '/bookings';
  static const String notifications = '/notifications';

  /// Genera las rutas de la aplicación
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
        return MaterialPageRoute(
          builder: (_) => const AuthWrapper(),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordPhonePage(),
          settings: settings,
        );

      case forgotPasswordOtp:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordOtpPage(),
          settings: settings,
        );

      case forgotPasswordNewPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordNewPasswordPage(),
          settings: settings,
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );

      case editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfilePage(),
          settings: settings,
        );

      case changePassword:
        return MaterialPageRoute(
          builder: (_) => const ChangePasswordPage(),
          settings: settings,
        );

      case bookings:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => BookingsCubit()..loadBookings(),
            child: const BookingsListPage(),
          ),
          settings: settings,
        );

      case notifications:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => OffersCubit()..loadMyOffers(),
            child: const NotificationsPage(),
          ),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const AuthWrapper(),
          settings: settings,
        );
    }
  }

  /// Navegar a login
  static void toLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, login);
  }

  /// Navegar a register
  static void toRegister(BuildContext context) {
    Navigator.pushNamed(context, register);
  }

  /// Navegar a forgot password (paso 1: teléfono)
  static void toForgotPassword(BuildContext context) {
    Navigator.pushNamed(context, forgotPassword);
  }

  /// Navegar a forgot password OTP (paso 2: verificación OTP)
  static void toForgotPasswordOtp(BuildContext context) {
    Navigator.pushNamed(context, forgotPasswordOtp);
  }

  /// Navegar a forgot password nueva contraseña (paso 3: nueva contraseña)
  static void toForgotPasswordNewPassword(BuildContext context) {
    Navigator.pushNamed(context, forgotPasswordNewPassword);
  }

  /// Navegar a home (después del login)
  static void toHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, initial);
  }

  /// Navegar a profile
  static void toProfile(BuildContext context) {
    Navigator.pushNamed(context, profile);
  }

  /// Navegar a edit profile
  static void toEditProfile(BuildContext context) {
    Navigator.pushNamed(context, editProfile);
  }

  /// Navegar a change password
  static void toChangePassword(BuildContext context) {
    Navigator.pushNamed(context, changePassword);
  }

  /// Navegar a bookings (mis reservas)
  static void toBookings(BuildContext context) {
    Navigator.pushNamed(context, bookings);
  }

  /// Navegar a notificaciones
  static void toNotifications(BuildContext context) {
    Navigator.pushNamed(context, notifications);
  }

  /// Volver atrás
  static void back(BuildContext context) {
    Navigator.pop(context);
  }
}
