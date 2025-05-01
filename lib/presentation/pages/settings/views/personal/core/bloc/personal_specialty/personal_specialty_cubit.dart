import 'package:dent_app_mobile/core/repo/user/user_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/users/specialty_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'personal_specialty_state.dart';

class PersonalSpecialtyCubit extends Cubit<PersonalSpecialtyState> {
  final UserRepo _userRepo;

  PersonalSpecialtyCubit({UserRepo? userRepo})
    : _userRepo = userRepo ?? UserRepoImpl(),
      super(PersonalSpecialtyInitial());

  /// Fetches all specialties and user's specialties
  Future<void> getSpecialties({required int userId}) async {
    emit(PersonalSpecialtyLoading());
    try {
      final specialties = await _userRepo.getSpecialties(userId);
      final userSpecialties = await _userRepo.getUserSpecialties(
        userId: userId,
      );

      emit(
        PersonalSpecialtyLoaded(
          specialties: specialties,
          userSpecialties: userSpecialties,
        ),
      );
    } on DioException catch (e) {
      emit(PersonalSpecialtyError(message: _formatErrorMessage(e), error: e));
    } catch (e) {
      emit(PersonalSpecialtyError(message: e.toString(), error: e));
    }
  }

  /// Adds specialties to a user
  Future<void> addSpecialty({
    required int userId,
    required List<int> specialtyIds,
  }) async {
    if (specialtyIds.isEmpty) return;

    final currentState = state;
    emit(
      PersonalSpecialtyUpdating(
        previousState: currentState,
        actionType: 'add',
        specialtyIds: specialtyIds,
      ),
    );

    try {
      await _userRepo.addUserSpecialty(
        userId: userId,
        specialtyIds: specialtyIds,
      );

      // Refresh specialties after successful add
      await getSpecialties(userId: userId);
    } on DioException catch (e) {
      emit(
        PersonalSpecialtyError(
          message: _formatErrorMessage(e),
          error: e,
          previousState: currentState,
        ),
      );
    } catch (e) {
      emit(
        PersonalSpecialtyError(
          message: e.toString(),
          error: e,
          previousState: currentState,
        ),
      );
    }
  }

  /// Deletes a specialty from a user
  Future<void> deleteSpecialty({
    required int userId,
    required int specialtyId,
  }) async {
    final currentState = state;
    emit(
      PersonalSpecialtyUpdating(
        previousState: currentState,
        actionType: 'delete',
        specialtyIds: [specialtyId],
      ),
    );

    try {
      await _userRepo.deleteUserSpecialty(
        userId: userId,
        specialtyId: specialtyId,
      );

      // Refresh specialties after successful delete
      await getSpecialties(userId: userId);
    } on DioException catch (e) {
      emit(
        PersonalSpecialtyError(
          message: _formatErrorMessage(e),
          error: e,
          previousState: currentState,
        ),
      );
    } catch (e) {
      emit(
        PersonalSpecialtyError(
          message: e.toString(),
          error: e,
          previousState: currentState,
        ),
      );
    }
  }

  /// Formats error message from DioException
  String _formatErrorMessage(DioException e) {
    String message = LocaleKeys.errors_something_went_wrong.tr();
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response?.data as Map<String, dynamic>;
      if (data.containsKey('message')) {
        message = data['message'];
      }
    }
    return message;
  }

  /// Resets state to initial
  void reset() {
    emit(PersonalSpecialtyInitial());
  }
}
