import 'package:dent_app_mobile/core/repo/hear_beats/heart_beats_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/heartbeats/heart_beats_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'heartbeats_state.dart';

class HeartbeatsCubit extends Cubit<HeartbeatsState> {
  HeartbeatsCubit() : super(HeartbeatsInitial());

  final HeartBeatsRepo heartBeatsRepo = HeartBeatsRepo();

  Future<void> getHeartBeats(DateType dateType) async {
    emit(HeartbeatsLoading());
    try {
      final heartbeats = await heartBeatsRepo.getHeartBeats(dateType);
      emit(HeartbeatsLoaded(heartbeats: heartbeats));
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        emit(HeartbeatsError(e.response?.data['message'] ?? ''));
      } else {
        emit(HeartbeatsError(LocaleKeys.errors_something_went_wrong.tr()));
      }
    }
  }
}
