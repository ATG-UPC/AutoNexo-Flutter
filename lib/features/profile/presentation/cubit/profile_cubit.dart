import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/status.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/models/models.dart';
import '../../data/repositories/profile_repository.dart';
import 'profile_state.dart';

/// Cubit para manejar el estado del perfil
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileCubit(this._profileRepository) : super(const ProfileState());

  /// Actualizar perfil
  Future<UserModel?> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
  }) async {
    emit(state.copyWith(status: Status.loading));

    try {
      final request = UpdateProfileRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      );

      final updatedUser = await _profileRepository.updateProfile(request);

      emit(
        state.copyWith(
          status: Status.success,
          successMessage: 'Perfil actualizado exitosamente',
        ),
      );

      return updatedUser;
    } catch (e) {
      emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
      return null;
    }
  }

  /// Cambiar contraseña
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(state.copyWith(status: Status.loading));

    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      await _profileRepository.changePassword(request);

      emit(
        state.copyWith(
          status: Status.success,
          successMessage: 'Contraseña cambiada exitosamente',
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
      return false;
    }
  }

  /// Resetear estado
  void reset() {
    emit(const ProfileState());
  }
}
