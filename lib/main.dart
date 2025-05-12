import 'package:dent_app_mobile/core/repo/patient/patient_repo.dart';
import 'package:dent_app_mobile/presentation/localization/app_localization.dart';
import 'package:dent_app_mobile/presentation/pages/auth/core/bloc/login_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/calendar_action/appointment_action_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/calendar_appointments/calendar_appointments_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/doctor/doctor_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/free_time/free_time_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/room/room_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/search_patient/search_patient_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/dashboard/core/heartbeats/heartbeats_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/create_patient/create_patient_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_appointments/patient_appointments_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_bloc/patient_bloc.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_tooth/patient_tooth_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/report/core/bloc/debtor/debtor_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/report/core/bloc/deposit/deposit_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/report/core/bloc/discount/discount_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/report/core/bloc/payment/payment_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/report/core/bloc/report/report_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/diagnosis/core/bloc/cubit/diagnosis_configuration_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/diagnosis/core/bloc/diagnosis/diagnosis_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/appointment/appointment_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal/personal_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_action/personal_action_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_patient/personal_patient_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_specialty/personal_specialty_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_work_schedule/personal_work_schedule_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/services/core/bloc/get_service/get_service_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/services/core/bloc/get_service_item/get_service_item_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/services/core/bloc/service/service_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/services/core/bloc/service_type/service_type_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/warehouse/core/bloc/document/document_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/warehouse/core/bloc/product/product_cubit.dart';
import 'package:dent_app_mobile/presentation/theme/app_theme.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/single_child_widget.dart';

void main() async {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(AppLocalization(child: await Initializer.initialize(MyApp())));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final router = getIt<AppRouter>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router.config(),
      title: 'DentApp Mobile',
      theme: AppTheme.light,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}

final getIt = GetIt.instance;
void setupLocator() {
  getIt.registerSingleton<AppRouter>(AppRouter());
}

class Initializer {
  static Future<Widget> initialize(Widget child) async {
    return MultiBlocProvider(providers: providers, child: child);
  }

  static final List<SingleChildWidget> providers = [
    BlocProvider(create: (context) => LoginCubit()),
    BlocProvider(create: (context) => HeartbeatsCubit()),
    BlocProvider(create: (context) => PatientBloc(patientRepo: PatientRepo())),
    BlocProvider(create: (context) => CreatePatientCubit()),
    BlocProvider(create: (context) => ReportCubit()),
    BlocProvider(create: (context) => PaymentCubit()),
    BlocProvider(create: (context) => DiscountCubit()),
    BlocProvider(create: (context) => DepositCubit()),
    BlocProvider(create: (context) => DebtorCubit()),
    BlocProvider(create: (context) => ServiceCubit()),
    BlocProvider(create: (context) => ServiceTypeCubit()),
    BlocProvider(create: (context) => GetServiceItemCubit()),
    BlocProvider(create: (context) => GetServiceCubit()),
    BlocProvider(create: (context) => DiagnosisCubit()),
    BlocProvider(create: (context) => DiagnosisConfigurationCubit()),
    BlocProvider(create: (context) => PersonalActionCubit()),
    BlocProvider(create: (context) => PersonalCubit()),
    BlocProvider(create: (context) => PersonalPatientCubit()),
    BlocProvider(create: (context) => PersonalSpecialtyCubit()),
    BlocProvider(create: (context) => PersonalWorkScheduleCubit()),
    BlocProvider(create: (context) => AppointmentCubit()),
    BlocProvider(create: (context) => AppointmentActionCubit()),
    BlocProvider(create: (context) => CalendarAppointmentsCubit()),
    BlocProvider(create: (context) => SearchPatientCubit()),
    BlocProvider(create: (context) => FreeTimeCubit()),
    BlocProvider(create: (context) => RoomCubit()),
    BlocProvider(create: (context) => ProductCubit()),
    BlocProvider(create: (context) => DocumentCubit()),
    BlocProvider(create: (context) => DoctorCubit()),
    BlocProvider(create: (context) => PatientAppointmentsCubit()),
    BlocProvider(create: (context) => PatientToothCubit()),
  ];
}
