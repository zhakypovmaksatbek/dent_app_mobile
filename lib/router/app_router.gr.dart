// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AboutClinicPage]
class AboutClinicRoute extends PageRouteInfo<void> {
  const AboutClinicRoute({List<PageRouteInfo>? children})
    : super(AboutClinicRoute.name, initialChildren: children);

  static const String name = 'AboutClinicRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AboutClinicPage();
    },
  );
}

/// generated route for
/// [AppointmentWorkHistory]
class AppointmentWorkHistoryRoute
    extends PageRouteInfo<AppointmentWorkHistoryRouteArgs> {
  AppointmentWorkHistoryRoute({
    Key? key,
    required List<AppointmentWorkModel> works,
    required int appointmentId,
    required AppointmentWorksCubit appointmentWorkHistory,
    List<PageRouteInfo>? children,
  }) : super(
         AppointmentWorkHistoryRoute.name,
         args: AppointmentWorkHistoryRouteArgs(
           key: key,
           works: works,
           appointmentId: appointmentId,
           appointmentWorkHistory: appointmentWorkHistory,
         ),
         initialChildren: children,
       );

  static const String name = 'AppointmentWorkHistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AppointmentWorkHistoryRouteArgs>();
      return AppointmentWorkHistory(
        key: args.key,
        works: args.works,
        appointmentId: args.appointmentId,
        appointmentWorkHistory: args.appointmentWorkHistory,
      );
    },
  );
}

class AppointmentWorkHistoryRouteArgs {
  const AppointmentWorkHistoryRouteArgs({
    this.key,
    required this.works,
    required this.appointmentId,
    required this.appointmentWorkHistory,
  });

  final Key? key;

  final List<AppointmentWorkModel> works;

  final int appointmentId;

  final AppointmentWorksCubit appointmentWorkHistory;

  @override
  String toString() {
    return 'AppointmentWorkHistoryRouteArgs{key: $key, works: $works, appointmentId: $appointmentId, appointmentWorkHistory: $appointmentWorkHistory}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AppointmentWorkHistoryRouteArgs) return false;
    return key == other.key &&
        const ListEquality<AppointmentWorkModel>().equals(works, other.works) &&
        appointmentId == other.appointmentId &&
        appointmentWorkHistory == other.appointmentWorkHistory;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const ListEquality<AppointmentWorkModel>().hash(works) ^
      appointmentId.hashCode ^
      appointmentWorkHistory.hashCode;
}

/// generated route for
/// [CalendarPage]
class CalendarRoute extends PageRouteInfo<void> {
  const CalendarRoute({List<PageRouteInfo>? children})
    : super(CalendarRoute.name, initialChildren: children);

  static const String name = 'CalendarRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CalendarPage();
    },
  );
}

/// generated route for
/// [CreatePersonalView]
class CreatePersonalRoute extends PageRouteInfo<CreatePersonalRouteArgs> {
  CreatePersonalRoute({
    Key? key,
    UserModel? user,
    List<PageRouteInfo>? children,
  }) : super(
         CreatePersonalRoute.name,
         args: CreatePersonalRouteArgs(key: key, user: user),
         initialChildren: children,
       );

  static const String name = 'CreatePersonalRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreatePersonalRouteArgs>(
        orElse: () => const CreatePersonalRouteArgs(),
      );
      return CreatePersonalView(key: args.key, user: args.user);
    },
  );
}

class CreatePersonalRouteArgs {
  const CreatePersonalRouteArgs({this.key, this.user});

  final Key? key;

  final UserModel? user;

  @override
  String toString() {
    return 'CreatePersonalRouteArgs{key: $key, user: $user}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreatePersonalRouteArgs) return false;
    return key == other.key && user == other.user;
  }

  @override
  int get hashCode => key.hashCode ^ user.hashCode;
}

/// generated route for
/// [DashboardPage]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DashboardPage();
    },
  );
}

/// generated route for
/// [DiagnosisPage]
class DiagnosisRoute extends PageRouteInfo<void> {
  const DiagnosisRoute({List<PageRouteInfo>? children})
    : super(DiagnosisRoute.name, initialChildren: children);

  static const String name = 'DiagnosisRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DiagnosisPage();
    },
  );
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginPage();
    },
  );
}

/// generated route for
/// [MainPage]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainPage();
    },
  );
}

/// generated route for
/// [PatientDetail]
class PatientDetailRoute extends PageRouteInfo<PatientDetailRouteArgs> {
  PatientDetailRoute({Key? key, required int id, List<PageRouteInfo>? children})
    : super(
        PatientDetailRoute.name,
        args: PatientDetailRouteArgs(key: key, id: id),
        initialChildren: children,
      );

  static const String name = 'PatientDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PatientDetailRouteArgs>();
      return PatientDetail(key: args.key, id: args.id);
    },
  );
}

class PatientDetailRouteArgs {
  const PatientDetailRouteArgs({this.key, required this.id});

  final Key? key;

  final int id;

  @override
  String toString() {
    return 'PatientDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PatientDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [PatientPage]
class PatientRoute extends PageRouteInfo<void> {
  const PatientRoute({List<PageRouteInfo>? children})
    : super(PatientRoute.name, initialChildren: children);

  static const String name = 'PatientRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PatientPage();
    },
  );
}

/// generated route for
/// [PaymentDetailPage]
class PaymentDetailRoute extends PageRouteInfo<PaymentDetailRouteArgs> {
  PaymentDetailRoute({
    Key? key,
    required int appointmentId,
    List<PageRouteInfo>? children,
  }) : super(
         PaymentDetailRoute.name,
         args: PaymentDetailRouteArgs(key: key, appointmentId: appointmentId),
         initialChildren: children,
       );

  static const String name = 'PaymentDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PaymentDetailRouteArgs>();
      return PaymentDetailPage(
        key: args.key,
        appointmentId: args.appointmentId,
      );
    },
  );
}

class PaymentDetailRouteArgs {
  const PaymentDetailRouteArgs({this.key, required this.appointmentId});

  final Key? key;

  final int appointmentId;

  @override
  String toString() {
    return 'PaymentDetailRouteArgs{key: $key, appointmentId: $appointmentId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaymentDetailRouteArgs) return false;
    return key == other.key && appointmentId == other.appointmentId;
  }

  @override
  int get hashCode => key.hashCode ^ appointmentId.hashCode;
}

/// generated route for
/// [PaymentView]
class PaymentViewRoute extends PageRouteInfo<PaymentViewRouteArgs> {
  PaymentViewRoute({
    Key? key,
    required int appointmentId,
    List<PageRouteInfo>? children,
  }) : super(
         PaymentViewRoute.name,
         args: PaymentViewRouteArgs(key: key, appointmentId: appointmentId),
         initialChildren: children,
       );

  static const String name = 'PaymentViewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PaymentViewRouteArgs>();
      return PaymentView(key: args.key, appointmentId: args.appointmentId);
    },
  );
}

class PaymentViewRouteArgs {
  const PaymentViewRouteArgs({this.key, required this.appointmentId});

  final Key? key;

  final int appointmentId;

  @override
  String toString() {
    return 'PaymentViewRouteArgs{key: $key, appointmentId: $appointmentId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaymentViewRouteArgs) return false;
    return key == other.key && appointmentId == other.appointmentId;
  }

  @override
  int get hashCode => key.hashCode ^ appointmentId.hashCode;
}

/// generated route for
/// [PersonalDetailPage]
class PersonalDetailRoute extends PageRouteInfo<PersonalDetailRouteArgs> {
  PersonalDetailRoute({
    Key? key,
    required int userId,
    List<PageRouteInfo>? children,
  }) : super(
         PersonalDetailRoute.name,
         args: PersonalDetailRouteArgs(key: key, userId: userId),
         initialChildren: children,
       );

  static const String name = 'PersonalDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PersonalDetailRouteArgs>();
      return PersonalDetailPage(key: args.key, userId: args.userId);
    },
  );
}

class PersonalDetailRouteArgs {
  const PersonalDetailRouteArgs({this.key, required this.userId});

  final Key? key;

  final int userId;

  @override
  String toString() {
    return 'PersonalDetailRouteArgs{key: $key, userId: $userId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PersonalDetailRouteArgs) return false;
    return key == other.key && userId == other.userId;
  }

  @override
  int get hashCode => key.hashCode ^ userId.hashCode;
}

/// generated route for
/// [PersonalPage]
class PersonalRoute extends PageRouteInfo<void> {
  const PersonalRoute({List<PageRouteInfo>? children})
    : super(PersonalRoute.name, initialChildren: children);

  static const String name = 'PersonalRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PersonalPage();
    },
  );
}

/// generated route for
/// [PersonalPatientsPage]
class PersonalPatientsRoute extends PageRouteInfo<PersonalPatientsRouteArgs> {
  PersonalPatientsRoute({
    Key? key,
    required int userId,
    List<PageRouteInfo>? children,
  }) : super(
         PersonalPatientsRoute.name,
         args: PersonalPatientsRouteArgs(key: key, userId: userId),
         initialChildren: children,
       );

  static const String name = 'PersonalPatientsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PersonalPatientsRouteArgs>();
      return PersonalPatientsPage(key: args.key, userId: args.userId);
    },
  );
}

class PersonalPatientsRouteArgs {
  const PersonalPatientsRouteArgs({this.key, required this.userId});

  final Key? key;

  final int userId;

  @override
  String toString() {
    return 'PersonalPatientsRouteArgs{key: $key, userId: $userId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PersonalPatientsRouteArgs) return false;
    return key == other.key && userId == other.userId;
  }

  @override
  int get hashCode => key.hashCode ^ userId.hashCode;
}

/// generated route for
/// [PersonalRouterRoute]
class PersonalNavigationRoute extends PageRouteInfo<void> {
  const PersonalNavigationRoute({List<PageRouteInfo>? children})
    : super(PersonalNavigationRoute.name, initialChildren: children);

  static const String name = 'PersonalNavigationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PersonalRouterRoute();
    },
  );
}

/// generated route for
/// [ReportPage]
class ReportRoute extends PageRouteInfo<void> {
  const ReportRoute({List<PageRouteInfo>? children})
    : super(ReportRoute.name, initialChildren: children);

  static const String name = 'ReportRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ReportPage();
    },
  );
}

/// generated route for
/// [ServicesPage]
class ServicesRoute extends PageRouteInfo<void> {
  const ServicesRoute({List<PageRouteInfo>? children})
    : super(ServicesRoute.name, initialChildren: children);

  static const String name = 'ServicesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ServicesPage();
    },
  );
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsPage();
    },
  );
}

/// generated route for
/// [SplashPage]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashPage();
    },
  );
}

/// generated route for
/// [TeethConditionAction]
class TeethConditionActionRoute
    extends PageRouteInfo<TeethConditionActionRouteArgs> {
  TeethConditionActionRoute({
    Key? key,
    required int appointmentId,
    required PatientToothCubit patientToothCubit,
    required int patientId,
    required AppointmentWorksCubit appointmentWorksCubit,
    List<PageRouteInfo>? children,
  }) : super(
         TeethConditionActionRoute.name,
         args: TeethConditionActionRouteArgs(
           key: key,
           appointmentId: appointmentId,
           patientToothCubit: patientToothCubit,
           patientId: patientId,
           appointmentWorksCubit: appointmentWorksCubit,
         ),
         initialChildren: children,
       );

  static const String name = 'TeethConditionActionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TeethConditionActionRouteArgs>();
      return TeethConditionAction(
        key: args.key,
        appointmentId: args.appointmentId,
        patientToothCubit: args.patientToothCubit,
        patientId: args.patientId,
        appointmentWorksCubit: args.appointmentWorksCubit,
      );
    },
  );
}

class TeethConditionActionRouteArgs {
  const TeethConditionActionRouteArgs({
    this.key,
    required this.appointmentId,
    required this.patientToothCubit,
    required this.patientId,
    required this.appointmentWorksCubit,
  });

  final Key? key;

  final int appointmentId;

  final PatientToothCubit patientToothCubit;

  final int patientId;

  final AppointmentWorksCubit appointmentWorksCubit;

  @override
  String toString() {
    return 'TeethConditionActionRouteArgs{key: $key, appointmentId: $appointmentId, patientToothCubit: $patientToothCubit, patientId: $patientId, appointmentWorksCubit: $appointmentWorksCubit}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TeethConditionActionRouteArgs) return false;
    return key == other.key &&
        appointmentId == other.appointmentId &&
        patientToothCubit == other.patientToothCubit &&
        patientId == other.patientId &&
        appointmentWorksCubit == other.appointmentWorksCubit;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      appointmentId.hashCode ^
      patientToothCubit.hashCode ^
      patientId.hashCode ^
      appointmentWorksCubit.hashCode;
}

/// generated route for
/// [TreatmentPage]
class TreatmentRoute extends PageRouteInfo<TreatmentRouteArgs> {
  TreatmentRoute({
    Key? key,
    CalendarAppointmentModel? calendarAppointment,
    List<PageRouteInfo>? children,
  }) : super(
         TreatmentRoute.name,
         args: TreatmentRouteArgs(
           key: key,
           calendarAppointment: calendarAppointment,
         ),
         initialChildren: children,
       );

  static const String name = 'TreatmentRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TreatmentRouteArgs>(
        orElse: () => const TreatmentRouteArgs(),
      );
      return TreatmentPage(
        key: args.key,
        calendarAppointment: args.calendarAppointment,
      );
    },
  );
}

class TreatmentRouteArgs {
  const TreatmentRouteArgs({this.key, this.calendarAppointment});

  final Key? key;

  final CalendarAppointmentModel? calendarAppointment;

  @override
  String toString() {
    return 'TreatmentRouteArgs{key: $key, calendarAppointment: $calendarAppointment}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TreatmentRouteArgs) return false;
    return key == other.key && calendarAppointment == other.calendarAppointment;
  }

  @override
  int get hashCode => key.hashCode ^ calendarAppointment.hashCode;
}

/// generated route for
/// [WarehousePage]
class WarehouseRoute extends PageRouteInfo<void> {
  const WarehouseRoute({List<PageRouteInfo>? children})
    : super(WarehouseRoute.name, initialChildren: children);

  static const String name = 'WarehouseRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WarehousePage();
    },
  );
}

/// generated route for
/// [WorkItemsView]
class WorkItemsRoute extends PageRouteInfo<WorkItemsRouteArgs> {
  WorkItemsRoute({
    Key? key,
    required int appointmentId,
    required PatientToothCubit patientToothCubit,
    required int patientId,
    required AppointmentWorksCubit appointmentWorksCubit,
    List<PageRouteInfo>? children,
  }) : super(
         WorkItemsRoute.name,
         args: WorkItemsRouteArgs(
           key: key,
           appointmentId: appointmentId,
           patientToothCubit: patientToothCubit,
           patientId: patientId,
           appointmentWorksCubit: appointmentWorksCubit,
         ),
         initialChildren: children,
       );

  static const String name = 'WorkItemsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WorkItemsRouteArgs>();
      return WorkItemsView(
        key: args.key,
        appointmentId: args.appointmentId,
        patientToothCubit: args.patientToothCubit,
        patientId: args.patientId,
        appointmentWorksCubit: args.appointmentWorksCubit,
      );
    },
  );
}

class WorkItemsRouteArgs {
  const WorkItemsRouteArgs({
    this.key,
    required this.appointmentId,
    required this.patientToothCubit,
    required this.patientId,
    required this.appointmentWorksCubit,
  });

  final Key? key;

  final int appointmentId;

  final PatientToothCubit patientToothCubit;

  final int patientId;

  final AppointmentWorksCubit appointmentWorksCubit;

  @override
  String toString() {
    return 'WorkItemsRouteArgs{key: $key, appointmentId: $appointmentId, patientToothCubit: $patientToothCubit, patientId: $patientId, appointmentWorksCubit: $appointmentWorksCubit}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkItemsRouteArgs) return false;
    return key == other.key &&
        appointmentId == other.appointmentId &&
        patientToothCubit == other.patientToothCubit &&
        patientId == other.patientId &&
        appointmentWorksCubit == other.appointmentWorksCubit;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      appointmentId.hashCode ^
      patientToothCubit.hashCode ^
      patientId.hashCode ^
      appointmentWorksCubit.hashCode;
}
