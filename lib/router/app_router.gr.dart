// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AppointmentDetail]
class AppointmentDetailRoute extends PageRouteInfo<AppointmentDetailRouteArgs> {
  AppointmentDetailRoute({
    Key? key,
    required int id,
    List<PageRouteInfo>? children,
  }) : super(
         AppointmentDetailRoute.name,
         args: AppointmentDetailRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'AppointmentDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AppointmentDetailRouteArgs>();
      return AppointmentDetail(key: args.key, id: args.id);
    },
  );
}

class AppointmentDetailRouteArgs {
  const AppointmentDetailRouteArgs({this.key, required this.id});

  final Key? key;

  final int id;

  @override
  String toString() {
    return 'AppointmentDetailRouteArgs{key: $key, id: $id}';
  }
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
