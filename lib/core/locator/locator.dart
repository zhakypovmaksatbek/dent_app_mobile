import 'package:dent_app_mobile/core/manager/test_mode_manager.dart';
import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/service/dio_settings.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/calendar_appointments/calendar_appointments_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/bloc/appointment_works/appointment_works_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/bloc/manage_work/manage_work_cubit.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;
void setupLocator() {
  getIt.registerSingleton<AppRouter>(AppRouter());
  getIt.registerFactory<AppointmentWorksCubit>(
    () => AppointmentWorksCubit(AppointmentRepo()),
  );
  getIt.registerFactory<ManageWorkCubit>(
    () => ManageWorkCubit(AppointmentRepo()),
  );
  getIt.registerLazySingleton(() => CalendarAppointmentsCubit());
  getIt.registerLazySingleton(() => TestModeManager());
  getIt.registerLazySingleton(() => DioService());
  getIt.registerLazySingleton(() => AuthDioSettings());
}

final dio = getIt<DioService>();
final dioAuth = getIt<AuthDioSettings>();
