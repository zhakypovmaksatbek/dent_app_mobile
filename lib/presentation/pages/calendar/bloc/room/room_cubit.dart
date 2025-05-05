import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/appointment/room_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'room_state.dart';

class RoomCubit extends Cubit<RoomState> {
  RoomCubit() : super(RoomInitial());

  final AppointmentRepo appointmentRepo = AppointmentRepo();

  Future<void> getRoomList() async {
    emit(RoomLoading());
    try {
      final rooms = await appointmentRepo.getRoomList();
      emit(RoomLoaded(rooms: rooms));
    } on DioException catch (e) {
      emit(RoomFailure(message: FormatUtils.formatErrorMessage(e)));
    }
  }
}
