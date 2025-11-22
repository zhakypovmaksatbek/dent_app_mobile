part of 'appointment_works_cubit.dart';

@freezed
class AppointmentWorksState with _$AppointmentWorksState {
  const factory AppointmentWorksState.initial() = _Initial;
  const factory AppointmentWorksState.loaded(List<AppointmentWorkModel> work) =
      _Loaded;
  const factory AppointmentWorksState.loading() = _Loading;
  const factory AppointmentWorksState.error(String message) = _Error;
}
