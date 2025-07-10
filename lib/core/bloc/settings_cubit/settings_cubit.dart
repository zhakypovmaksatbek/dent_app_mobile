import 'package:dent_app_mobile/core/repo/clinic/clinic_i_repo.dart';
import 'package:dent_app_mobile/core/repo/clinic/clinic_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/clinic/clinic_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial());
  final ClinicIRepo _settingsRepo = ClinicRepo();

  Future<void> getSettings() async {
    emit(SettingsLoading());
    try {
      final clinic = await _settingsRepo.getClinic();
      emit(SettingsSuccess(clinic: clinic));
    } on DioException catch (e) {
      emit(SettingsError(error: FormatUtils.formatErrorMessage(e)));
    }
  }
}
